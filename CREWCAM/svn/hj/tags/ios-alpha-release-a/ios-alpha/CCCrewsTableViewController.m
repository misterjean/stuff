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
    [self reloadCrewsOnBackgroundThread];
    [super viewDidLoad];
}

- (void)reloadCrewsOnBackgroundThread
{    
    [reloadingCrewsIndicator setHidden:NO];

    // Delete all the objects
    [[[[CCCoreManager sharedInstance] currentUser] crews] removeAllObjects];
    
    // Clear the table (because there are no crews)
    [[self tableView] reloadData];
    
    // Reload
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{                 
        [[[CCCoreManager sharedInstance] currentUser] loadCrewsWithNewThread:NO];
        // Reload on background thread
        dispatch_async( dispatch_get_main_queue(), ^{
            // Update the GUI thread
            [reloadingCrewsIndicator setHidden:YES];
            if ([[[[CCCoreManager sharedInstance] currentUser] crews] count] != 0)
            {
                [[self tableView] setHidden:NO]; 
                [[self tableView] reloadData];
            }
        });
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [[self tableView] reloadData];
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
    return [[[[CCCoreManager sharedInstance] currentUser] crews] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"crewTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:100];
    label.text = [[[[[CCCoreManager sharedInstance] currentUser] crews] objectAtIndex:[indexPath row]] name];
    label = (UILabel *)[cell viewWithTag:101];
    label.text = [[NSString alloc] initWithFormat:@"%d members", [[[[[[CCCoreManager sharedInstance] currentUser] crews] objectAtIndex:[indexPath row]] members] count]];
    label = (UILabel *)[cell viewWithTag:102];
    label.text = [[NSString alloc] initWithFormat:@"%d videos", [[[[[[CCCoreManager sharedInstance] currentUser] crews] objectAtIndex:[indexPath row]] videos] count]];
    
    return cell;
}

// UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self loadViewForCrew:[[[[CCCoreManager sharedInstance] currentUser] crews] objectAtIndex:[indexPath row]]];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self loadViewForCrew:[[[[CCCoreManager sharedInstance] currentUser] crews] objectAtIndex:[indexPath row]]];    
}

#warning implement - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender


- (IBAction)onRefreshButtonPressed:(id)sender 
{
    [self reloadCrewsOnBackgroundThread];    
}
@end
