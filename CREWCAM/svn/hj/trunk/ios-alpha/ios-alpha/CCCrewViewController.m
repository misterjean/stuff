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
@synthesize sortedVideoList;
@synthesize noVideosLabel;
@synthesize topBarView;

- (IBAction)onBackButtonPressed:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [crewForView addCrewUpdateListener:self];
    
    [videoTableView setDataSource:self];
    
    topBarView.layer.shadowRadius = 10;
    topBarView.layer.shadowOpacity = 1;
    
    [self reloadVideosOnBackgroundThread];
    
    if ([[crewForView ccVideos] count] > 0)
    {
        [videoTableView setHidden:NO];
        [noVideosLabel setHidden:YES];
    }    
    else if ([crewForView getNumberOfVideos] > 0)
    {
        [noVideosLabel setText:@"Loading videos..."];
    }
    
    [self setTitle:[crewForView getName]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)reloadVideosOnBackgroundThread
{    
    [crewForView loadVideosInBackgroundWithBlockOrNil:nil];
}

- (void) addedNewVideosAtIndexes:(NSArray *) newVideoIndexes andRemovedVideosAtIndexes:(NSArray *) deletedVideoIndexes
{

    [videoTableView setHidden:NO];
    [noVideosLabel setHidden:YES];
    
    [videoTableView beginUpdates];

    [videoTableView deleteRowsAtIndexPaths:deletedVideoIndexes withRowAnimation:UITableViewRowAnimationFade];
    [videoTableView insertRowsAtIndexPaths:newVideoIndexes withRowAnimation:UITableViewRowAnimationFade];            
    
    [videoTableView endUpdates];    
}

- (void)viewDidUnload
{
    [self setVideoTableView:nil];
    [self setNoVideosLabel:nil];
    
    [crewForView removeCrewUpdateListener:self];
    
    [self setTopBarView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[crewForView ccVideos] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	 
    static NSString *CellIdentifier = @"videoTableCell";
    CCVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id<CCVideo> videoForCell = [[crewForView ccVideos] objectAtIndex:[indexPath row]];
    
    if (cell == nil)
    {
        cell = [[CCVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
<<<<<<< .mine
    UILabel *videoLengthLabel = (UILabel *)[cell viewWithTag: VIDEO_LENGTH];
    [videoLengthLabel setText: @"20 minutes"];
    
    UIButton *playVideoButton = (UIButton *)[cell viewWithTag:VIDEO_PLAY_BUTTON];
    [playVideoButton addTarget:self action:@selector(playSelectedMovie:) forControlEvents:UIControlEventTouchUpInside];
=======
    [cell initializeWithVideo:videoForCell andNavigationController:[self navigationController]];
>>>>>>> .r260
    
<<<<<<< .mine
    UIButton *videoViewsButton = (UIButton *)[cell viewWithTag:VIDEO_VIEWS_BUTTON];
    [videoViewsButton addTarget:self action:@selector(loadViewersList:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
=======
>>>>>>> .r260
    return cell;
}

- (IBAction)onLeaveButtonPressed:(id)sender 
{
    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserFromCrew:crewForView WithBlockOrNil:nil];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"addMemberSegue"])
    {
        CCNewCrewViewController *vc = [segue destinationViewController];
        [vc setPassedCrew:crewForView];
    }
    else if ([[segue identifier] isEqualToString:@"membersListPush"])
    {
        CCCrewMembersViewController *crewMembersView = [segue destinationViewController];
        [crewMembersView setCrewForView:crewForView];
    }
}
- (IBAction)doSomething:(id)sender {
}
@end
