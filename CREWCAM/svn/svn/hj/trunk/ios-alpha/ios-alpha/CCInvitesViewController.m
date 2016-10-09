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
    return [[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"inviteTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id<CCInvite> thisInvite = [[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] objectAtIndex:[indexPath row]];
    
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
    
    id<CCInvite> thisInvite = [[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] objectAtIndex:[indexPath row]];
    
    if ([[thisInvite crewInvitedTo] containsMember:[[[CCCoreManager sharedInstance] server] currentUser]]) 
    {
        //User already memeber of crew.
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:@"User Already a member of Crew ignoring request."];
        
        // Update the invite
        [thisInvite deleteObjectWithBlockOrNil:nil];
    }
    else
    {
        // Add the user to the crew
        [[thisInvite crewInvitedTo] addMember:[[[CCCoreManager sharedInstance] server] currentUser]];
        
        [[CCCoreManager sharedInstance] recordMetricEvent:@"Joined crew" withProperties:nil];
        
        // Update the crew
        [[thisInvite crewInvitedTo] pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            // Update the invite
            [thisInvite deleteObjectWithBlockOrNil:nil];
            
            // Add the crew to the user locally
            [[[[[CCCoreManager sharedInstance] server] currentUser] crews] addObject:[thisInvite crewInvitedTo]];
        }];
    }
    
    // Remove the invite from the list
    [[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] removeObjectAtIndex:[indexPath row]];
    
    // Refresh the user's crews in the background
    [[[CCCoreManager sharedInstance] server] startReloadingTheCurrentUsersCrewsWithDelegateOrNil:nil];
    
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
        [[[[CCCoreManager sharedInstance] server] currentUser] loadInvitesWithNewThread:NO];
        dispatch_async( dispatch_get_main_queue(), ^{
            // Update the GUI thread
            [loadingInvitesIndicator setHidden:YES];
            if ([[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] count] == 0)
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
