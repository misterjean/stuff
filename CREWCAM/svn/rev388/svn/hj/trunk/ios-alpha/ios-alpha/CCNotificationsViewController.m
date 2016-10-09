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
@synthesize globalActivityView;
@synthesize notificationsTableView;
@synthesize noNotificationsLabel;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotificationsTab:) name:CC_RELOAD_NOTIFICATIONS_TAB object:nil];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
}

- (void) reloadNotificationsTab: (id) sender
{
    [self viewDidAppear:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setUIElementsBasedOnInvites];
    [[[[CCCoreManager sharedInstance] server] currentUser] loadNotificationsInBackgroundWithBlockOrNil:nil];
}

- (void)viewDidUnload
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setNotificationsTableView:nil];
    [self setGlobalActivityView:nil];
    [self setNoNotificationsLabel:nil];
    [super viewDidUnload];

    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserUpdateListener:self];
}

- (void) setUIElementsBasedOnInvites
{
    [globalActivityView setHidden:YES];
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] count] == 0)
        [noNotificationsLabel setHidden:NO];
    else
        [noNotificationsLabel setHidden:YES];
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
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] count] == 0)
        return;
    
    [globalActivityView setHidden:NO];
    [[[[CCCoreManager sharedInstance] server] currentUser] clearAllNotificationsInBackground];
}
@end
