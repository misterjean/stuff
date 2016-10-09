//
//  CCFriendFinderViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-10.
//
//

#import "CCFriendFinderViewController.h"

@interface CCFriendFinderViewController ()

@end

@implementation CCFriendFinderViewController
@synthesize friendsTableView;
@synthesize activityTextView;
@synthesize searchTextField;
@synthesize searchBarBackground;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [searchTextField becomeFirstResponder];
    
    [[self view] addCrewcamTitleToViewController:@"FRIEND FINDER"];
    
    searchBarBackground.layer.cornerRadius = 4;
    
    [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed)];
    
    [searchTextField addTarget:self action:@selector(searchFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    [searchTextField setDelegate:self];
    
    [friendsTableView setDelegate:self];
    
    isSearchQueued = NO;
    
    friendFinder = [[CCParseFriendFinder alloc] init];
    
    [friendFinder addDelegate:self];
}

- (void)viewDidUnload
{
    ccFriends = nil;
    friendFinder = nil;
    selectedPerson = nil;
    
    firstTimePopover = nil;
    
    [self setSearchTextField:nil];
    [self setSearchBarBackground:nil];
    [self setFriendsTableView:nil];
    [self setActivityTextView:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([[[[CCCoreManager sharedInstance] server] currentUser] isUserNewlyActivated])
    {
        [activityTextView setText:@""];
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[[[CCCoreManager sharedInstance] server] currentUser] isUserNewlyActivated])
    {
        firstTimePopover = [[CCTutorialPopover alloc] initWithMessage:@"Start typing a name or email to search for your friends!" pointsDirection:ccTutorialPopoverDirectionUp withTargetPoint:CGPointMake(searchBarBackground.frame.origin.x + searchBarBackground.frame.size.width/2, searchBarBackground.frame.origin.y + searchBarBackground.frame.size.height) andParentView:self.view];
        
        [firstTimePopover show];
    }
}

- (void) onBackButtonPressed
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField != searchTextField)
        return;        
    
    if ([searchTextField.text isEqualToString:@"SEARCH"])
        [searchTextField setText:@""];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField != searchTextField)
        return YES;
    
    [searchTextField resignFirstResponder];
    
    [friendsTableView reloadData];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField != searchTextField)
        return;
    
    if ([searchTextField.text isEqualToString:@""])
        [searchTextField setText:@"SEARCH"];
}

- (void) searchFieldChanged
{
    if (firstTimePopover)
        [firstTimePopover dismiss];
    
    if (searchTextField.text.length < 1)
        return;
    
    if ([friendFinder isSearching])
    {
        isSearchQueued = YES;
        return;
    }
    
    [friendFinder startSearchingForFriendsWithString:[searchTextField text]];
}

- (NSInteger) numberOfRowsForArray:(NSArray *) array
{
    return ([array count] / 3) + (([array count] % 3) > 0 ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 
    return [self numberOfRowsForArray:ccFriends];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendTableCell";
    
    CCPeopleTableViewCell *cell = [friendsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CCPeopleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSMutableArray *peopleForRow = [[NSMutableArray alloc] init];
    
    int startingPersonIndex = ([indexPath row] * 3);
    
    for(int personIndex = startingPersonIndex; personIndex < [ccFriends count] && personIndex < (startingPersonIndex + 3); personIndex++)
    {
        CCBasePerson *personForCell = [ccFriends objectAtIndex:personIndex];
        
        [peopleForRow addObject:personForCell];
    }
    
    [cell setForPeople:peopleForRow areIconsSelectable:YES andArePeopleSelectedBools:nil arePeopleRequestable:YES];
    
    return cell;
}

/* CCParseFriendFinderDelegate Methods */

- (void) didBeginSearchingForFriends
{
    [[self friendsTableView] setHidden:YES];
    
    [activityTextView setText:@"LOADING..."];
    [activityTextView setHidden:NO];
}

- (void) didUpdateFriendsSearchResultWithSuccess:(BOOL)wasSuccesfull andError:(NSError *)error andCCUsersThatAreFriends:(NSArray *)friends
{
    if (isSearchQueued)
        [friendFinder startSearchingForFriendsWithString:searchTextField.text];
    
    isSearchQueued = NO;
    
    if (wasSuccesfull)
    {
        if ([friends count] > 0)
        {
            if (!clickToInvitePopover && [[[[CCCoreManager sharedInstance] server] currentUser] isUserNewlyActivated])
            {
                clickToInvitePopover = [[CCTutorialPopover alloc] initWithMessage:@"Click to send a friend request!" pointsDirection:ccTutorialPopoverDirectionLeft withTargetPoint:CGPointMake(100, 120) andParentView:self.view];
                
                [clickToInvitePopover show];
            }
            
            [friendsTableView setHidden:NO];
            [activityTextView setHidden:YES];
        }
        else
        {
            [activityTextView setText:@"NO MATCHES."];
        }
        
        ccFriends = friends;
        
        [friendsTableView reloadData];
    }
    else
    {
        [activityTextView setText:@"ERROR."];
    }
}

@end
