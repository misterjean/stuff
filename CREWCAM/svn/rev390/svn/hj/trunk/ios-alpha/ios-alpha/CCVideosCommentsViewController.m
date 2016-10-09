//
//  CCVideosCommentsViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCVideosCommentsViewController.h"

@interface CCVideosCommentsViewController ()

@end

@implementation CCVideosCommentsViewController
@synthesize loadingLabel;
@synthesize loadingActivityIndicator;
@synthesize commentsTableView;
@synthesize videoInfoView;
@synthesize videoThumbnail;
@synthesize videoTitleLabel;
@synthesize videoForView;
@synthesize videoPlayer;
@synthesize wasPlayingMedia;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)]];
    
    [[self navigationItem] setRightBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Add" target:self action:@selector(onAddCommentPressed:)]];
    
    [commentsTableView setDataSource:self];
    
    [videoForView addVideoUpdateListener:self];
    
    [videoForView loadCommentsInBackgroundWithBlockOrNil:nil];
    
    [self setUpVideoInfoView];
    
    if ([[videoForView ccComments] count] > 0)
    {
        [loadingLabel setHidden:YES];
        [commentsTableView setHidden:NO];
        [commentsTableView reloadData];
        [loadingActivityIndicator setHidden:YES];
    }
    else if ([videoForView getNumberOfComments] == 0) 
    {
        [loadingLabel setHidden:YES];
        [loadingActivityIndicator setHidden:YES];
        [loadingLabel setHidden:NO];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([[videoForView ccComments] count] == 0)
    {
        [commentsTableView setHidden:YES];
        [loadingLabel setHidden:NO];        
    }
    else
    {
        [commentsTableView setHidden:NO];
        [loadingLabel setHidden:YES];
    }
    
}

- (void) onBackButtonPressed:(id) sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void) setVideoForView:(id<CCVideo>) video
{
    videoForView = video;
}

- (void) finishedLoadingCommentsWithSuccess:(BOOL)successful andError:(NSError *)error
{
    if([[videoForView ccComments] count] == 0)
    {
        [loadingLabel setText:@"No comments yet."];
    }
}

- (void) addedNewCommentsAtIndexes:(NSArray *) addedCommentIndexes andRemovedCommentsAtIndexes:(NSArray *)removedCommentIndexes
{
    [loadingActivityIndicator setHidden:YES];
    
    if([[videoForView ccComments] count] == 0)
    {
        [commentsTableView setHidden:YES];
        [loadingLabel setText:@"No comments yet."];
        [loadingLabel setHidden:NO];        
    }
    else
    {
        [commentsTableView setHidden:NO];
        [loadingLabel setHidden:YES];
        
        [commentsTableView beginUpdates];
        
        [commentsTableView deleteRowsAtIndexPaths:removedCommentIndexes withRowAnimation:UITableViewRowAnimationFade];
        [commentsTableView insertRowsAtIndexPaths:addedCommentIndexes withRowAnimation:UITableViewRowAnimationFade];            
        
        [commentsTableView endUpdates]; 
        [commentsTableView reloadData];
    }
}

- (void) setUpVideoInfoView
{
    [videoTitleLabel setText:[videoForView getName]];
    
    
    if ([videoForView getThumbnail] == nil)
    {
        [videoForView loadThumbnailInBackground];
        [videoThumbnail setImage:nil];
    }
    else 
    {
        [videoThumbnail setImage:[videoForView getThumbnail]];
    }
}

- (void)finishedLoadingThumbnailWithSucess:(BOOL)successful andError:(NSError *)error
{
    if (successful)
        [videoThumbnail setImage:[videoForView getThumbnail]];
}

- (IBAction)onAddCommentPressed:(id)sender 
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Comment" message:@"  " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    

    commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
    [commentTextField setBackgroundColor:[UIColor whiteColor]];
    [commentTextField  becomeFirstResponder];
    [alert addSubview:commentTextField];
    
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [loadingActivityIndicator setHidden:NO];
        
        if ([commentTextField text] && !
            [[commentTextField text] isEqualToString:@""]) {
        
            [[[CCCoreManager sharedInstance] server] addNewCommentToVideo:videoForView withText:[commentTextField text] withBlockOrNil:^(BOOL succeeded, NSError *error) 
            {
                [loadingActivityIndicator setHidden:YES];
                
                if (!succeeded)
                {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"Error adding your comment." delegate:self cancelButtonTitle:@"You suck." otherButtonTitles:nil, nil];
                    
                    [alert show];
                }
            }];        
        }
        else 
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"Don't Put Null Messages." delegate:self cancelButtonTitle:@"You suck." otherButtonTitles:nil, nil];
            
            [loadingActivityIndicator setHidden:YES];
            
            [alert show];
        }
    }
        
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[videoForView ccComments] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<CCComment> commentForCell = [[videoForView ccComments] objectAtIndex:[indexPath row]];
    
    static NSString *CellIdentifier = @"commentTableCell";
    CCCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[CCCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell initializeWithComment:commentForCell];
    
    return cell;    
}

- (void)viewDidUnload
{
    [videoForView removeVideoUpdateListener:self];
    
    commentTextField = nil;
    
    [self setLoadingLabel:nil];
    [self setLoadingActivityIndicator:nil];
    [self setCommentsTableView:nil];
    [self setVideoInfoView:nil];
    [self setVideoThumbnail:nil];
    [self setVideoTitleLabel:nil];
    [self setVideoForView:nil];
    [self setVideoPlayer:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)videoThumbnailPressed:(id)sender
{
    if (![videoForView isUploading])
        [self playVideo];
}

//lots of duplicated code from the video cell not sure if we should try and seperate this out later or not
- (void)playVideo
{  
    /*This code may look stupid, and maybe it is. Essentially we spawn a new thread and do nothing.
     The reason we do this is because the button press action call needs complete and return for the gui 
     to update. The GUI needs to update to display an activity indicator while the video loads.
     Dispatching a new thread was the only way I could think of doing it. If you have a better solution
     feel free to implement it.*/
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async( dispatch_get_main_queue(), ^{
              self.videoPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[[NSURL alloc] initWithString:[videoForView getVideoURL]]];
              self.videoPlayer.moviePlayer.allowsAirPlay=YES;
              if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) 
                  wasPlayingMedia = YES;
              
              [videoForView addViewInBackground:[[[CCCoreManager sharedInstance] server] currentUser] withBlockOrNil:nil];
              
              [[NSNotificationCenter defaultCenter] 
               addObserver:self 
               selector:@selector(playMovieFinished:) 
               name:MPMoviePlayerPlaybackDidFinishNotification 
               object:self.videoPlayer.moviePlayer];
              
              [[NSNotificationCenter defaultCenter]
               addObserver:self
               selector:@selector(MPMoviePlayerDidExitFullscreen:)
               name:MPMoviePlayerDidExitFullscreenNotification
               object:self.videoPlayer.moviePlayer];
              
              [self.videoPlayer.moviePlayer setFullscreen:YES animated:YES];
              [self presentMoviePlayerViewControllerAnimated:self.videoPlayer];
              [[CCCoreManager sharedInstance] recordMetricEvent:CC_VIEWED_VIDEO withProperties:nil];
        });
   });  
}

- (void)playMovieFinished:(NSNotification*)theNotification
{   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.videoPlayer.moviePlayer stop];
    self.videoPlayer = nil;
    
    [self.videoPlayer.moviePlayer stop];
    
    self.videoPlayer = nil;
    
    NSError *error = [[theNotification userInfo] objectForKey:@"error"];
    if (error)
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed Loading Video: %@", [error localizedDescription]];  
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Video Playback Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
        
        [alert show];
    }
    
    if (wasPlayingMedia)
    {
        [[MPMusicPlayerController iPodMusicPlayer] play];
        wasPlayingMedia = NO;
    }
}

- (void)MPMoviePlayerDidExitFullscreen:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.videoPlayer.moviePlayer stop];
    self.videoPlayer = nil;
    
    if (wasPlayingMedia)
    {
        [[MPMusicPlayerController iPodMusicPlayer] play];
        wasPlayingMedia = NO;
    }
}

@end
