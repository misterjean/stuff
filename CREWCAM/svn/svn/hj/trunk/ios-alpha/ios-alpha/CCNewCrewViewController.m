//
//  CCNewCrewViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNewCrewViewController.h"

@interface CCNewCrewViewController ()

@end

@implementation CCNewCrewViewController
@synthesize noFriendsLabel;
@synthesize crewNameField;
@synthesize crewNavigationBar;
@synthesize loadingFriendsIndicator;
@synthesize friendsArray;
@synthesize friendsTableView;
@synthesize passedCrew;
@synthesize checkedIndexPaths;
@synthesize publicPrivateSelecor;

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
#warning This view is also used for inviting members to an existing crew... name should be changed
    if (passedCrew != nil) 
    {
        //not a new crew adding... members
        NSString *titleString = [[NSString alloc] initWithFormat:@"Invite to \"%@\"", [passedCrew name]];
        [crewNavigationBar setTitle:titleString];
        [crewNameField setAlpha:0];
        [publicPrivateSelecor setSelectedSegmentIndex:[passedCrew securitySetting]];
        [publicPrivateSelecor setEnabled:NO];
    }    
    checkedIndexPaths = [[NSMutableSet alloc] init];
	[[[CCCoreManager sharedInstance] server] startLoadingFriendsWithBlock:^(NSArray *friends, NSError *error){
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crews from Facebook friends: %@", [error localizedDescription]];
        }
        else
        {
            [loadingFriendsIndicator stopAnimating];
            
            if (passedCrew != nil)
            {
                friendsArray = [passedCrew getFriendsNotInCrewFromList:friends];
            }
            else 
            {
                friendsArray = friends;   
            }
            
            if ([friendsArray count] == 0)
            {
                [noFriendsLabel setHidden:NO];
            }
            else
            {
                [friendsTableView setHidden:NO];
            }
            
            [friendsTableView reloadData];
        }
    }];
}

- (void)viewDidUnload
{
    [self setLoadingFriendsIndicator:nil];
    [self setFriendsTableView:nil];
    [self setCrewNameField:nil];
    [self setCrewNavigationBar:nil];
    [self setCrewNavigationBar:nil];
    [self setNoFriendsLabel:nil];
    [self setCheckedIndexPaths:nil];
    [self setPublicPrivateSelecor:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Required UITableViewDataSource and UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (friendsArray == nil)
        return 0;
    
    return [friendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:0];
    label.text = [(id<CCUser>)[friendsArray objectAtIndex:[indexPath row]] name];
    
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
    
    // Add the checkmark indicator for the cell
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

- (IBAction)onCancelButtonPressed:(id)sender 
{
    if([[[self navigationController] viewControllers] indexOfObject:self] == 0)
    {
        [[self navigationController] dismissViewControllerAnimated:YES completion:nil]; 
    }
    else 
    {
         [[self navigationController] popViewControllerAnimated:YES];   
    }
}

- (IBAction)onDoneButtonPressed:(id)sender 
{
    
    if(passedCrew == nil)
    {
        //Crew is new create it
        if ([[crewNameField text] isEqualToString:@""])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops..." 
                                                            message:@"You forgot to give your Crew a name!" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"My bad"
                                                  otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        // Add it to the user "locally" right away        
        [[[CCCoreManager sharedInstance] server] addNewCrewWithName:[crewNameField text] privacy:[publicPrivateSelecor selectedSegmentIndex] withBlock:^(id<CCCrew> crew, BOOL succeeded, NSError *error) {
            
            if (error)
            {
#warning Handle this                  
            }
            else
            {
                [self inviteFriendsToCrew:crew];
            }
            
        }];
        
    }
    else 
    {
        //Crew is old and being edited
        [self inviteFriendsToCrew:passedCrew];
    }

            
    if([[[self navigationController] viewControllers] indexOfObject:self] == 0)
    {
        [[self navigationController] dismissViewControllerAnimated:YES completion:nil]; 
    }
    else 
    {
        [[self navigationController] popViewControllerAnimated:YES];   
    }
}

- (void)inviteFriendsToCrew:(id<CCCrew>)crew
{
    for(int friendIndex = 0; friendIndex < [friendsArray count]; friendIndex++)
    {
        NSIndexPath *indexPathForFriends = [NSIndexPath indexPathForRow:friendIndex inSection:0];
        
        if ([[self checkedIndexPaths] containsObject:indexPathForFriends])
        {       
            [(id<CCUser>)[friendsArray objectAtIndex:friendIndex] inviteToCrew:crew useNewThread:NO];
            [[CCCoreManager sharedInstance] recordMetricEvent:@"Invited friend" withProperties:nil];
        }            
    }
}

- (IBAction)hideKeyboad:(id)sender 
{
    [[self crewNameField] resignFirstResponder];
}
@end
