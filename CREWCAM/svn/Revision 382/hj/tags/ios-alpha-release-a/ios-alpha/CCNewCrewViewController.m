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
    if (passedCrew != nil) 
    {
        NSString *titleString = [[NSString alloc] initWithFormat:@"Invite to \"%@\"", [passedCrew name]];
        [crewNavigationBar setTitle:titleString];
        [crewNameField setAlpha:0];
    }    
	[[[CCCoreManager sharedInstance] server] startLoadingFacebookFriendsWithDelegate:self];
}

- (void)viewDidUnload
{
    [self setLoadingFriendsIndicator:nil];
    [self setFriendsTableView:nil];
    [self setCrewNameField:nil];
    [self setCrewNavigationBar:nil];
    [self setCrewNavigationBar:nil];
    [self setNoFriendsLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Required CCServerLoadFacebookFriendsDelegate methods

- (void)successfullyLoadedFacebookFriends:(NSArray *)facebookFriends
{
    [loadingFriendsIndicator stopAnimating];
    
    if (passedCrew != nil)
    {
        friendsArray = [passedCrew getFriendsNotInCrewFromList:facebookFriends];
    }
    else 
    {
        friendsArray = facebookFriends;   
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

- (void)failedLoadingFacebookFriendsWithReason:(NSString *)reason
{
    
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
        [[[CCCoreManager sharedInstance] server] addNewCrewWithName:[crewNameField text] useNewThread:YES delegateOrNil:self];
    }
    else 
    {
        //Crew is old and being edited
        [self addFriendsToCrew:passedCrew];
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

- (void)successfullyAddedCrew:(id<CCCrew>)crew
{
    [self addFriendsToCrew:crew];
}

- (void)failedAddingCrewWithReason:(NSString *)reason
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to add crew: %@", reason];
}

- (void)addFriendsToCrew:(id<CCCrew>)crew
{
    for(int friendIndex = 0; friendIndex < [friendsArray count]; friendIndex++)
    {
        UITableViewCell *cellForCrew = [friendsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:friendIndex inSection:0]];
        
        if ([cellForCrew accessoryType] == UITableViewCellAccessoryCheckmark)
        {       
            [(id<CCUser>)[friendsArray objectAtIndex:friendIndex] inviteToCrew:crew useNewThread:NO];
        }            
    }
}

- (IBAction)hideKeyboad:(id)sender {
    [[self crewNameField] resignFirstResponder];
}
@end
