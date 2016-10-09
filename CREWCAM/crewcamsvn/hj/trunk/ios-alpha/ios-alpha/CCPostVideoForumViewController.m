//
//  CCPostVideoForumViewController.m
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCPostVideoForumViewController.h"

@interface CCPostVideoForumViewController ()

@end

@implementation CCPostVideoForumViewController
@synthesize crewsTableViewOutlet;
@synthesize videoPath;
@synthesize shareButton;
@synthesize checkedIndexPaths;
@synthesize cancelButton;
@synthesize postToFacebook;
@synthesize mediaSource;
@synthesize storedNavigationController;

- (void)viewDidUnload
{
    crewsForVideo = nil;
    crewsForPosting = nil;
    
    [self setCrewsTableViewOutlet:nil];
    [self setVideoPath:nil];
    [self setShareButton:nil];
    [self setCheckedIndexPaths:nil];
    [self setCancelButton:nil];
    [self setPostToFacebook:nil];
    [self setStoredNavigationController:nil];
    
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    checkedIndexPaths = [[NSMutableSet alloc] init];
    
    if ([[[CCCoreManager sharedInstance] server] globalSettings].isPostableToFacebook)
    {
        [postToFacebook setHidden:NO];
    }
    else
    {
        [postToFacebook setHidden:YES];
    }
    
    crewsForPosting = [[NSMutableArray alloc] initWithArray:[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews]];
    
    for (id<CCCrew> crew in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews])
    {
        if ([crew getCrewtype] == CCDeveloper && ![[[[CCCoreManager sharedInstance] server] currentUser] isUserDeveloper])
        {
            [crewsForPosting removeObject:crew];
        }
    }
    
    crewsForPosting = [self sortArrayOfCrewsAlphabetically:crewsForPosting];
    
    [crewsTableViewOutlet setHidden:NO];
    [crewsTableViewOutlet reloadData];
    
    [shareButton setEnabled:YES];
    
    [cancelButton setHidden:NO];
    [postToFacebook setHidden:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onSubmitPressWithSender:(id)sender 
{    
    if ([checkedIndexPaths count] == 0)
    {
        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"CREW_SELECT_TITLE", @"Localizable", nil)
                                                                      message:NSLocalizedStringFromTable(@"CREW_SELECT_TEXT", @"Localizable", nil)
                                                                withTextField:NO
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:nil];
        [alert show];
        
        return;
    }        
    else
    {
        [crewsTableViewOutlet setHidden:YES];
        
        [shareButton setEnabled:NO];
        
        [cancelButton setHidden:YES];
        [postToFacebook setHidden:YES];
        [self saveVideoToSelectedCrews];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)onCancelPressWithSender:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    
    if (mediaSource != ccVideoLibrary && UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (videoPath))
    {
        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"SAVE VIDEO"
                                                                      message:NSLocalizedStringFromTable(@"ASK_TO_SAVE_LOCALLY", @"Localizable", nil)
                                                                withTextField:NO
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:@"Save", nil];
        alert.tag = askToSaveTag;
        [alert show];
    }
}

- (IBAction)postToFacebookButtonPressed:(id)sender
{
    if (![[[[CCCoreManager sharedInstance] server] currentUser] isUserLinkedToFacebook])
    {
        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"FACEBOOK_PERMISSIONS_TITLE", @"Localizable", nil)
                                                                      message:NSLocalizedStringFromTable(@"FACEBOOK_ENABLED_TEXT", @"Localizable", nil)
                                                                withTextField:NO
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:nil];
        
        [alert show];
        
        return;   
    }
    
    if (![[[[CCCoreManager sharedInstance] server] currentUser] getFacebookUserWallPostPermission])
    {
        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"FACEBOOK_PERMISSIONS_TITLE", @"Localizable", nil)
                                                                      message:NSLocalizedStringFromTable(@"FACEBOOK_PERMISSIONS_TEXT", @"Localizable", nil)
                                                                withTextField:NO
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:@"Save & Logout", nil];
        
        [alert setTag:reauthorizeTag];
        
        [alert show];

        return;
    }
    [[self postToFacebook] setHighlighted:NO];
    [[self postToFacebook] setSelected:![[self postToFacebook] isSelected]];
}

- (IBAction)shareWithFacebookHelpPressed:(id)sender {
    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Help" message:@"Selecting share with Facebook will post a link to the video on your wall. This feature requires that your account be connected to a Facebook account" withTextField:NO delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    
    [alert show];
    
}

// Required UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [crewsForPosting count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"postToCrewsCell";
    CCCrewForSharingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CCCrewForSharingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setCrewForCell:[crewsForPosting objectAtIndex:[indexPath row]] withViewController:self];
    
    if([[self checkedIndexPaths] containsObject:indexPath])
    {
        [cell setCrewSelected:YES];
    }
    else
    {
        [cell setCrewSelected:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Add the checmark indicator for the cell
    CCCrewForSharingCell *thisCell = (CCCrewForSharingCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if([[self checkedIndexPaths] containsObject:indexPath])
    {
        [[self checkedIndexPaths] removeObject:indexPath];
        [thisCell setCrewSelected:NO];
    }
    else
    {
        [[self checkedIndexPaths] addObject:indexPath];
        [thisCell setCrewSelected:YES];
    }
}

- (void)saveVideoToSelectedCrews
{
    NSArray *usersCrews = crewsForPosting;
    crewsForVideo = [[NSMutableArray alloc] init];
    
    for(int currentCrew = 0; currentCrew < [usersCrews count]; currentCrew++)
    {
        NSIndexPath *indexPathForCrew = [NSIndexPath indexPathForRow:currentCrew inSection:0];
        
        if ([[self checkedIndexPaths] containsObject:indexPathForCrew])
        {              
            [crewsForVideo addObject:[usersCrews objectAtIndex:currentCrew]];
        }            
    }
    
    [[[CCCoreManager sharedInstance] server] addNewVideoWithName:@"" currentVideoLocation:videoPath addToCrews:crewsForVideo addToFacebook:[postToFacebook isSelected] mediaSource:[self mediaSource]];
}


// CCVideoUpdatesDelegate Methods

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case askToSaveTag:
            if (buttonIndex == 1)
            {
                // Save the video
                UISaveVideoAtPathToSavedPhotosAlbum (videoPath, nil, nil, nil);
                
            }
            break;
            
        case reauthorizeTag:

            if (buttonIndex == 1)
            {
                UISaveVideoAtPathToSavedPhotosAlbum (videoPath, nil, nil, nil);
                [[[CCCoreManager sharedInstance] server] logOutCurrentUserInBackground];
                UIViewController *localyStoredNC = [self storedNavigationController];
                [self dismissModalViewControllerAnimated:NO];
                [localyStoredNC dismissViewControllerAnimated:NO completion:^{
                    
                }];
            }
            break;
        default:
            break;
    } 
}

- (NSMutableArray *) sortArrayOfCrewsAlphabetically:(NSMutableArray *) crews
{
    NSMutableArray *sortedCrews = [[NSMutableArray alloc] initWithArray:crews];
    [sortedCrews sortUsingComparator:^NSComparisonResult(id<CCCrew> obj1, id<CCCrew> obj2) 
     {
         return [[obj1 getName] compare:[obj2 getName] options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];

     }];
    return sortedCrews;
}

@end
