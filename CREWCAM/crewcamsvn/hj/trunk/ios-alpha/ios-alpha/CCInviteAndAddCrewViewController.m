//
//  CCNewCrewViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCInviteAndAddCrewViewController.h"

@interface CCInviteAndAddCrewViewController ()

@end

#define CC_REAUTHORIZE_REQUEST 1

@implementation CCInviteAndAddCrewViewController
@synthesize crewcamButton;
@synthesize facebookButton;
@synthesize contactsButton;
@synthesize activityLabel;
@synthesize crewNameField;
@synthesize privatePublicHelpButton;
@synthesize peopleThatAreFriends;
@synthesize friendsTableView;
@synthesize passedCrew;
@synthesize publicPrivateSelecor;
@synthesize searchBarBackground;
@synthesize postingCrewOverlay;
@synthesize searchStringField;
@synthesize storedNavigationController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    searchBarBackground.layer.cornerRadius = 4;           
    
    [searchStringField addTarget:self action:@selector(searchFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)];
    
    [searchStringField setDelegate:self];
    [searchStringField setFont:[UIFont getSteelfishFontForSize:20]];
    
    selectedCrewcamFriends = [[NSMutableArray alloc] init];
    selectedFacebookFriends = [[NSMutableArray alloc] init];
    selectedAddressBookFriends = [[NSMutableArray alloc] init];
    filteredListContent = [[NSMutableArray alloc] init];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField != searchStringField)
        return;
    
    if ([searchStringField.text isEqualToString:@"SEARCH"])
        [searchStringField setText:@""];    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField != searchStringField)
        return YES;
    
    [searchStringField resignFirstResponder];
    
    [self filterContentForSearchText:(@"")];
    
    [friendsTableView reloadData];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField != searchStringField)
        return;
    
    if ([searchStringField.text isEqualToString:@""])
        [searchStringField setText:@"SEARCH"];
    
    isSearching = NO;
}

- (void) searchFieldChanged
{
    isSearching = YES;
    
    [self filterContentForSearchText:[searchStringField text]];
    
    [friendsTableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    isSearching = NO;
    isPublicCrew = NO;
    
    selectedPeople = selectedCrewcamFriends;
    
    searchStringField.text = @"SEARCH";
    [searchStringField resignFirstResponder];
    
    crewcamFriends = nil;
    [selectedCrewcamFriends removeAllObjects];
    [selectedFacebookFriends removeAllObjects];
    [selectedAddressBookFriends removeAllObjects];
    [filteredListContent removeAllObjects];
    
    [crewNameField setText:@""];
    
    [crewcamButton setSelected:YES];
    [facebookButton setSelected:NO];
    [contactsButton setSelected:NO];

    [self disableButins];
    [self reloadTableWithCrewcamFriends];
    
    if (noFriendsPopover)
        [noFriendsPopover dismiss];
    
    if (passedCrew)
    {
        [crewNameField setHidden:YES];
        [privatePublicHelpButton setHidden:YES];
        [[self view] addCrewcamTitleToViewController:@"Invite"];
        [[self publicPrivateSelecor] setHidden:YES];
        [searchStringField setFrame:CGRectMake(searchStringField.frame.origin.x, searchStringField.frame.origin.y, 211, searchStringField.frame.size.height)];
        [searchBarBackground setFrame:CGRectMake(searchBarBackground.frame.origin.x, searchBarBackground.frame.origin.y, 219, searchBarBackground.frame.size.height)];
    }
    else
    {
        [privatePublicHelpButton setHidden:NO];
        [publicPrivateSelecor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Private" ofType:@"png"]] forState:UIControlStateNormal];
        [publicPrivateSelecor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Private_ACT" ofType:@"png"]] forState:UIControlStateHighlighted];
        
        [crewNameField setFont:[UIFont getSteelfishFontForSize:35]];
        [crewNameField becomeFirstResponder];
        [searchStringField setFrame:CGRectMake(searchStringField.frame.origin.x, searchStringField.frame.origin.y, 150, searchStringField.frame.size.height)];
        [searchBarBackground setFrame:CGRectMake(searchBarBackground.frame.origin.x, searchBarBackground.frame.origin.y, 158, searchBarBackground.frame.size.height)];
    }
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
    
    noFriendsPopover = nil;
    
    [self setPeopleThatAreFriends:nil];
    [self setFriendsTableView:nil];
    [self setCrewNameField:nil];
    [self setActivityLabel:nil];
    [self setPublicPrivateSelecor:nil];
    [self setPrivatePublicHelpButton:nil];
    [self setPostingCrewOverlay:nil];
    [self setStoredNavigationController:nil];
    [self setPassedCrew:nil];
    [self setCrewcamButton:nil];
    [self setFacebookButton:nil];
    [self setContactsButton:nil];    
    [self setSearchStringField:nil];
    [self setSearchBarBackground:nil];
    [self setPrivatePublicHelpButton:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Searching
- (void)filterContentForSearchText:(NSString*)searchText
{
    [filteredListContent removeAllObjects];
    
    if (!searchText || [searchText isEqualToString:@""])
    {
        [filteredListContent addObjectsFromArray:peopleThatAreFriends];
        return;
    }
    
    for (CCBasePerson *person in peopleThatAreFriends)
    {
        NSString *nameToMatch = [[NSString alloc] initWithFormat:@"%@ %@", [person getFirstName], [person getLastName]];
        NSComparisonResult result = [nameToMatch compare:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if (result == NSOrderedSame)
        {
            [filteredListContent addObject:person];
            continue;
        } 
        
        result = [[person getLastName] compare:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if (result == NSOrderedSame)
        {
            [filteredListContent addObject:person];
        }            
    }
}

- (NSInteger) numberOfRowsForArray:(NSArray *) array
{
    return ([array count] / 3) + (([array count] % 3) > 0 ? 1 : 0);
}

// Required UITableViewDataSource and UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (peopleThatAreFriends == nil)
        return 0;
    
    if (isSearching)
    {        
        return [self numberOfRowsForArray:filteredListContent];
    }
    
    return [self numberOfRowsForArray:peopleThatAreFriends];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendTableCell";
    CCPeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[CCPeopleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSMutableArray *peopleForRow = [[NSMutableArray alloc] init];
    NSMutableArray *isSelectedBoolsForRow = [[NSMutableArray alloc] init];
    
    int startingPersonIndex = ([indexPath row] * 3);
    for(int personIndex = startingPersonIndex; personIndex < (isSearching ? [filteredListContent count] : [peopleThatAreFriends count]) && personIndex < (startingPersonIndex + 3); personIndex++)
    {
        CCBasePerson *personForCell = (isSearching ? [filteredListContent objectAtIndex:personIndex] : [peopleThatAreFriends objectAtIndex:personIndex]);
                
        [peopleForRow addObject:personForCell];
        
        [isSelectedBoolsForRow addObject:[NSNumber numberWithBool:([selectedPeople containsObject:personForCell])]];        
    }
    
    [cell setForPeople:peopleForRow areIconsSelectable:YES andArePeopleSelectedBools:isSelectedBoolsForRow arePeopleRequestable:NO];
    
    [cell setDelegate:self];
    
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

- (void) didSelectPerson:(CCBasePerson *)person forView:(UIView *)personView
{
    if (passedCrew)
    {
        if ([passedCrew getCrewtype] == CCFBSchool || [passedCrew getCrewtype] == CCFBWork || [passedCrew getCrewtype] == CCFBLocation)
        {
            if ([person ccUser])
            {
                if ([[NSString stringWithFormat: CC_MINIMUM_VERSION_FOR_AUTO_CREW_INVITE] compare:[[person ccUser] getUserRevision] options:NSNumericSearch] == NSOrderedDescending)
                {
                    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Version Error" message:@"Selected user needs to update Crewcam to support this crew type.  Tell them to update!" withTextField:NO delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    
                    [alert show];
                    
                    [(CCPersonIconView *)personView setSelected:NO];
                    
                    return;
                }
            }
            else if ([[NSString stringWithFormat: CC_MINIMUM_VERSION_FOR_AUTO_CREW_INVITE] compare:[[[CCCoreManager sharedInstance] server] globalSettings].currentAppStoreRevisionString options:NSNumericSearch] == NSOrderedDescending)
            {
                CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Version Error" message:@"You are running a pre-release version of Crewcam and the currently released version doesn't support this feature.  You'll have to wait till this version goes live!" withTextField:NO delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
                
                [(CCPersonIconView *)personView setSelected:NO];
                
                return;
            }
        }
    }
    
    if (![crewcamButton isSelected] && ![self isCurrentUserAllowedToInviteMorePeople])
    {
        NSString *alertMessage = [[NSString alloc] initWithFormat:@"Sadly, access to Crewcam is currently limited.  You only have %d invites left and you've already selected that many people!",
                                  [[[[[CCCoreManager sharedInstance] server] currentUser] getNumberOfInvitesLeft] intValue]];
        
        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Invite limit breached!"
                                                                      message:alertMessage
                                                                withTextField:NO
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Darn."
                                                            otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if (![selectedPeople containsObject:person])
        [selectedPeople addObject:person];
}

- (void) didUnselectPerson:(CCBasePerson *) person forView:(UIView *)personView
{ 
    if ([selectedPeople containsObject:person])
        [selectedPeople removeObject:person];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];        
}

- (void) hideView
{
    if ([self navigationController])
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else{
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)onBackButtonPressed:(id)sender
{
    [self hideView];
}
         
- (IBAction)onDoneButtonPressed:(id)sender 
{
    if(passedCrew == nil)
    {
        if ([[crewNameField text] isEqualToString:@""])
        {
            CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Oops..."
                                                                          message:@"You forgot to give your Crew a name!"
                                                                    withTextField:NO
                                                                         delegate:nil
                                                                cancelButtonTitle:nil
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
#warning check if this is a new user and their first crew... if so trigger main view to have a dialog that prompts the user to post a video
            [postingCrewOverlay setHidden:YES];
            
            if (error)
            {
                CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Crew creation failed!"
                                                                              message:[error localizedDescription]
                                                                        withTextField:NO
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
            [self hideView];
        }];
    }
    else
    {
        [self hideView];
    }
}

- (IBAction)hideKeyboad:(id)sender 
{
    [searchStringField resignFirstResponder];
    [[self crewNameField] resignFirstResponder];
}

- (IBAction)backgroundTouched:(id)sender {
    [searchStringField resignFirstResponder];
    [crewNameField resignFirstResponder];
}

- (IBAction)onPrivatePublicHelpPressed:(id)sender {
    
    CCCrewcamAlertView *alert= [[CCCrewcamAlertView alloc] initWithTitle:@"Help" message:@"A private (locked) crew requires that friends be invited to join. A public (unlocked) crew can be joined by friends from the 'Join' tab." withTextField:NO  delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    
    [alert show];    
}

- (IBAction)onPrivatePublicButtonPress:(id)sender {
    // Flip the bit
    isPublicCrew = !isPublicCrew;
    
    if (isPublicCrew)
    {
        [publicPrivateSelecor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Public" ofType:@"png"]] forState:UIControlStateNormal];
        [publicPrivateSelecor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Public_ACT" ofType:@"png"]] forState:UIControlStateHighlighted];
    }
    else 
    {
        [publicPrivateSelecor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Private" ofType:@"png"]] forState:UIControlStateNormal];
        [publicPrivateSelecor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Private_ACT" ofType:@"png"]] forState:UIControlStateHighlighted];
    }
}

- (void) handleNewFriendOptionSelected
{
    [self disableButins];
    
    [searchStringField setText:@"SEARCH"];
    [searchStringField resignFirstResponder];
    
    [friendsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
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
    if ([((UIButton *)sender) isSelected])
        return;
    
    [self handleNewFriendOptionSelected];
    
    [((UIButton *)sender) setSelected:YES];
    
    selectedPeople = selectedAddressBookFriends;
    
    [friendsTableView setUserInteractionEnabled:YES];

    [self reloadTableWithAddressBook];
}

- (IBAction)onFacebookSelected:(id)sender {
    if ([((UIButton *)sender) isSelected])
        return;
    
    [self handleNewFriendOptionSelected];
    
    [((UIButton *)sender) setSelected:YES];

    selectedPeople = selectedFacebookFriends;
    
    [friendsTableView setUserInteractionEnabled:YES];
    
    [self reloadTableWithFacebookFriends];
}

- (IBAction)onCrewcamSelected:(id)sender {    
    if ([((UIButton *)sender) isSelected])
        return;
    
    [self handleNewFriendOptionSelected];
    
    [((UIButton *)sender) setSelected:YES];
    
    selectedPeople = selectedCrewcamFriends;
    
    [friendsTableView setUserInteractionEnabled:YES];
    
    [self reloadTableWithCrewcamFriends];
}

- (void) startReload
{
    [activityLabel setHidden:NO];
    [activityLabel setText:@"LOADING..."];
    [friendsTableView setHidden:YES];
}

- (void) loadTableWithNewPeople:(NSArray *) people
{    
    peopleThatAreFriends = people;
    
    if ([peopleThatAreFriends count] == 0)
    {
        if ([[[[CCCoreManager sharedInstance] server] currentUser] isUserNewlyActivated] && [people count] == 0 && !noFriendsPopover)
        {
            noFriendsPopover = [[CCTutorialPopover alloc] initWithMessage:@"Couldn't find any friends!  Use \"add friends\" in the settings tab." pointsDirection:ccTutorialPopoverDirectionNone withTargetPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 40) andParentView:self.view];
            
            [noFriendsPopover show];
            
            [activityLabel setText:@""];
        }
        else
        {
            [activityLabel setHidden:NO];
            
            NSString *noFriendsMessage = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_NO_CREWCAM_FRIENDS_KEY withDefault:@"COULDN'T FIND ANY FRIENDS."];
            
            [activityLabel setText:noFriendsMessage];
        }
    }
    else
    {
        [activityLabel setHidden:YES];
        [friendsTableView setHidden:NO];
    }
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
    
    [[[CCCoreManager sharedInstance] friendManager] addFacebookFriendsAndContactsWhoAreUsingCrewcamWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                __block NSArray *ccFriends = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends];
                __block NSMutableArray *basePeopleFriends = [[NSMutableArray alloc] initWithCapacity:[ccFriends count]];
                
                for(id<CCUser> user in ccFriends)
                {
                    [basePeopleFriends addObject:[[CCBasePerson alloc] initWithCCUser:user]];
                }                                
                
                if (passedCrew != nil)
                {
                    [passedCrew loadInvitesInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                        [passedCrew loadMembersInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            ccFriends = [passedCrew getFriendsNotInCrewFromList:ccFriends];
                            NSMutableArray *basePeopleFriends = [[NSMutableArray alloc] initWithCapacity:[ccFriends count]];
                            for(id<CCUser> user in ccFriends)
                            {
                                [basePeopleFriends addObject:[[CCBasePerson alloc] initWithCCUser:user]];
                            }
                            crewcamFriends = basePeopleFriends;
                            [self loadTableWithNewPeople:crewcamFriends];
                        }];
                    }];
                }
                else
                {
                    crewcamFriends = basePeopleFriends;
                    [self loadTableWithNewPeople:basePeopleFriends];
                }
            }
            else
            {
                CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Unable to load Crewcam friends!"
                                                                              message:[error localizedDescription]
                                                                        withTextField:NO
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"Ok"
                                                                    otherButtonTitles:nil];
                [alert show];
            }
        }];
    }];
}

- (void) reloadTableWithFacebookFriends
{
    if (![[[[CCCoreManager sharedInstance] server] currentUser] getFacebookUserWallPostPermission])
    {
        NSString* warningText = [[NSString alloc] initWithFormat:@"You have not enabled the required Facebook permissions. Log out of the app and enable the \"Post on your behalf\" permission to invite friends from Facebook."];
        
        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Authorize" message:warningText withTextField:NO delegate:self cancelButtonTitle:nil otherButtonTitles:@"Logout", nil];
        
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
            CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Unable to load Facebook friends!"
                                                                          message:[error localizedDescription]
                                                                    withTextField:NO
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
             CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Unable to load contacts!"
                                                                           message:[error localizedDescription]
                                                                     withTextField:NO
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"Ok"
                                                                 otherButtonTitles:nil];
             [alert show];
         }       
     }];
}

- (void) disableButins
{
    [crewcamButton setUserInteractionEnabled:NO];
    [facebookButton setUserInteractionEnabled:NO];
    [contactsButton setUserInteractionEnabled:NO];
}

- (void) enableButins
{
    [crewcamButton setUserInteractionEnabled:YES];
    [facebookButton setUserInteractionEnabled:YES];
    [contactsButton setUserInteractionEnabled:YES];
}

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == CC_REAUTHORIZE_REQUEST)
    {
        if (buttonIndex == 1)
        {
            [[[CCCoreManager sharedInstance] server] logOutCurrentUserInBackground];
            UINavigationController *localyStoredNC = [self storedNavigationController];
            [self hideView];
            [localyStoredNC dismissViewControllerAnimated:NO completion:^{
                
            }];
        }

    }
}

@end
