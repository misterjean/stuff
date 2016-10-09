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
    
    [[[CCCoreManager sharedInstance] server] startLoadingFriendsCrewsWithDelegate:self];
}

- (void)viewDidUnload
{
    [self setCrewsTable:nil];
    [self setNextStepDescription:nil];
    [self setLoadingIndicator:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Required UITableViewDataSource and UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (crewsArray == nil)
        return 0;
    
    return [crewsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"joinCrewTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    id<CCCrew> crew = [crewsArray objectAtIndex:[indexPath row]];
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:100];
    label.text = [crew name];
    label = (UILabel *)[cell viewWithTag:101];
    label.text = [[NSString alloc] initWithFormat:@"%d members", [[crew members] count]];
    label = (UILabel *)[cell viewWithTag:102];
    label.text = [[NSString alloc] initWithFormat:@"%d videos", [[crew videos] count]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Add the checmark for the cell
    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (thisCell.accessoryType == UITableViewCellAccessoryNone)
    {
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else 
    {
        thisCell.accessoryType = UITableViewCellAccessoryNone;
    }
}

// Required CCFriendsLoadedDelegate methods

- (void)successfullyLoadedFriendsCrews:(NSArray *)crews
{
    [loadingIndicator stopAnimating];
    if ([crews count] == 0)
    {
        // We will simply suggest the user adds a crew
        [nextStepDescription setText:@"You seem new here.  Would you like to add a crew?"];
    
        return;
    }
    
    [nextStepDescription setText:@"Join your friend's crews:"];
    [crewsTable setHidden:NO];
    
    [self setCrewsArray:crews];
    
    [crewsTable reloadData];
}

- (void)failedLoadingFriendsCrewsWithReason:(NSString *)reason
{
    
}

- (void)addUserToSelectedGroups
{
    for(int currentCrew = 0; currentCrew < [crewsArray count]; currentCrew++)
    {
        UITableViewCell *cellForCrew = [crewsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentCrew inSection:0]];
//        UITableViewCell *cellForCrew = 
        
        if ([cellForCrew accessoryType] == UITableViewCellAccessoryCheckmark)
        {
            // Add the current user to this crew in the background
            [[crewsArray objectAtIndex:currentCrew] addMember:[[CCCoreManager sharedInstance] currentUser] useNewThread:YES];
        }            
    }
}

- (IBAction)onNextButtonPressed:(id)sender 
{
    [self addUserToSelectedGroups];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
