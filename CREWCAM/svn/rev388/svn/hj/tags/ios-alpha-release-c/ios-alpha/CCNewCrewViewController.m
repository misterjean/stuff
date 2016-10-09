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
@synthesize crewcamButton;
@synthesize facebookButton;
@synthesize contactsButton;
@synthesize searchBar;
@synthesize activityLabel;
@synthesize crewNameField;
@synthesize crewNavigationBar;
@synthesize loadingFriendsIndicator;
@synthesize peopleThatAreFriends;
@synthesize friendsTableView;
@synthesize passedCrew;
@synthesize publicPrivateSelecor;
@synthesize optionsBackgroundView;
@synthesize postingCrewOverlay;
@synthesize selectedPeople;
@synthesize finishedButton;

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
    
    optionsBackgroundView.layer.shadowRadius = 10;
    optionsBackgroundView.layer.shadowOpacity = 1;
    isSearching = NO;
    isPublicCrew = NO;
    selectedPeople = [[NSMutableArray alloc] init];
    
    for (UIView *subview in searchBar.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }   
    
    [[[self navigationController] navigationBar] setOpaque:YES];
    [[[self navigationController] navigationBar] setClipsToBounds:NO];    
    if ([[UIScreen mainScreen] scale] == 0x40000000)
    {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
        [[[self navigationController] navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    else 
    {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }   
    
    if (passedCrew != nil) 
    {        
        NSString *titleString = [[NSString alloc] initWithFormat:@"Invite to \"%@\"", [passedCrew getName]];
        [crewNavigationBar setTitle:titleString];
        [crewNameField setAlpha:0];
        [publicPrivateSelecor setHidden:YES];
        
        [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)]];
    }
    
    [[self navigationItem] setRightBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Done" target:self action:@selector(onDoneButtonPressed:)]];
    
    filteredListContent = [[NSMutableArray alloc] init];
    
    // Change the cancel button to say "Done"
    for(UIView *subView in searchBar.subviews) {        
        if([subView isKindOfClass:UIButton.class])
        {
            [(UIButton*)subView setTitle:@"Done" forState:UIControlStateNormal];
            break;
        }        
    }
    
    searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:searchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;

    selectedPeople = [[NSMutableArray alloc] init];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [selectedPeople removeAllObjects];
    [selectedCrewcamFriends removeAllObjects];
    [selectedFacebookFriends removeAllObjects];
    [selectedAddressBookFriends removeAllObjects];
    
    [crewNameField setText:@""];
    
    crewcamFriends = nil; 
    
    [crewcamButton setSelected:YES];
    [facebookButton setSelected:NO];
    [contactsButton setSelected:NO];

    [self disableButins];
    [self reloadTableWithCrewcamFriends];
    
    if (passedCrew)
        [finishedButton setTitle:@"Done"];
    else 
        [finishedButton setTitle:@"Create"];
}

- (void)viewDidUnload
{
    [self setLoadingFriendsIndicator:nil];
    [self setFriendsTableView:nil];
    [self setCrewNameField:nil];
    [self setCrewNavigationBar:nil];
    [self setCrewNavigationBar:nil];
    [self setActivityLabel:nil];
    selectedPeople = nil;
    [self setPublicPrivateSelecor:nil];
    [self setOptionsBackgroundView:nil];
    [self setSearchBar:nil];
    [self setFinishedButton:nil];
    [self setCrewcamButton:nil];
    [self setFacebookButton:nil];
    [self setContactsButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Searching
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    /*
     Update the filtered array based on the search text and scope.
     */
    
    [filteredListContent removeAllObjects]; // First clear the filtered array.
    /*
     Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
     */
    for (CCBasePerson *person in peopleThatAreFriends)
    {
        NSString *nameToMatch = [[NSString alloc] initWithFormat:@"%@ %@", [person getFirstName], [person getLastName]];
        NSComparisonResult result = [nameToMatch compare:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        // Is the first/whole name a match?
        if (result == NSOrderedSame)
        {
            [filteredListContent addObject:person];
            continue;
        } 
        
        // Otherwise, try the last name
        result = [[person getLastName] compare:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if (result == NSOrderedSame)
        {
            [filteredListContent addObject:person];
        }            
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    isSearching = YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    // Change the "Cancel" button to "Done"
    for(UIView *subView in searchBar.subviews){
        if([subView isKindOfClass:UIButton.class])
        {
            [((UIButton*) subView) setTitle:@"Done" forState:UIControlStateNormal];
            break;
        }
    }
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [friendsTableView reloadData];
    isSearching = NO;
}

// Required UITableViewDataSource and UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (peopleThatAreFriends == nil)
        return 0;
    
    if (tableView != friendsTableView)
    {
        return [filteredListContent count];
    }
    if (friendsTableView == [[self searchDisplayController] searchResultsTableView])
    {
        return [filteredListContent count];
    }
    
    return [peopleThatAreFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CCBasePerson *personForCell;
    if (tableView != friendsTableView)
    {
        personForCell = [filteredListContent objectAtIndex:[indexPath row]];
    }
    else 
    {
        personForCell = [peopleThatAreFriends objectAtIndex:[indexPath row]];
    }

    UILabel *label;
    label = (UILabel *)[cell viewWithTag:0];
    label.text =  [[NSString alloc] initWithFormat:@"%@ %@", [personForCell getFirstName], [personForCell getLastName]];
    
    if([[self selectedPeople] containsObject:personForCell])
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
    
    CCBasePerson *selectedPerson;
    if (tableView != friendsTableView)
    {
         selectedPerson = [filteredListContent objectAtIndex:[indexPath row]];
    }
    else 
    {
        selectedPerson = [peopleThatAreFriends objectAtIndex:[indexPath row]];
    }
    
    if([[self selectedPeople] containsObject:selectedPerson])
    {
        [[self selectedPeople] removeObject:selectedPerson];
        thisCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        [[self selectedPeople] addObject:selectedPerson];
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}


- (IBAction)onBackButtonPressed:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}
         
- (IBAction)onDoneButtonPressed:(id)sender 
{
    // Save whatever is currently selected
    if ([crewcamButton isSelected])
    {
        selectedCrewcamFriends = [[NSMutableArray alloc] initWithArray:selectedPeople];
    }
    else if ([facebookButton isSelected]) 
    {
        selectedFacebookFriends = [[NSMutableArray alloc] initWithArray:selectedPeople];
    }
    else if ([contactsButton isSelected])
    {
        selectedAddressBookFriends = [[NSMutableArray alloc] initWithArray:selectedPeople];
    }

    if(passedCrew == nil)
    {
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
             
        [postingCrewOverlay setHidden:NO];
        CCSecuritySetting securitySetting = CCPrivate;
        if (isPublicCrew)
        {
            securitySetting = CCPublic;
        }
        
        [[[CCCoreManager sharedInstance] server] addNewCrewWithName:[crewNameField text] privacy:securitySetting withBlock:^(id<CCCrew> crew, BOOL succeeded, NSError *error) 
        {      
            [postingCrewOverlay setHidden:YES];
            
            if (error)
            {
                UIAlertView *alert;  
                
                alert = [[UIAlertView alloc] initWithTitle:@"Crew creation failed!" 
                                                   message:[error localizedDescription]
                                                  delegate:nil 
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                [self inviteFriendsToCrew:crew];
                
                [self hideViewController];
            }
            
        }];
        
    }
    else 
    {
        //Crew is old and being edited
        [self inviteFriendsToCrew:passedCrew];
        
        [self hideViewController];
    }
}

- (void) hideViewController
{
    if([[[self navigationController] viewControllers] indexOfObject:self] == 0)
    {
        [[self tabBarController] setSelectedIndex:MY_CREWS_TAB_BAR_INDEX];         
    }
    else 
    {
      [[self navigationController] popViewControllerAnimated:YES]; 
    }
}
    

- (void)inviteFriendsToCrew:(id<CCCrew>)crew
{
    if ([selectedCrewcamFriends count] > 0)
    {
        for (CCBasePerson *person in selectedCrewcamFriends)
        {
            [[[CCCoreManager sharedInstance] server] addNewInviteToCrewInBackground:crew forUser:[person ccUser]];
        }
    }    
    if ([selectedFacebookFriends count] > 0)
    {
        [[[CCCoreManager sharedInstance] server] inviteCCFacebookPersons:selectedFacebookFriends toCrew:crew];
    }
    
    if ([selectedAddressBookFriends count] > 0)
    {
        [[[CCCoreManager sharedInstance] server] inviteCCAddressBookPeople:selectedAddressBookFriends toCrew:crew displayMessageOnView:[self parentViewController]];
    }
}

- (IBAction)hideKeyboad:(id)sender 
{
    [[self crewNameField] resignFirstResponder];
}

- (IBAction)backgroundTouched:(id)sender {
    [searchBar resignFirstResponder];
    [crewNameField resignFirstResponder];
    [searchController setActive:NO];
}

- (IBAction)onPrivatePublicButtonPress:(id)sender {
    // Flip the bit
    isPublicCrew = !isPublicCrew;
    
    if (isPublicCrew)
    {
        [publicPrivateSelecor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Public_ACT" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else 
    {
        [publicPrivateSelecor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Private_ACT" ofType:@"png"]] forState:UIControlStateNormal];
    }
}

- (void) handleNewFriendOptionSelected
{
    [self disableButins];
    
    [friendsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];    
    [searchController setActive:NO];
    
    if ([crewcamButton isSelected])
    {
        selectedCrewcamFriends = [[NSMutableArray alloc] initWithArray:selectedPeople];
        crewcamFriends = [[NSMutableArray alloc] initWithArray:peopleThatAreFriends];
        [crewcamButton setSelected:NO];
    }
    else if ([facebookButton isSelected]) 
    {
        selectedFacebookFriends = [[NSMutableArray alloc] initWithArray:selectedPeople];
        facebookFriends = [[NSMutableArray alloc] initWithArray:peopleThatAreFriends];
        [facebookButton setSelected:NO];
    }
    else if ([contactsButton isSelected])
    {
        selectedAddressBookFriends = [[NSMutableArray alloc] initWithArray:selectedPeople];
        addressBookFriends = [[NSMutableArray alloc] initWithArray:peopleThatAreFriends];
        [contactsButton setSelected:NO];
    }
}

- (IBAction)onContactsSelected:(id)sender {
    UIAlertView *alert;  
    
    alert = [[UIAlertView alloc] initWithTitle:@"Coming Soon!" 
                                       message:@"Inviting contacts will be supported in Crewcam's release next week!"
                                      delegate:nil 
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil];
    [alert show];
    return;
    
    [self handleNewFriendOptionSelected];
    
    [((UIButton *)sender) setSelected:YES];
    
    if (selectedAddressBookFriends != nil)
    {
        selectedPeople = selectedAddressBookFriends;
    }
    [self reloadTableWithAddressBook];
}

- (IBAction)onFacebookSelected:(id)sender {
    UIAlertView *alert;  
    
    alert = [[UIAlertView alloc] initWithTitle:@"Coming Soon!" 
                                       message:@"Inviting Facebook friends will be supported in Crewcam's release next week!"
                                      delegate:nil 
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil];
    [alert show];
    return;
    [self handleNewFriendOptionSelected];
    
    [((UIButton *)sender) setSelected:YES];
    
    if (selectedFacebookFriends != nil)
    {
        selectedPeople = selectedFacebookFriends;
    }
    [self reloadTableWithFacebookFriends];
}

- (IBAction)onCrewcamSelected:(id)sender {    
    [self handleNewFriendOptionSelected];
    
    [((UIButton *)sender) setSelected:YES];
    
    if (selectedCrewcamFriends != nil)
    {
        selectedPeople = selectedCrewcamFriends;
    }
    [self reloadTableWithCrewcamFriends];
}

- (void) startReload
{
    [activityLabel setHidden:NO];
    [activityLabel setText:@"Loading..."];
    [loadingFriendsIndicator setHidden:NO];
    [friendsTableView setHidden:YES];
}

- (void) loadTableWithNewPeople:(NSArray *) people
{
    if (passedCrew != nil)
    {
        [passedCrew loadInvitesInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            [passedCrew loadMembersInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                peopleThatAreFriends = [passedCrew getFriendsNotInCrewFromList:people];                
                if ([peopleThatAreFriends count] == 0)
                {
                    [activityLabel setHidden:NO];
                    [activityLabel setText:@"Unable to find any friends."];
                }
                else
                {
                    [activityLabel setHidden:YES];
                    [friendsTableView setHidden:NO];
                }
                
                [loadingFriendsIndicator setHidden:YES];
                [friendsTableView reloadData];
                
                [self enableButins];
            }];
        }];
    }
    else 
    {
        peopleThatAreFriends = people;        
        
        if ([peopleThatAreFriends count] == 0)
        {
            [activityLabel setHidden:NO];
            [activityLabel setText:@"Unable to find any friends."];
        }
        else
        {
            [activityLabel setHidden:YES];
            [friendsTableView setHidden:NO];
        }
        [loadingFriendsIndicator setHidden:YES];
        [friendsTableView reloadData];
        
        [self enableButins];
    }
}

- (void) reloadTableWithCrewcamFriends
{   
    [self startReload]; 
    if (crewcamFriends != nil)
    {
        [self loadTableWithNewPeople:crewcamFriends];        
        return;
    }
    
    [[[CCCoreManager sharedInstance] friendManager] loadCrewcamFriendsInBackgroundWithBlock:^(NSArray *friends, NSError *error)
     {
         if (!error)
         {
             [self loadTableWithNewPeople:friends];
         }
         else 
         {
             UIAlertView *alert;  
             
             alert = [[UIAlertView alloc] initWithTitle:@"Unable to load Crewcam friends!" 
                                                message:[error localizedDescription] 
                                               delegate:nil 
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil];
             [alert show];
         }
     }];
}

- (void) reloadTableWithFacebookFriends
{
    [self startReload];
    if (facebookFriends != nil)
    {
        [self loadTableWithNewPeople:facebookFriends];
        return;
    }

    [[[CCCoreManager sharedInstance] friendManager] loadFacebookFriendPeopleInBackgroundWithBlock:^(NSArray *friends, NSError *error) 
    {
        if (!error)
        {
            [self loadTableWithNewPeople:friends];
        }
        else 
        {
            UIAlertView *alert;  
            
            alert = [[UIAlertView alloc] initWithTitle:@"Unable to load Facebook friends!" 
                                               message:[error localizedDescription] 
                                              delegate:nil 
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
            [alert show];
        }       
    }];
}

- (void) reloadTableWithAddressBook
{
    [self startReload];
    if (addressBookFriends != nil)
    {
        [self loadTableWithNewPeople:addressBookFriends];
        return;
    }

    [[[CCCoreManager sharedInstance] friendManager] loadContactListPeopleInBackgroundWithBlock:^(NSArray *friends, NSError *error) 
     {
         if (!error)
         {
             [self loadTableWithNewPeople:friends];             
         }
         else 
         {
             UIAlertView *alert;  
             
             alert = [[UIAlertView alloc] initWithTitle:@"Unable to load contacts!" 
                                                message:[error localizedDescription] 
                                               delegate:nil 
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil];
             [alert show];
         }       
     }];
}

- (void) disableButins
{
    [crewcamButton setEnabled:NO];
    [facebookButton setEnabled:NO];
    [contactsButton setEnabled:NO];
}

- (void) enableButins
{
    [crewcamButton setEnabled:YES];
    [facebookButton setEnabled:YES];
    [contactsButton setEnabled:YES];
}

@end
