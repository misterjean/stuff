//
//  CCJoinCrewsViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCWelcomeViewController.h"

@interface CCWelcomeViewController ()

@end

@implementation CCWelcomeViewController

@synthesize crewsArray;
@synthesize crewsTable;
@synthesize nextStepDescription;
@synthesize loadingIndicator;
@synthesize textBackground;
@synthesize isNewUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[[self navigationController] navigationBar] setOpaque:YES];
    [[[self navigationController] navigationBar] setClipsToBounds:NO];
    
    if ([[UIScreen mainScreen] scale] == 0x40000000)
    {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
        [[[self navigationController] navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    else 
    {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }  
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isNewUser)
    {        
        [[[CCCoreManager sharedInstance] friendManager] loadCrewcamFriendsInBackgroundWithBlock:^(NSArray *ccFriends, NSError *error)
         {
             if (error)
             {
                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Could not load facebook friends did not send push notification: %@", [error localizedDescription]];
             }
             else
             {
                 [[[[CCCoreManager sharedInstance] server] currentUser] getName];
                 if(ccFriends != nil)
                 {
                     for(int friendIndex = 0; friendIndex < [ccFriends count]; friendIndex++)
                     {
                         [(id<CCUser>)[ccFriends objectAtIndex:friendIndex] sendNotificationWithMessage:[[NSString alloc] initWithFormat:@"Your friend %@ has joined Crewcam!", [[[[CCCoreManager sharedInstance] server] currentUser] getName]]];
                     }
                 }
             }
         }];  
    }
    
    if ([crewsArray count] < 1)
    {
        [loadingIndicator setHidden:NO];
    }
    
    [nextStepDescription setText:@"Loading friend's crews..."];
    
    [[[CCCoreManager sharedInstance] friendManager] loadFriendsPublicCrewsInBackgroundWithBlock:^(NSArray *ccCrews, NSError *error)
     {        
         [loadingIndicator setHidden:YES];
         
         if ([ccCrews count] == 0)
         {
             // We will simply suggest the user adds a crew
             [nextStepDescription setText:@"No public crews available."];
             [crewsTable setHidden:YES];
             return;
         }
         
         [nextStepDescription setHidden:YES];
         
         [crewsTable setHidden:NO];
         
         [self setCrewsArray:ccCrews];
         
         [crewsTable reloadData];
         
     }];
}

- (void)viewDidUnload
{
    [self setCrewsTable:nil];
    [self setNextStepDescription:nil];
    [self setLoadingIndicator:nil];
    [self setTextBackground:nil];
    [self setCrewsArray:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (crewsArray == nil)
        return 0;
    
    return [crewsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"joinCrewTableCell";
    CCFriendCrewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CCFriendCrewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    id<CCCrew> crew = [crewsArray objectAtIndex:[indexPath row]];
    
    [[cell crewNameLabel] setText:[crew getName]];
    [[cell crewMembersLabel] setText:[[NSString alloc] initWithFormat:@"%d members", [crew getNumberOfMembers]]];
    [[cell crewVideosLabel] setText:[[NSString alloc] initWithFormat:@"%d videos", [crew getNumberOfVideos]]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CCFriendCrewTableViewCell *cell = (CCFriendCrewTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    [[cell crewActivityIndicator] setHidden:NO];
    [cell setUserInteractionEnabled:NO];
    
    // Add the current user to this crew in the background
    [tableView setUserInteractionEnabled:NO];
    [[crewsArray objectAtIndex:indexPath.row] addMemberInBackground:[[[CCCoreManager sharedInstance] server] currentUser] withBlockOrNil:^(BOOL succeeded, NSError *error) {
        
        [[cell crewActivityIndicator] setHidden:YES];
        [cell setUserInteractionEnabled:YES];
        
        [tableView setUserInteractionEnabled:YES];
        
        if (succeeded)
        {
            [(NSMutableArray*)crewsArray removeObjectAtIndex:indexPath.row];
            
            if ([crewsArray count] == 0)
            {
                // We will simply suggest the user adds a crew
                [nextStepDescription setText:@"No public crews available."];
                [nextStepDescription setHidden:NO];                
                [crewsTable setHidden:YES];
                return;
            }
            
            [tableView beginUpdates];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
            [tableView endUpdates];
            
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_JOINED_PUBLIC_CREW withProperties:nil];
            
            if ( [crewsArray count] == 0)
            {
                [nextStepDescription setText:@"No public crews available."];
                [crewsTable setHidden:YES];
            }
        }
    }];
}

- (void)failedLoadingFacebookFriendsWithReason:(NSString *)reason
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Could not load facebook friends did not send push notification."];
}


@end
