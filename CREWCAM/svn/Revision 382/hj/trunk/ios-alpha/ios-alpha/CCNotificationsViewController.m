//
//  CCNotificationsViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNotificationsViewController.h"

@interface CCNotificationsViewController ()

@end

@implementation CCNotificationsViewController
@synthesize notificationsTableView;

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
    
    [[[self navigationController] navigationBar] setClipsToBounds:NO];
    [[[self navigationController] navigationBar] setOpaque:YES];   
    if ([[UIScreen mainScreen] scale] == 0x40000000)
    {        
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
        [[[self navigationController] navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    else 
    {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [[[[CCCoreManager sharedInstance] server] currentUser] loadNotificationsInBackgroundWithBlockOrNil:nil];
}

- (void)viewDidUnload
{
    [self setNotificationsTableView:nil];
    [super viewDidUnload];

    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserUpdateListener:self];
}

- (void) setUIElementsBasedOnInvites
{
    
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
        
    return [CCNotificationTableViewCell createNotificationCellForNotification:notification forTable:[self notificationsTableView] andViewController:[self navigationController]];
}

- (IBAction)clearAllButtonPressed:(id)sender {
    [[[[CCCoreManager sharedInstance] server] currentUser] clearAllNotificationsInBackground];
}
@end
