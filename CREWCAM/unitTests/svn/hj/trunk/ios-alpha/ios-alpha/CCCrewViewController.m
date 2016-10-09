//
//  CCVideoViewController.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewViewController.h"
#import "CCVideoTableViewCell.h"

@interface CCCrewViewController ()

@end

@implementation CCCrewViewController
@synthesize videoTableView;
@synthesize crewForView;
@synthesize sortedVideoList;
@synthesize noVideosLabel;
@synthesize publicPrivateCrewLabel;
@synthesize loadingActivityIndicator;
@synthesize crewBusyView;


- (void) refreshTableOnPullUp
{
    [self loadOldVideosOnBackgroundThread];
}

- (IBAction)onBackButtonPressed:(id)sender 
{
    [crewForView removeCrewUpdateListener:self];
    
    if ([crewForView oldVideosLoaded])
    {
        NSDictionary *kissMetricDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInt:[crewForView numberOfOldVideos]],  CC_NUMBER_OF_OLD_VIDEOS_LOADED,
                                              nil];
        
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_LOADED_OLD_VIDEOS withProperties:kissMetricDictionary];
        
        [crewForView setOldVideosLoaded:NO];
        [crewForView setNumberOfOldVideos:0];
        
        [[crewForView ccVideos] removeObjectsInRange:NSMakeRange(10, [[crewForView ccVideos] count] - 10)];
        [videoTableView reloadData];
    }

    if (self == [[[self navigationController] viewControllers] objectAtIndex:0])
    {
        [[self navigationController] dismissModalViewControllerAnimated:YES];
    }
    else 
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    
    for (id<CCVideo> video in [crewForView ccVideos])
    {
        [video clearThumbnail];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [crewForView addCrewUpdateListener:self];
    
    if ([crewForView getSecuritySetting] == CCPublic)
    {
        [publicPrivateCrewLabel setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Public_ACT" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else
    {
        [publicPrivateCrewLabel setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Private_ACT" ofType:@"png"]] forState:UIControlStateNormal];
    }
    
    [videoTableView setDataSource:self];
    [videoTableView setDelegate:self];
    [videoTableView setTableDelegate:self];
    
    [self reloadVideosOnBackgroundThread];
    
    if ([[crewForView ccVideos] count] > 0)
    {
        [noVideosLabel setHidden:YES];
        [loadingActivityIndicator setHidden:YES];
        [videoTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [videoTableView setScrollEnabled:YES];
    }    
    else if ([crewForView getNumberOfVideos] > 0)
    {
        [loadingActivityIndicator setHidden:NO];
        [noVideosLabel setText:@"Loading..."];
    }
    
    [self setTitle:[crewForView getName]];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CCReloadCrewNotificationReceived:) name:@"ReloadCrewNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationItem] setRightBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Leave" target:self action:@selector(onLeaveButtonPressed:)]];
    
    [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)]];
    
    [videoTableView reloadData];
}


-(void) initWithCrew:(id<CCCrew>)crew
{
    [self setCrewForView:crew];
    [self setTitle:[crew getName]];
}

- (void)reloadVideosOnBackgroundThread
{
    [crewForView reloadVideosInBackgroundWithBlockOrNil:nil];
}

- (void) loadOldVideosOnBackgroundThread
{
    [crewForView loadVideosInBackgroundWithBlockOrNil:nil startingAtIndex:[videoTableView numberOfRowsInSection:0] forVideoCount:10];
}

- (void) startingToLoadVideos
{
    if ([videoTableView numberOfRowsInSection:0] == 0)
    {
        [loadingActivityIndicator setHidden:NO];
        [noVideosLabel setText:@"Loading..."];
    }
}

- (void) finishedLoadingVideosWithSuccess:(BOOL)successful andError:(NSError *)error
{
    [loadingActivityIndicator setHidden:YES];
    if ([[crewForView ccVideos] count] == 0)
    {
        [noVideosLabel setText:@"No videos yet!"];
    }
}

- (void) addedNewVideosAtIndexes:(NSArray *) newVideoIndexes andRemovedVideosAtIndexes:(NSArray *) deletedVideoIndexes
{
    [loadingActivityIndicator setHidden:YES];
    [noVideosLabel setHidden:YES];
    
    [videoTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [videoTableView setScrollEnabled:YES];
    
    [videoTableView beginUpdates];

    [videoTableView deleteRowsAtIndexPaths:deletedVideoIndexes withRowAnimation:UITableViewRowAnimationRight];
    [videoTableView insertRowsAtIndexPaths:newVideoIndexes withRowAnimation:UITableViewRowAnimationFade];            
    
    [videoTableView endUpdates];
}

- (void) addedOldVideosAtIndexes:(NSArray *) oldVideoIndexes
{
    [videoTableView stopLoading];
    
    [crewForView setOldVideosLoaded:YES];
    
    if ([oldVideoIndexes count] > 0)
    {
        [videoTableView beginUpdates];
        
        [videoTableView insertRowsAtIndexPaths:oldVideoIndexes withRowAnimation:UITableViewRowAnimationLeft];         
        
        [videoTableView endUpdates]; 
        
        [videoTableView performSelector:@selector(pushViewDown) withObject:nil afterDelay:0.5];
    }
    
}

- (void)viewDidUnload
{    
    [crewForView removeCrewUpdateListener:self];    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setVideoTableView:nil];
    [self setNoVideosLabel:nil];
    [self setCrewBusyView:nil];
    [self setSortedVideoList:nil];
    [self setLoadingActivityIndicator:nil];
    [self setPublicPrivateCrewLabel:nil];
    [super viewDidUnload];
    
    if ([[self navigationController] topViewController] == self)
    {
        [self viewDidLoad];
    }
    else 
    {
        [self setCrewForView:nil];
    }
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
    
    [cell initializeWithVideo:videoForCell andNavigationController:self];
    
    if (indexPath.row + 1 == ([videoTableView numberOfRowsInSection:0])
        && [[crewForView ccVideos] count] >= 10
        && [crewForView getNumberOfVideos] > ([videoTableView numberOfRowsInSection:0])
        && ![crewForView isUploadInProgress])
    {
        [videoTableView addPullToRefreshFooterToSection:0 withOffset:82];
    }
    else 
        [videoTableView setDelegate:nil];
    
    return cell;
}

- (IBAction)onLeaveButtonPressed:(id)sender 
{
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedStringFromTable(@"LEAVE_CREW", @"Localizable", nil) 
                                                          message: NSLocalizedStringFromTable(@"LEAVING_CREW_CONFIRMATION", @"Localizable", nil) 
                                                         delegate: self 
                                                    cancelButtonTitle: @"Cancel" 
                                                    otherButtonTitles:@"Leave", nil];
    {
        [updateAlert show];
    }
}    
 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (buttonIndex==1)
   {
       [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
       [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
       [crewBusyView setHidden:NO];
       
       [[[[CCCoreManager sharedInstance] server] currentUser] removeUserFromCrew:crewForView WithBlockOrNil:^(BOOL succeeded, NSError *error) {
           
           [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
           [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
           [crewBusyView setHidden:YES];
           
           if (succeeded)
           {
               if (self == [[[self navigationController] viewControllers] objectAtIndex:0])
               {
                   [[self navigationController] dismissModalViewControllerAnimated:YES];
               }
               else
               {
                   [[self navigationController] popViewControllerAnimated:YES];
               }
           }
           else 
           {
               if (error)
                   [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error uploading video: %@", [error localizedDescription]];
               
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ERROR_LEAVING_TITLE",@"Localizable", nil) 
                                                               message:NSLocalizedStringFromTable(@"ERROR_LEAVING_TEXT",@"Localizable", nil) 
                                                              delegate:self 
                                                     cancelButtonTitle:@"Close"
                                                     otherButtonTitles: nil];
               [alert show];
           }
       }];
   }
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
        CCInviteViewController *vc = [segue destinationViewController];
        [vc setStoredNavigationController:[self navigationController]];
        [vc setPassedCrew:crewForView];
    }
    else if ([[segue identifier] isEqualToString:@"membersListPush"])
    {
        CCCrewMembersViewController *crewMembersView = [segue destinationViewController];
        [crewMembersView setCrewForView:crewForView];
    }
}
@end
