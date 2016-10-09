//
//  CCCrewMembersViewController.m
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewMembersViewController.h"

@interface CCCrewMembersViewController ()

@end

@implementation CCCrewMembersViewController
@synthesize loadingLabel;
@synthesize viewTableView;
@synthesize crewForView;

- (void) setCrewForView:(id<CCCrew>) crew
{
    crewForView = crew;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [viewTableView setDataSource:self];

    // This can happen in low memory situations.  No real need to crash
    if (crewForView == nil)
    {
#ifdef DEBUG
        [NSException raise:@"Loaded crew memebers table without calling setCrewForView!" format:@"Loaded crew memebers table without calling setCrewForView!"];
#endif
        return;
    }
    
    [crewForView addCrewUpdateListener:self];
    
    [crewForView loadMembersInBackgroundWithBlock:nil];
    
    if ([[crewForView ccUsersThatAreMembers] count] > 0)
    {
        [viewTableView setHidden:NO];
        [loadingLabel setHidden:YES];
        [viewTableView reloadData];
    }

    [[self view] addCrewcamTitleToViewController:@"Members"];
    [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)];
}

- (IBAction)onBackButtonPressed:(id)sender {
    if ([self navigationController])
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else{
        [self dismissModalViewControllerAnimated:YES];
    }

}

- (void) finishedLoadingMembersCountWithSuccess:(BOOL)successful andError:(NSError *)error
{
    if ([[crewForView ccUsersThatAreMembers] count] == 0)
    {
        [loadingLabel setText:@"NO MEMBERS."];
    }
}

- (void) addedNewMembersAtIndexes:(NSArray *) newMemberIndexes andRemovedMembersAtIndexes:(NSArray *) deletedMemberIndexes
{
    [viewTableView setHidden:NO];
    [loadingLabel setHidden:YES];
    
    [viewTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([[crewForView ccUsersThatAreMembers] count] / 3) + (([[crewForView ccUsersThatAreMembers] count] % 3) > 0 ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"crewMemberCell";
    CCPeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CCPeopleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSMutableArray *membersForRow = [[NSMutableArray alloc] init];
    
    int startingMemberIndex = ([indexPath row] * 3);
    for(int memberIndex = startingMemberIndex; memberIndex < [[crewForView ccUsersThatAreMembers] count] && memberIndex < (startingMemberIndex + 3); memberIndex++)
    {
        id<CCUser> userForIcon = [[crewForView ccUsersThatAreMembers] objectAtIndex:memberIndex];
        [membersForRow addObject:[[CCBasePerson alloc] initWithCCUser:userForIcon]];
    }
    
    [cell setForPeople:membersForRow areIconsSelectable:YES andArePeopleSelectedBools:nil arePeopleRequestable:YES];
    
    return cell;
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (id<CCUser> user in [crewForView ccUsersThatAreMembers])
    {
        [user clearProfilePicture];
    }
}

- (void)viewDidUnload
{
    [self setLoadingLabel:nil];
    [self setViewTableView:nil];
    [self setCrewForView:nil];
    [crewForView removeCrewUpdateListener:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
