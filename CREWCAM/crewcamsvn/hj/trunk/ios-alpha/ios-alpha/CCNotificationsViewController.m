//
//  CCNotificationsViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNotificationsViewController.h"
#import "CCNotificationTableViewCell.h"

@interface CCNotificationsViewController ()

@end

@implementation CCNotificationsViewController
@synthesize globalActivityView;
@synthesize notificationsTableView;
@synthesize noNotificationsLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] addCrewcamTitleToViewController:@"MY FEED"];
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setNewlyViewedNotificationsAsViewed];
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_NOTIFICATIONS_VIEWED object:nil];
    [self setUIElementsBasedOnInvites];
    [notificationsTableView reloadData];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] loadNotificationsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        [self setNewlyViewedNotificationsAsViewed];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanupOldCrewViewControllers" object:nil userInfo:nil];
}

- (void)viewDidUnload
{   
    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserUpdateListener:self];
    
    [self setNotificationsTableView:nil];
    [self setGlobalActivityView:nil];
    [self setNoNotificationsLabel:nil];
    
    [super viewDidUnload];
}

- (void)setNewlyViewedNotificationsAsViewed
{
    for (int notificationIndex = 0; notificationIndex < [[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] count]; notificationIndex++)
    {
        if (![[[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] objectAtIndex:notificationIndex] getIsViewed])
        {
            [[[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] objectAtIndex:notificationIndex] setIsViewedWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed to push notification as viewed: %@", [error localizedDescription]];
                }
            }];
        }
    }
}

- (void) setUIElementsBasedOnInvites
{
    [globalActivityView setHidden:YES];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] count] == 0)
    {
        [noNotificationsLabel setText:@"NO NOTIFICATIONS."];
        [noNotificationsLabel setHidden:NO];
    }
    else
    {
        [noNotificationsLabel setHidden:YES];
    }
}

- (void) addedNewNotificationsAtIndexes:(NSArray *)addedNotificationIndexes andRemovedNotificationsAtIndexes:(NSArray *)removedNotificationIndexes
{
    [self setUIElementsBasedOnInvites];
    
    [notificationsTableView beginUpdates];
    
    [notificationsTableView deleteRowsAtIndexPaths:removedNotificationIndexes withRowAnimation:UITableViewRowAnimationRight];
    [notificationsTableView insertRowsAtIndexPaths:addedNotificationIndexes withRowAnimation:UITableViewRowAnimationLeft];
    
    [notificationsTableView endUpdates];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<CCNotification> notification = [[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] objectAtIndex:[indexPath row]];
        
    return [CCNotificationTableViewCell createNotificationCellForNotification:notification forTable:[self notificationsTableView] andViewController:self];
}

- (void)setAllNotificationsAsClicked
{
    for (int notificationIndex = 0; notificationIndex < [[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] count]; notificationIndex++)
    {
        if (![[[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] objectAtIndex:notificationIndex] getIsClicked])
        {
            [[[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] objectAtIndex:notificationIndex] setIsClickedWithBlock:^(BOOL succeeded, NSError *error) {
            }];
        }
    }
}

@end
