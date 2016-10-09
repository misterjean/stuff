//
//  CCJoinCrewsViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCJoinViewController.h"

@interface CCJoinViewController ()

@end

@implementation CCJoinViewController

@synthesize crewsArray;
@synthesize crewsTable;
@synthesize nextStepDescription;
@synthesize isNewUser;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] addCrewcamTitleToViewController:@"JOIN"];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#warning stupid stupid
//    if (isNewUser)
//    {        
//        [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {            
//             if (error)
//             {
//                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Could not load facebook friends did not send push notification: %@", [error localizedDescription]];
//             }
//             else
//             {
//                 for(id<CCUser> friend in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends])
//                 {
//                     [friend sendNotificationWithMessage:[[NSString alloc] initWithFormat:@"Your friend %@ has joined Crewcam!", [[[[CCCoreManager sharedInstance] server] currentUser] getName]]];
//                 }
//             }
//         }];  
//    }
    
    [nextStepDescription setText:@"LOADING..."];
    
    [[[CCCoreManager sharedInstance] friendManager] loadFriendsPublicCrewsInBackgroundWithBlock:^(NSArray *ccCrews, NSError *error)
     {        
         
         if ([ccCrews count] == 0)
         {
             // We will simply suggest the user adds a crew
             [nextStepDescription setText:@"NO PUBLIC CREWS."];
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
    
    [cell setCrewForCell:crew andViewController:self];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CCFriendCrewTableViewCell *cell = (CCFriendCrewTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    [cell setUserInteractionEnabled:NO];
    
    [cell setCrewSelected:YES];
    // Add the current user to this crew in the background
    [tableView setUserInteractionEnabled:NO];
    
    [[crewsArray objectAtIndex:indexPath.row] addMemberInBackground:[[[CCCoreManager sharedInstance] server] currentUser] withBlockOrNil:^(BOOL succeeded, NSError *error) {
        
        [cell setUserInteractionEnabled:YES];
        
        [tableView setUserInteractionEnabled:YES];
        
        if (succeeded)
        {
            [(NSMutableArray*)crewsArray removeObjectAtIndex:indexPath.row];
            
            if ([crewsArray count] == 0)
            {
                // We will simply suggest the user adds a crew
                [nextStepDescription setText:@"NO PUBLIC CREWS."];
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
                [nextStepDescription setText:@"NO PUBLIC CREWS."];
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
