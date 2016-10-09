//
//  CCInvitesViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCInvitesViewController.h"

@interface CCInvitesViewController ()

@end

@implementation CCInvitesViewController
@synthesize noInvitesLabel;
@synthesize loadingInvitesIndicator;
@synthesize navigationBar;
@synthesize invitesTable;

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
    
    if ([[UIScreen mainScreen] scale] == 0x40000000)
    {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
        [navigationBar setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    else 
    {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] count] == 0)
    {
        [loadingInvitesIndicator setHidden:NO];
        [noInvitesLabel setHidden:NO];
        [noInvitesLabel setText:@"Loading invites..."];   
    }
    else 
    {
        [noInvitesLabel setHidden:YES];
        [loadingInvitesIndicator setHidden:YES];
        [invitesTable setHidden:NO];
    }
    
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] loadInvitesInBackgroundWithBlockOrNil:nil];
}

- (void) setUIElementsBasedOnInvites
{        
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] count] > 0)
    {
        [noInvitesLabel setHidden:YES];
        [invitesTable setHidden:NO];
    }
    else 
    {
        [invitesTable setHidden:YES];
        [noInvitesLabel setHidden:NO];
        [noInvitesLabel setText:@"No invites yet."];
    }
    
    [loadingInvitesIndicator setHidden:YES];
}

- (void) finishedReloadingAllInvitesWithSucces:(BOOL) successful andError:(NSError *) error
{
    [self setUIElementsBasedOnInvites];
}

- (void) addedNewInvitesAtIndexes:(NSArray *) addedInviteIndexes andRemovedInvitesAtIndexes:(NSArray *)removedInviteIndexes
{
    [self setUIElementsBasedOnInvites];
    
    [invitesTable beginUpdates];
    
    [invitesTable deleteRowsAtIndexPaths:removedInviteIndexes withRowAnimation:UITableViewRowAnimationRight];
    [invitesTable insertRowsAtIndexPaths:addedInviteIndexes withRowAnimation:UITableViewRowAnimationLeft];
    
    [invitesTable endUpdates];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Required UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"inviteTableCell";
    CCInviteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CCInviteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    id<CCInvite> thisInvite = [[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] objectAtIndex:[indexPath row]];
    
    [cell setInviteForCell:thisInvite];
    
    return cell;
}

- (void)viewDidUnload 
{    
    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserUpdateListener:self];
    
    [self setInvitesTable:nil];
    [self setNoInvitesLabel:nil];
    [self setLoadingInvitesIndicator:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
}

@end
