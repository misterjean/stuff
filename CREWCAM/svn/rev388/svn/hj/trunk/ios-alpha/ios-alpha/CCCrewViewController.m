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


- (void) refreshTableOnPullUp
{
    [self loadOldVideosOnBackgroundThread];
}

- (IBAction)onBackButtonPressed:(id)sender 
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [crewForView addCrewUpdateListener:self];
    
    [videoTableView setDataSource:self];
    [videoTableView setTableDelegate:self];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CCCleanUpTableNotificationReceived:) name:@"CleanUpTableNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CCReloadCrewNotificationReceived:) name:@"ReloadCrewNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationItem] setRightBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Leave" target:self action:@selector(onLeaveButtonPressed:)]];
    
    [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)]];
}

-(void) initWithCrew:(id<CCCrew>)crew
{
    [self setCrewForView:crew];
    [self setTitle:[crew getName]];
}

- (void)reloadVideosOnBackgroundThread
{
    [crewForView loadVideosInBackgroundWithBlockOrNil:nil startingAtIndex:0 forVideoCount:([videoTableView numberOfRowsInSection:0] <= 10) ? 10 : [videoTableView numberOfRowsInSection:0]];
}

- (void) loadOldVideosOnBackgroundThread
{
    [crewForView loadVideosInBackgroundWithBlockOrNil:nil startingAtIndex:[videoTableView numberOfRowsInSection:0] forVideoCount:10];
}

- (void) startingToLoadVideos
{
    [noVideosLabel setText:@"Loading videos..."];
}

- (void) finishedLoadingVideosWithSuccess:(BOOL)successful andError:(NSError *)error
{
    if ([[crewForView ccVideos] count] == 0)
    {
        [noVideosLabel setText:@"No videos yet!"];
    }
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

- (void) addedOldVideosAtIndexes:oldVideoIndexes
{
    [videoTableView stopLoading];


    [videoTableView beginUpdates];
    
    [videoTableView insertRowsAtIndexPaths:oldVideoIndexes withRowAnimation:UITableViewRowAnimationFade]; 
        
    
    [videoTableView endUpdates]; 
    
    [videoTableView performSelector:@selector(pushViewDown) withObject:nil afterDelay:0.5];
}

- (void)viewDidUnload
{
    [self setVideoTableView:nil];
    [self setNoVideosLabel:nil];
    
    [crewForView removeCrewUpdateListener:self];
    
    [self setTopBarView:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    
    [cell initializeWithVideo:videoForCell andNavigationController:[self navigationController]];
    
    if ( indexPath.row + 1 == [videoTableView numberOfRowsInSection:0] && [[crewForView ccVideos] count] >= 10  && [crewForView getNumberOfVideos] > [videoTableView numberOfRowsInSection:0])
    {
        [videoTableView addPullToRefreshFooter];
    }
    else 
        [videoTableView setDelegate:nil];
    
    return cell;
}

- (IBAction)onLeaveButtonPressed:(id)sender 
{
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle: @"Leave Crew" message: @"Are you sure you want to leave? You will be missed!" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles:@"Leave", nil];
    {
        [updateAlert show];
    }
}    
 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (buttonIndex==1)
   {
       [[[[CCCoreManager sharedInstance] server] currentUser] removeUserFromCrew:crewForView WithBlockOrNil:^(BOOL succeeded, NSError *error) {
           if (succeeded)
               [[self navigationController] popViewControllerAnimated:YES];
           else 
           {
               if (error)
                   [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error uploading video: %@", [error localizedDescription]];
               
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh..." 
                                                               message:@"Error leaving the crew.  Try again later." 
                                                              delegate:self 
                                                     cancelButtonTitle:@"Close"
                                                     otherButtonTitles: nil];
               [alert show];
           }
       }];
   }
}

- (void) CCCleanUpTableNotificationReceived:(NSNotification *)CCTableCleanUpNotification
{
    if ( [[crewForView ccVideos] count] == 0)
    {
        [videoTableView reloadData];
        [videoTableView setHidden:YES];
        [noVideosLabel setHidden:NO];
    }
    
    [crewForView removeCrewUpdateListener:self];
}

- (void) CCReloadCrewNotificationReceived:(NSNotification *)CCReloadCrewNotification
{
    [self setCrewForView:[[[[CCCoreManager sharedInstance] server] currentUser] getCrewFromObjectID:[crewForView getObjectID]]];
    [crewForView addCrewUpdateListener:self];
    [self reloadVideosOnBackgroundThread];
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
@end
