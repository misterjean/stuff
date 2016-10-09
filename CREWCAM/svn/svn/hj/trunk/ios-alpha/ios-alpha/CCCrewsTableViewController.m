
//
//  CCCrewViewController.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewsTableViewController.h"

@interface CCCrewsTableViewController ()

@end

@implementation CCCrewsTableViewController
@synthesize reloadingCrewsIndicator;

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    [self reloadCrewsOnBackgroundThread];
}

- (void)reloadCrewsOnBackgroundThread
{    
    [reloadingCrewsIndicator setHidden:NO];    
    
    // Delete all the objects
    [[[[[CCCoreManager sharedInstance] server] currentUser] crews] removeAllObjects];
    
    // Clear the table (because there are no crews)
    [[self tableView] reloadData];
    
    [[[CCCoreManager sharedInstance] server] startReloadingTheCurrentUsersCrewsWithDelegateOrNil:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];   
}

- (void)viewDidUnload
{
    [self setReloadingCrewsIndicator:nil];

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadViewForCrew:(id<CCCrew>) crew
{        
    CCCrewViewController *crewView = [self.storyboard instantiateViewControllerWithIdentifier:@"crewFeedView"];
    
    [crewView setCrewForView:crew];
    
    [self.navigationController pushViewController:crewView animated:YES];
}

// UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[[CCCoreManager sharedInstance] server] currentUser] crews] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"crewTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:100];
    label.text = [[[[[[CCCoreManager sharedInstance] server] currentUser] crews] objectAtIndex:[indexPath row]] name];
    label = (UILabel *)[cell viewWithTag:101];
    label.text = [[NSString alloc] initWithFormat:@"%d members", [[[[[[[CCCoreManager sharedInstance] server] currentUser] crews] objectAtIndex:[indexPath row]] members] count]];
    label = (UILabel *)[cell viewWithTag:102];
    label.text = [[NSString alloc] initWithFormat:@"%d videos", [[[[[[[CCCoreManager sharedInstance] server] currentUser] crews] objectAtIndex:[indexPath row]] videos] count]];
    
    return cell;
}

// UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self loadViewForCrew:[[[[[CCCoreManager sharedInstance] server] currentUser] crews] objectAtIndex:[indexPath row]]];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self loadViewForCrew:[[[[[CCCoreManager sharedInstance] server] currentUser] crews] objectAtIndex:[indexPath row]]];    
}

- (IBAction)onRefreshButtonPressed:(id)sender 
{
    [self reloadCrewsOnBackgroundThread];    
}

// CCCoreObjectsDelegate methods
- (void)successfullyRefreshedCurrentUser
{
    // Ingore for now
}

- (void)startingToRefreshCurrentUser
{
    // Ingore for now    
}

- (void)failedRefreshingCurrentUserWithReason:(NSString *)reason
{
    // Ingore for now 
}

- (void)successfullyRefreshedUsersCrews
{
    [reloadingCrewsIndicator setHidden:YES];
    
    [[self tableView] reloadData];
}

- (void)startingToRefreshUsersCrews
{
    [reloadingCrewsIndicator setHidden:NO];
    
    // Clear the table (because there are no crews)
    [[self tableView] reloadData];
}

- (void)failedRefreshingUsersCrewsWithReason:(NSString *)reason
{
    
}

@end
