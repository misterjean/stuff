//
//  CCNewCrewViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCInviteViewController.h"

@interface CCInviteViewController ()

@end

#define CC_REAUTHORIZE_REQUEST 1

@implementation CCInviteViewController
@synthesize crewcamButton;
@synthesize facebookButton;
@synthesize contactsButton;
@synthesize searchBar;
@synthesize activityLabel;
@synthesize crewNameField;
@synthesize navigationBar;
@synthesize navigationItem;
@synthesize loadingFriendsIndicator;
@synthesize peopleThatAreFriends;
@synthesize friendsTableView;
@synthesize passedCrew;
@synthesize publicPrivateSelecor;
@synthesize optionsBackgroundView;
@synthesize postingCrewOverlay;
@synthesize storedNavigationController;

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
    selectedCrewcamFriends = [[NSMutableArray alloc] init];
    selectedFacebookFriends = [[NSMutableArray alloc] init];
    selectedAddressBookFriends = [[NSMutableArray alloc] init];
    selectedPeople = selectedCrewcamFriends;
    
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
        [[self navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
        [[self navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    else 
    {
        [[self navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }   
    
    if (passedCrew != nil) 
    {        

        [crewNameField setAlpha:0];
        [publicPrivateSelecor setHidden:YES];
    }
    
    [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)]];
    
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
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [selectedCrewcamFriends removeAllObjects];
    [selectedFacebookFriends removeAllObjects];
    [selectedAddressBookFriends removeAllObjects];
    
    [crewNameField setText:@""];
    
    [crewcamButton setSelected:YES];
    [facebookButton setSelected:NO];
    [contactsButton setSelected:NO];

    [self disableButins];
    [self reloadTableWithCrewcamFriends];
    
    if (passedCrew)
        [navigationItem setTitle:@"Invite"];
}

- (void)viewDidUnload
{
    selectedFacebookFriends = nil;
    facebookFriends = nil;
    selectedAddressBookFriends = nil;
    addressBookFriends = nil;
    selectedCrewcamFriends = nil;
    crewcamFriends = nil;
    selectedPeople = nil;
    filteredListContent = nil;
    searchController = nil;
    
    [self setLoadingFriendsIndicator:nil];
    [self setPeopleThatAreFriends:nil];
    [self setFriendsTableView:nil];
    [self setCrewNameField:nil];
    [self setActivityLabel:nil];
    [self setPublicPrivateSelecor:nil];
    [self setOptionsBackgroundView:nil];
    [self setPostingCrewOverlay:nil];
    [self setSearchBar:nil];
    [self setStoredNavigationController:nil];
    [self setPassedCrew:nil];
    [self setCrewcamButton:nil];
    [self setFacebookButton:nil];
    [self setContactsButton:nil];
    [self setNavigationBar:nil];
    [self setNavigationItem:nil];
    
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
    
    if([selectedPeople containsObject:personForCell])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

// This function assumes we aren't currently selecting Crewcam people
- (BOOL) isCurrentUserAllowedToInviteMorePeople
{
    id<CCUser> currentUser = [[[CCCoreManager sharedInstance] server] currentUser];
    
    // Is the user under the invite limit?
    return (!(([selectedAddressBookFriends count] + [selectedFacebookFriends count]) >=
            [[currentUser getNumberOfInvitesLeft] intValue]) ||

    // Is the global setting "open"?
            [[[CCCoreManager sharedInstance] server] globalSettings].isOpenAccess ||

    // Is the user a developer?
            [currentUser isUserDeveloper]);
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
    
    if([selectedPeople containsObject:selectedPerson])
    {
        [selectedPeople removeObject:selectedPerson];
        thisCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        // Are we at our invite limit and not in "open access" mode and trying to invite a non-Crewcam person?
        if (![crewcamButton isSelected] && ![self isCurrentUserAllowedToInviteMorePeople])
        {
            NSString *alertMessage = [[NSString alloc] initWithFormat:@"Sadly, access to Crewcam is currently limited.  You only have %d invites left and you've already selected that many people!",
                                      [[[[[CCCoreManager sharedInstance] server] currentUser] getNumberOfInvitesLeft] intValue]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invite limit breached!"
                                                            message:alertMessage
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Darn."
                                                  otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        [selectedPeople addObject:selectedPerson];
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}


- (IBAction)onBackButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
         
- (IBAction)onDoneButtonPressed:(id)sender 
{
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
            }            
        }];
    }
    else 
    {
        //Crew is old and being edited
        [self inviteFriendsToCrew:passedCrew];
    }
}
    
- (void) updateCurrentUsersNumberOfInvitesLeft
{
    if ([[[CCCoreManager sharedInstance] server] globalSettings].isOpenAccess || [[[[CCCoreManager sharedInstance] server] currentUser] isUserDeveloper])
        return;
    
    int numberOfInvitesLeft = [[[[[CCCoreManager sharedInstance] server] currentUser] getNumberOfInvitesLeft] integerValue] -
    ([selectedAddressBookFriends count] + [selectedFacebookFriends count]);
    [[[[CCCoreManager sharedInstance] server] currentUser] setNumberOfInvites:[NSNumber numberWithInt:numberOfInvitesLeft]];
    [[[[CCCoreManager sharedInstance] server] currentUser] pushObjectWithBlockOrNil:nil];
}

- (void)inviteFriendsToCrew:(id<CCCrew>)crew
{
    [self updateCurrentUsersNumberOfInvitesLeft];
    
    if ([selectedCrewcamFriends count] > 0)
    {
        for (CCBasePerson *person in selectedCrewcamFriends)
        {
            [[[CCCoreManager sharedInstance] server] addNewInviteToCrewInBackground:crew forUser:[person ccUser] fromUser:[[[CCCoreManager sharedInstance] server] currentUser] withNotification:YES];
        }
    }    
    if ([selectedFacebookFriends count] > 0)
    {
        [[[CCCoreManager sharedInstance] server] inviteCCFacebookPersons:selectedFacebookFriends toCrew:crew];
    }
    
    if ([selectedAddressBookFriends count] > 0)
    {
        [[[CCCoreManager sharedInstance] server] inviteCCAddressBookPeople:selectedAddressBookFriends toCrew:crew displayMessageOnView:self withBlock:^(BOOL succeeded, NSError *error) {
            [self dismissModalViewControllerAnimated:YES];
        }];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
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
        [crewcamButton setSelected:NO];
    }
    else if ([facebookButton isSelected]) 
    {
        [facebookButton setSelected:NO];
    }
    else if ([contactsButton isSelected])
    {
        [contactsButton setSelected:NO];
    }
}

- (IBAction)onContactsSelected:(id)sender {
    [self handleNewFriendOptionSelected];
    
    [((UIButton *)sender) setSelected:YES];
    
    selectedPeople = selectedAddressBookFriends;
    
    [friendsTableView setUserInteractionEnabled:YES];

    [self reloadTableWithAddressBook];
}

- (IBAction)onFacebookSelected:(id)sender {
    [self handleNewFriendOptionSelected];
    
    [((UIButton *)sender) setSelected:YES];

    selectedPeople = selectedFacebookFriends;
    
    [friendsTableView setUserInteractionEnabled:YES];
    
    [self reloadTableWithFacebookFriends];
}

- (IBAction)onCrewcamSelected:(id)sender {    
    [self handleNewFriendOptionSelected];
    
    [((UIButton *)sender) setSelected:YES];
    
    selectedPeople = selectedCrewcamFriends;
    
    [friendsTableView setUserInteractionEnabled:YES];
    
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
    peopleThatAreFriends = people;
    
    if ([peopleThatAreFriends count] == 0)
    {
        [activityLabel setHidden:NO];
        NSString *noFriendsMessage = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_NO_CREWCAM_FRIENDS_KEY withDefault:@"No friends who aren't in the crew!"];
        [activityLabel setText:noFriendsMessage];
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

- (void) reloadTableWithCrewcamFriends
{
    if (crewcamFriends != nil)
    {
        [self loadTableWithNewPeople:crewcamFriends];
        return;
    }
    [self startReload]; 
    
    [[[CCCoreManager sharedInstance] friendManager] loadCrewcamFriendsInBackgroundWithBlock:^(NSArray *friends, NSError *error)
     {
         if (!error)
         {
             if (passedCrew != nil)
             {
                 [passedCrew loadInvitesInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                     [passedCrew loadMembersInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         crewcamFriends = [passedCrew getFriendsNotInCrewFromList:friends];
                         [self loadTableWithNewPeople:crewcamFriends];
                     }];
                 }];
             }
             else
             {
                 crewcamFriends = friends;
                 [self loadTableWithNewPeople:friends];
             }             
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
    if (![[[[CCCoreManager sharedInstance] server] currentUser] getFacebookUserWallPostPermission])
    {
        NSString* warningText = [[NSString alloc] initWithFormat:@"You have not enabled the required Facebook permissions. Log out of the app and enable the \"Post on your behalf\" permission to invite friends from Facebook."];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authorize" message:warningText delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
        
        [alert setTag:CC_REAUTHORIZE_REQUEST];
        
        [alert show];
        
        [friendsTableView setUserInteractionEnabled:NO];
    }
    
    if (facebookFriends != nil)
    {
        [self loadTableWithNewPeople:facebookFriends];
        return;
    }
        
    [self startReload];

    [[[CCCoreManager sharedInstance] friendManager] loadFacebookFriendPeopleInBackgroundWithBlock:^(NSArray *friends, NSError *error) 
    {
        if (!error)
        {
            facebookFriends = friends;
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
    if (addressBookFriends != nil)
    {
        [self loadTableWithNewPeople:addressBookFriends];
        return;
    }
    [self startReload];

    [[[CCCoreManager sharedInstance] friendManager] loadContactListPeopleInBackgroundWithBlock:^(NSArray *friends, NSError *error) 
     {
         if (!error)
         {
             addressBookFriends = friends;
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == CC_REAUTHORIZE_REQUEST)
    {
        if (buttonIndex == 1)
        {
            [[[CCCoreManager sharedInstance] server] logOutCurrentUserInBackground];
            UINavigationController *localyStoredNC = [self storedNavigationController];
            [self dismissModalViewControllerAnimated:NO];
            [localyStoredNC dismissViewControllerAnimated:NO completion:^{
                
            }];
        }

    }
}

@end
