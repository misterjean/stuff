//
//  CCVideoViewController.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewViewController.h"

@interface CCCrewViewController ()

@end

@implementation CCCrewViewController
@synthesize videoTableView;
@synthesize crewForView;
@synthesize videoPlayer;
@synthesize sortedVideoList;
@synthesize noVideosLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (IBAction)onBackButtonPressed:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[crewForView videos] count] == 0)
    {
        [noVideosLabel setHidden:NO];
        [videoTableView setHidden:YES];
    }
    else 
    {
        [noVideosLabel setHidden:YES];
        [videoTableView setHidden:NO];
        sortedVideoList  = [[NSArray alloc] initWithArray:[crewForView videos]];
        [[self videoTableView] reloadData];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:[crewForView name]];
    
    [videoTableView setDataSource:self];
}

- (void)viewDidUnload
{
    [self setVideoTableView:nil];
    [self setNoVideosLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[crewForView videos] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	 
    static NSString *CellIdentifier = @"videoTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id<CCVideo> videoForCell = [[crewForView videos] objectAtIndex:[indexPath row]];
    
    UIImageView *profilePicImageView = (UIImageView *)[cell viewWithTag:VIDEO_OWNER_PICTURE_TAG];    
    
    UILabel *videoTitleView = (UILabel *)[cell viewWithTag:VIDEO_TITLE_TAG];
    NSString *videoTitle = [[NSString alloc] initWithFormat:@"\"%@\"", [videoForCell name]];
    [videoTitleView setText:videoTitle];
    
    UIImageView *videoPreviewImageView = (UIImageView *)[cell viewWithTag:VIDEO_PREVIEW_PICTURE_TAG];
    
    // Start downloading the image and display it on a seperate thread
    if ([videoForCell videoImageData] == nil)
    {
        [videoForCell loadThumbnailWithNewThread:NO];
        UIImage *thumbNail = [[UIImage alloc] initWithData:[videoForCell videoImageData]];
        [videoPreviewImageView setImage:thumbNail];
    }
    else
    {
        UIImage *thumbNail = [[UIImage alloc] initWithData:[videoForCell videoImageData]];
        [videoPreviewImageView setImage:thumbNail];
    }

    UILabel *ownerNameLabel = (UILabel *)[cell viewWithTag:VIDEO_OWNER_NAME_TAG];
    [ownerNameLabel setText:[[videoForCell owner] name]];
    
    UILabel *distanceLabel = (UILabel *)[cell viewWithTag:VIDEO_DISTANCE_AWAY_TAG];
    
    if (nil != [videoForCell location] && nil != [[[CCCoreManager sharedInstance]locationManager] getCurrentLocation])
    {
        CLLocationDistance distance = [[videoForCell location] distanceFromLocation:[[[CCCoreManager sharedInstance]locationManager] getCurrentLocation]];            
        NSString *distanceString;
        if ((distance/1000) < 5)
        {
            distanceString = [NSString stringWithFormat:@"Right nearby!"];
        }
        else if((distance/1000) > 100)
        {
            distanceString = [NSString stringWithFormat:@"More than 100 km away."];
        }
        else 
        {
            distanceString = [NSString stringWithFormat:@"%.2f km away.", distance/1000];            
        }
        
        distanceLabel.text = distanceString;
    }
    
    NSTimeInterval timeSincePosting = [[NSDate date] timeIntervalSinceDate:[videoForCell createdDate]];
    
    NSString *timeSinceString;
    
    if (timeSincePosting/60 < 1) 
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"Posted %.f seconds ago", timeSincePosting];    
    }
    else if (timeSincePosting/60 < 60)
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"Posted %.f minutes ago", timeSincePosting/60];            
    }    
    else if (timeSincePosting/60/60 < 24)
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"Posted %.f hours ago", timeSincePosting/60/60];
    }
    else if (timeSincePosting/60/60 < 24*31)
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"Posted %.f days ago", timeSincePosting/60/60/24];
    }
    else 
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"Posted %.f months ago", timeSincePosting/60/60/24/31];
    }
    
    UILabel *timePostedLabel = (UILabel *)[cell viewWithTag:VIDEO_TIME_POSTED_TAG];
    [timePostedLabel setText:timeSinceString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<CCVideo> videoToPlay = [[crewForView videos] objectAtIndex:indexPath.row];
    NSURL *url = [[NSURL alloc]initWithString:[videoToPlay videoURL]];
    
    self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    self.videoPlayer.allowsAirPlay=YES;
    
    [self.view addSubview:self.videoPlayer.view];
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(playMovieFinished:) 
     name:MPMoviePlayerPlaybackDidFinishNotification 
     object:self.videoPlayer];
    
    [self.videoPlayer setFullscreen:YES animated:YES];          
}

- (void)playMovieFinished:(NSNotification*)theNotification{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:self.videoPlayer];
    
    [self.videoPlayer.view removeFromSuperview];
}

- (IBAction)onLeaveButtonPressed:(id)sender 
{
    [[[CCCoreManager sharedInstance] server] removeCurrentUserFromCrew:crewForView useNewThread:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"addMemberSegue"])
    {
        CCNewCrewViewController *vc = [segue destinationViewController];
        [vc setPassedCrew:crewForView];
    }
    
}
@end
