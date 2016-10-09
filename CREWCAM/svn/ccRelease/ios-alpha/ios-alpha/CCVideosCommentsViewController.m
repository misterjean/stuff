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
@synthesize commentsTableView;
@synthesize videoForView;
@synthesize videoPlayer;
@synthesize wasPlayingMedia;
@synthesize crewForView;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [commentsTableView setDataSource:self];
    
    [videoForView addVideoUpdateListener:self];
    
    [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)];        
    
    [[self view] addCrewcamTitleToViewController:@"COMMENTS"];
    
    [videoForView loadCommentsInBackgroundWithBlockOrNil:nil];
    
    if ([[videoForView ccComments] count] > 0)
    {
        [loadingLabel setHidden:YES];
        [commentsTableView setHidden:NO];
        [commentsTableView reloadData];
    }
    else if ([videoForView getNumberOfComments] == 0) 
    {
        [loadingLabel setHidden:YES];
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
        [loadingLabel setText:@"NO COMMENTS."];
    }
}

- (void) addedNewCommentsAtIndexes:(NSArray *) addedCommentIndexes andRemovedCommentsAtIndexes:(NSArray *)removedCommentIndexes
{    
    if([[videoForView ccComments] count] == 0)
    {
        [commentsTableView setHidden:YES];
        [loadingLabel setText:@"NO COMMENTS."];
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

- (IBAction)onAddCommentPressed:(id)sender 
{
    CCCrewcamAlertView * alert = [[CCCrewcamAlertView alloc] initWithTitle:@"New Comment" message:nil withTextField:YES delegate:self cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
    
    [alert show];
}

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {        
        if ([[alertView getTextField] text] && !
            [[[alertView getTextField] text] isEqualToString:@""]) {
        
            [[[CCCoreManager sharedInstance] server] addNewCommentToVideo:videoForView inCrew:crewForView withText:[[alertView getTextField] text] withBlockOrNil:^(BOOL succeeded, NSError *error)
            {
                if (!succeeded)
                {
                    CCCrewcamAlertView * alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Uh oh..." message:@"Error adding your comment." withTextField:NO delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                    
                    [alert show];
                }
            }];        
        }
        else 
        {
            CCCrewcamAlertView * alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Uh oh..." message:@"Don't Put Null Messages." withTextField:NO delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            
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
    
    [self setLoadingLabel:nil];
    [self setCommentsTableView:nil];
    [self setVideoForView:nil];
    [self setVideoPlayer:nil];
    [self setCrewForView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
