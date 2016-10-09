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
@synthesize checkedIndexPaths;

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
    checkedIndexPaths = [[NSMutableSet alloc] init];
    [[[CCCoreManager sharedInstance] server] startLoadingFriendsWithBlock:^(NSArray *friends, NSError *error){
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Could not load facebook friends did not send push notification: %@", [error localizedDescription]];
        }
        else
        {
            [[[[CCCoreManager sharedInstance] server] currentUser] name];
            if(friends != nil)
            {
                for(int friendIndex = 0; friendIndex < [friends count]; friendIndex++)
                {
                    [(id<CCUser>)[friends objectAtIndex:friendIndex] sendNotificationWithMessage:[[NSString alloc] initWithFormat:@"Your friend %@ has joined Crewcam!", [[[[CCCoreManager sharedInstance] server] currentUser] name]]];
                }
            }
        }
    }];
    [[[CCCoreManager sharedInstance] server] startLoadingFriendsCrewsWithBlock:^(NSArray *friends, NSError *error){
        
        [loadingIndicator stopAnimating];
        if ([friends count] == 0)
        {
            // We will simply suggest the user adds a crew
            [nextStepDescription setText:@"You seem new here.  Would you like to add a crew?"];
            
            return;
        }
        
        [nextStepDescription setText:@"Join your friend's crews:"];
        [crewsTable setHidden:NO];
        
        [self setCrewsArray:friends];
        
        [crewsTable reloadData];
        
    }];
}

- (void)viewDidUnload
{
    [self setCrewsTable:nil];
    [self setNextStepDescription:nil];
    [self setLoadingIndicator:nil];
    [self setCheckedIndexPaths:nil];
    
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
    
    if([[self checkedIndexPaths] containsObject:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Add the checmark indicator for the cell
    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([[self checkedIndexPaths] containsObject:indexPath])
    {
        [[self checkedIndexPaths] removeObject:indexPath];
        thisCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        [[self checkedIndexPaths] addObject:indexPath];
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
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
        NSIndexPath *indexPathForCrew = [NSIndexPath indexPathForRow:currentCrew inSection:0];
        
        if ([[self checkedIndexPaths] containsObject:indexPathForCrew])
        {
            // Add the current user to this crew in the background
            [[crewsArray objectAtIndex:currentCrew] addMember:[[[CCCoreManager sharedInstance] server] currentUser]];
            [[crewsArray objectAtIndex:currentCrew] pushObjectWithBlockOrNil:nil];
        }            
    }
}

- (IBAction)onNextButtonPressed:(id)sender 
{
    [self addUserToSelectedGroups];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Required CCServerLoadFacebookFriendsDelegate methods


- (void)failedLoadingFacebookFriendsWithReason:(NSString *)reason
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Could not load facebook friends did not send push notification."];
}


@end
