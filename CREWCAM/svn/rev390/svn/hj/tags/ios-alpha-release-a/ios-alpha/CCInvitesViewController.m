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
@synthesize invitesTable;
@synthesize invitesTabItem;

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
    
    [self reloadInvites];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self reloadInvites];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Required UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[CCCoreManager sharedInstance] currentUser] ccInvites] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"inviteTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id<CCInvite> thisInvite = [[[[CCCoreManager sharedInstance] currentUser] ccInvites] objectAtIndex:[indexPath row]];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:0];
    label.text = [[thisInvite crewInvitedTo] name];
    label = (UILabel *)[cell viewWithTag:1];
    NSString * nameString = [[NSString alloc] initWithFormat:@"Invited by %@", [[thisInvite userInvitedBy] name]];
    label.text = nameString;
    
    return cell;
}

// Required UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<CCInvite> thisInvite = [[[[CCCoreManager sharedInstance] currentUser] ccInvites] objectAtIndex:[indexPath row]];
    
    // Add the user to the crew
    [[thisInvite crewInvitedTo] addMember:[[CCCoreManager sharedInstance] currentUser] useNewThread:NO];
    
    // Update the crew
    [[thisInvite crewInvitedTo] pushObjectWithNewThread:YES delegateOrNil:nil];
    
    // Update the invite
    [thisInvite deleteObjectWithNewThread:YES];
    
    // Add the crew to the user locally
    [[[[CCCoreManager sharedInstance] currentUser] crews] addObject:[thisInvite crewInvitedTo]];
    
    // Remove the invite from the list
    [[[[CCCoreManager sharedInstance] currentUser] ccInvites] removeObjectAtIndex:[indexPath row]];
    
    [invitesTable reloadData];
}

- (void)viewDidUnload 
{
    [self setInvitesTable:nil];
    [self setInvitesTabItem:nil];
    [self setNoInvitesLabel:nil];
    [self setLoadingInvitesIndicator:nil];
    [super viewDidUnload];
}
- (void)reloadInvites
{
    [loadingInvitesIndicator setHidden:NO];

    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Reload on background thread
        [[[CCCoreManager sharedInstance] currentUser] loadInvitesWithNewThread:NO];
        dispatch_async( dispatch_get_main_queue(), ^{
            // Update the GUI thread
            [loadingInvitesIndicator setHidden:YES];
            if ([[[[CCCoreManager sharedInstance] currentUser] ccInvites] count] == 0)
            {
                [noInvitesLabel setHidden:NO];
                [invitesTable setHidden:YES];
            }
            else 
            {
                [noInvitesLabel setHidden:YES];
                [invitesTable setHidden:NO];
                [invitesTable reloadData];
            }  
        });
    });
}

- (IBAction)onRefreshButtonPressed:(id)sender 
{
    [self reloadInvites];
}
@end
