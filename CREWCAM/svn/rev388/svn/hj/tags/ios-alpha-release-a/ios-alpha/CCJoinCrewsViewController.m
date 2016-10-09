//
//  CCJoinCrewsViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCJoinCrewsViewController.h"

@interface CCJoinCrewsViewController ()

@end

@implementation CCJoinCrewsViewController

@synthesize crewsArray;
@synthesize crewsTable;
@synthesize loadingCrewsIndicator;

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
    [self setLoadingCrewsIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    [self setCrewsArray:crews];
//    crewsForView = crews;
    [loadingCrewsIndicator stopAnimating];
    
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
    
    CCTempViewController *recordVideoView = [self.storyboard instantiateViewControllerWithIdentifier:@"recordVideoView"];
    
    [self.navigationController pushViewController:recordVideoView animated:YES];
}

@end
