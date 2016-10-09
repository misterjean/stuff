//
//  CCCrewsViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewsViewController.h"



@interface CCCrewsViewController ()

@end

@implementation CCCrewsViewController
@synthesize linkFacebookButton;
@synthesize setPasswordButton;
@synthesize settingsPanGestureRecognizer;
@synthesize usersNameTextLabel;
@synthesize combinedCrewsAndSettingsView;
@synthesize loadingLabel;
@synthesize crewsTableView;
@synthesize crewsPageControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Reset the settings view, in case the storyboard was messed up
    [combinedCrewsAndSettingsView setFrame:CGRectMake(-219, combinedCrewsAndSettingsView.frame.origin.y, combinedCrewsAndSettingsView.frame.size.width, combinedCrewsAndSettingsView.frame.size.height)];
    
    isShowingSettings = NO;
    
    [crewsTableView setDelegate:self];
    [crewsTableView setDataSource:self];
    
    [combinedCrewsAndSettingsView addCrewcamTitleToViewController:@"MY CREWS"];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewForNotification:) name:CC_SHOW_CREWS_MEMBERS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewForNotification:) name:CC_SHOW_VIDEO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewForNotification:) name:CC_SHOW_VIDEOS_COMMENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewForNotification:) name:CC_SHOW_CREWS_MEMBERS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningHandler) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shakeGallery:) name:CC_START_SHAKING_CREWS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopShaking:) name:CC_STOP_SHAKING_CREWS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopShaking:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSettings) name:@"resetSettingsTab" object:nil];
    
    //Check if user is linked with facebook on load.
    if ([[[[CCCoreManager sharedInstance] server] currentUser] isUserLinkedToFacebook])
    {
        [linkFacebookButton setTitle: @"UNLINK FACEBOOK" forState: UIControlStateNormal];
        [setPasswordButton setHidden:YES];
    }
    else
    {
        [linkFacebookButton setTitle: @"LINK FACEBOOK" forState: UIControlStateNormal];
        [setPasswordButton setHidden:NO];
    }
    
    [usersNameTextLabel setFont:[UIFont getSteelfishFontForSize:30]];
    [usersNameTextLabel setText:[[[[[CCCoreManager sharedInstance] server] currentUser] getName] uppercaseString]];
}

- (void) didReceiveMemoryWarningHandler
{
    [[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] removeAllObjects];
    [crewsTableView reloadData];
    
    if (self.isViewLoaded && self.view.window)
    {
        [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewsInBackgroundWithBlockOrNil:nil];
    }
}

- (void) showCrewForNotification:(NSNotification *) nsNotificationData
{
    UIViewController *currentVC = [[self navigationController] visibleViewController];
    
    id<CCNotification> ccNotificationData = [[nsNotificationData userInfo] objectForKey:@"ccNotificationData"];
    
    if ([currentVC isKindOfClass:[CCCrewViewController class]])
    {
        if ([(CCCrewViewController*)currentVC crewForView] != [[[[CCCoreManager sharedInstance] server] currentUser] getCrewFromObjectID:[ccNotificationData getTargetCrewObjectID]])
        {
            [[self navigationController] popToRootViewControllerAnimated:NO];
            
            [self loadViewForCrew:[[[[CCCoreManager sharedInstance] server] currentUser] getCrewFromObjectID:[ccNotificationData getTargetCrewObjectID]] Animated:YES];
        }
    }
    else
    {
        [[self navigationController] popToRootViewControllerAnimated:NO];
        
        [self loadViewForCrew:[[[[CCCoreManager sharedInstance] server] currentUser] getCrewFromObjectID:[ccNotificationData getTargetCrewObjectID]] Animated:YES];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewsInBackgroundWithBlockOrNil:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanupOldCrewViewControllers" object:nil userInfo:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[[[CCCoreManager sharedInstance] server] currentUser] isUserNewlyActivated] && !joinCrewsPopover)
    {
        id appDelegate = [[UIApplication sharedApplication] delegate];
        UIWindow *window = [appDelegate window];
        
        joinCrewsPopover = [[CCTutorialPopover alloc] initWithMessage:@"...or click JOIN to find your friend's crews" pointsDirection:ccTutorialPopoverDirectionDown withTargetPoint:CGPointMake(98, 480-44) andParentView:window];
        
        [joinCrewsPopover show];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopShaking:nil];
    
    if (joinCrewsPopover)
        [joinCrewsPopover setHidden:YES];
}

- (void) setUIElementsBasedOnCurrentCrews
{
    [crewsTableView setHidden:NO];
}

- (void) finishedLoadingAllCrewsWithSuccess:(BOOL) successful andError:(NSError *) error
{
    [loadingLabel setHidden:YES];
    for (id<CCCrew> crew in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews]) {
        [crew loadUnwatchedVideoCountInBackgroundWithBlockOrNil:nil];
    }

    [self setUIElementsBasedOnCurrentCrews];
}

- (void) addedNewCrewsAtIndexes:(NSArray *) newCrewsIndexes andRemovedCrewsAtIndexes:(NSArray *) deletedCrewsIndexes
{
    [self setUIElementsBasedOnCurrentCrews];
    
    [crewsTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    int numberOfCrews = [[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] count];
    return (numberOfCrews + 1)/3 + (((numberOfCrews + 1) % 3 > 0) ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"crewTableCell";
    CCCrewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    BOOL isFirstRow = ([indexPath row] == 0);
    
    NSArray *usersCrews = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews];
    NSMutableArray *crews = [[NSMutableArray alloc] init];
    
    if (cell == nil)
    {
        cell = [[CCCrewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    int startingCrewIndex = ([indexPath row] == 0) ? 0 : (([indexPath row] * 3) - 1);
    int crewIndex;
    for(crewIndex = startingCrewIndex; crewIndex < [usersCrews count] && crewIndex < (isFirstRow ? (startingCrewIndex + 2) : (startingCrewIndex + 3)); crewIndex++)
    {
        [crews addObject:[usersCrews objectAtIndex:crewIndex]];
    }
    
    [cell setCrews:crews andNavigationController:self.navigationController andIsFirstRow:isFirstRow andIsShaking:shakingIcons];
    
    for (UIView *cv in [cell subviews])
    {
        if ([cv isKindOfClass:[CCCrewIconView class]])
        {
            if (shakingIcons)
                [((CCCrewIconView *)cv) shake];
            else
                [((CCCrewIconView *)cv) stopShaking];
        }
        
    }
    
    return cell;
}

- (void)loadViewForCrew:(id<CCCrew>) crew Animated:(BOOL)animated
{
    CCCrewViewController *crewView = [self.storyboard instantiateViewControllerWithIdentifier:@"crewFeedView"];
    
    [crewView initWithCrew:crew];
    
    [self.navigationController pushViewController:crewView animated:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)shakeGallery:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startShaking" object:nil];
    shakingIcons = YES;
}

- (IBAction)stopShaking:(id)sender
{
    for (UIView* v in [crewsTableView subviews])
    {
        if ([v isKindOfClass:[CCCrewTableViewCell class]])
        {
            for (UIView *cv in [v subviews])
            {
                if ([cv isKindOfClass:[CCCrewIconView class]])
                {
                    [((CCCrewIconView *) cv) stopShaking];
                }
            }
        }
    }
    shakingIcons = NO;
}

- (IBAction)setProfilePictureButtonPressed:(id)sender
{
    CCUserPictureViewController *userPPView = [[self storyboard] instantiateViewControllerWithIdentifier:@"profilePictureView"];
    
    [userPPView setNewUserProcess:NO];
    
    [[self navigationController] pushViewController:userPPView animated:YES];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserUpdateListener:self];
    
    crewForComment = nil;
    videoForComment = nil;
    newPasswordField = nil;
    confirmNewPasswordField = nil;
    
    [self setCrewsTableView:nil];
    [self setCombinedCrewsAndSettingsView:nil];
    [self setCrewsPageControl:nil];
    [self setLinkFacebookButton:nil];
    [self setSetPasswordButton:nil];
    
    // There seems to be a bug whereby this release will cause an exception to be thrown after a low memory warning
    //    [self setSettingsPanGestureRecognizer:nil];
    [self setUsersNameTextLabel:nil];
    [self setLoadingLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"friendsCrewsSegue"])
    {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        CCJoinViewController *welcomeVC = (CCJoinViewController*)[navController topViewController];
        [welcomeVC setIsNewUser:NO];
    }
}

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag]) {
        case CCCommentPushAlert:
        {
            if (buttonIndex == 1)
            {
                UIViewController *currentVC=[[self navigationController] visibleViewController];
                
                if ([currentVC isKindOfClass:[CCVideosCommentsViewController class]])
                {
                    if ([(CCVideosCommentsViewController *)currentVC videoForView] != videoForComment)
                    {
                        UINavigationController *navController = [self navigationController];
                        
                        [navController popToRootViewControllerAnimated:NO];
                        
                        [self loadViewForCrew:crewForComment Animated:NO];
                        
                        CCVideosCommentsViewController *videosCommentsView = [[self storyboard] instantiateViewControllerWithIdentifier:@"videosCommentsView"];
                        
                        [videosCommentsView setVideoForView:videoForComment];
                        
                        [navController pushViewController:videosCommentsView animated:YES];
                    }
                }
                else
                {
                    UINavigationController *navController = [self navigationController];
                    
                    [navController popToRootViewControllerAnimated:NO];
                    
                    [self loadViewForCrew:crewForComment Animated:NO];
                    
                    CCVideosCommentsViewController *videosCommentsView = [[self storyboard] instantiateViewControllerWithIdentifier:@"videosCommentsView"];
                    
                    [videosCommentsView setVideoForView:videoForComment];
                    
                    [navController pushViewController:videosCommentsView animated:YES];
                }
                
            }
            break;
        }
        case CCLogoutAlert:
        {
            if (buttonIndex == 1)
            {
                [[[CCCoreManager sharedInstance] server] logOutCurrentUserInBackground];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        }
        case CCUnlinkFBAlert:
        {
            if (buttonIndex == 1)
            {
                [[[CCCoreManager sharedInstance] server] unlinkCurrentUserToFacebookInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error)
                     {
                         [linkFacebookButton setEnabled:YES];
                     }
                     else
                     {
                         [self facebookLinkChange];
                     }
                 }];
            }
            else
            {
                [linkFacebookButton setEnabled:YES];
            }
        }
            break;
        case CCSuccessfulFBUnlink:
        {            
            CCUnlinkFBEmailViewController *unlinkEmailVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"unlinkFacebookEmailView"];
            [[self navigationController] presentModalViewController:unlinkEmailVC animated:YES];
            break;
        }
        default:
            break;
    }
    
}


- (IBAction)onLogoutButtonPressed:(id)sender {
    
    CCCrewcamAlertView *updateAlert = [[CCCrewcamAlertView alloc] initWithTitle: NSLocalizedStringFromTable(@"LOGOUT_CONFIRM_TITLE", @"Localizable", nil)
                                                                        message: NSLocalizedStringFromTable(@"LOGOUT_CONFIRM_TEXT", @"Localizable", nil)
                                                                  withTextField:NO
                                                                       delegate: self
                                                              cancelButtonTitle: nil
                                                              otherButtonTitles:@"Logout", nil];
    
    [updateAlert setTag:CCLogoutAlert];
    [updateAlert show];
    
}

- (IBAction)onAddFriendsButtonPressed:(id)sender {
    if (!friendFinderViewController)
    {
        friendFinderViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"friendFinderView"];
    }
    
    [[self navigationController] pushViewController:friendFinderViewController animated:YES];
}



- (IBAction)onPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:combinedCrewsAndSettingsView];
    [recognizer setTranslation:CGPointMake(0, 0) inView:combinedCrewsAndSettingsView];
    
    if ((combinedCrewsAndSettingsView.frame.origin.x + translation.x) > 0)
    {
        [combinedCrewsAndSettingsView setFrame:CGRectMake(0
                                                          , combinedCrewsAndSettingsView.frame.origin.y, combinedCrewsAndSettingsView.frame.size.width, combinedCrewsAndSettingsView.frame.size.height)];
    }
    else if((combinedCrewsAndSettingsView.frame.origin.x + translation.x) < -219)
    {
        [combinedCrewsAndSettingsView setFrame:CGRectMake(-219
                                                          , combinedCrewsAndSettingsView.frame.origin.y, combinedCrewsAndSettingsView.frame.size.width, combinedCrewsAndSettingsView.frame.size.height)];
    }
    else
    {
        [combinedCrewsAndSettingsView setFrame:CGRectMake(combinedCrewsAndSettingsView.frame.origin.x + translation.x
                                                          , combinedCrewsAndSettingsView.frame.origin.y, combinedCrewsAndSettingsView.frame.size.width, combinedCrewsAndSettingsView.frame.size.height)];
    }
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (combinedCrewsAndSettingsView.frame.origin.x + 219 < 219/2)
        {
            isShowingSettings = NO;
            // Animate to the crews page
            [crewsPageControl setHidden:YES];
            [UIView animateWithDuration:0.2 animations:^{
                [combinedCrewsAndSettingsView setFrame:CGRectMake(-219
                                                                  , combinedCrewsAndSettingsView.frame.origin.y, combinedCrewsAndSettingsView.frame.size.width, combinedCrewsAndSettingsView.frame.size.height)];
            }];
        }
        else
        {
            isShowingSettings = YES;
            [crewsPageControl setHidden:NO];
            // Animate to the settings page
            [UIView animateWithDuration:0.2 animations:^{
                [combinedCrewsAndSettingsView setFrame:CGRectMake(0
                                                                  , combinedCrewsAndSettingsView.frame.origin.y, combinedCrewsAndSettingsView.frame.size.width, combinedCrewsAndSettingsView.frame.size.height)];
            }];
        }
        
    }
}

- (IBAction)onSettingsButtonPressed:(id)sender {
    if (isShowingSettings)
    {
        [self hideSettings];
    }
    else
    {
        [self showSettings];
    }
}

- (void) showSettings
{
    [crewsPageControl setHidden:NO];
    isShowingSettings = YES;
    [UIView animateWithDuration:.2 animations:^{
        [combinedCrewsAndSettingsView setFrame:CGRectMake(0, combinedCrewsAndSettingsView.frame.origin.y, combinedCrewsAndSettingsView.frame.size.width, combinedCrewsAndSettingsView.frame.size.height)];
    } completion:nil];
}

- (void) hideSettings
{
    [crewsPageControl setHidden:YES];
    isShowingSettings = NO;
    [UIView animateWithDuration:.2 animations:^{
        [combinedCrewsAndSettingsView setFrame:CGRectMake(-219, combinedCrewsAndSettingsView.frame.origin.y, combinedCrewsAndSettingsView.frame.size.width, combinedCrewsAndSettingsView.frame.size.height)];
    } completion:nil];
}

- (IBAction)onCrewsPageTouched:(id)sender
{
    [self hideSettings];
}

- (IBAction)onLinkFacebookButtonPress:(id)sender
{
    [linkFacebookButton setEnabled:NO];
    
    if (![[[[CCCoreManager sharedInstance] server] currentUser] isUserLinkedToFacebook])
    {
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_LINK_FB withProperties:nil];
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_ADD_CREW withProperties:nil];
        [[[CCCoreManager sharedInstance] server] linkCurrentUserToFacebookInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error)
            {
                [linkFacebookButton setEnabled:YES];
                
                if([error code] == ccFacebookAccountAlreadyLinked)
                {
                    CCCrewcamAlertView *updateAlert = [[CCCrewcamAlertView alloc] initWithTitle: NSLocalizedStringFromTable(@"LINK_FB_ERROR_TITLE", @"Localizable", nil)
                                                                                        message: NSLocalizedStringFromTable(@"OTHER_ACCOUNT_LINKED", @"Localizable", nil)
                                                                                  withTextField:NO
                                                                                       delegate: self
                                                                              cancelButtonTitle: @"Cancel"
                                                                              otherButtonTitles: nil];
                    
                    [updateAlert show];
                }
                else
                {
                    CCCrewcamAlertView *updateAlert = [[CCCrewcamAlertView alloc] initWithTitle: @"Error"
                                                                                        message: @"Unable to link with Facebook."
                                                                                  withTextField: NO
                                                                                       delegate: self
                                                                              cancelButtonTitle: @"Cancel"
                                                                              otherButtonTitles: nil];
                    
                    [updateAlert show];
                }
                return;
            }
            
            [self facebookLinkChange];
        }];
    }
    else
    {
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_UNLINK_FB withProperties:nil];
        CCCrewcamAlertView *updateAlert = [[CCCrewcamAlertView alloc] initWithTitle: NSLocalizedStringFromTable(@"UNLINK_FB_CONFIRM_TITLE", @"Localizable", nil)
                                                                            message: NSLocalizedStringFromTable(@"UNLINK_FB_CONFIRM_TEXT", @"Localizable", nil)
                                                                      withTextField:NO
                                                                           delegate: self
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:@"Unlink", nil];
        
        [updateAlert setTag:CCUnlinkFBAlert];
        [updateAlert show];
    }
    
}

- (IBAction)onSetPasswordPress:(id)sender
{
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_SET_PASSWORD withProperties:nil];
    CCUnlinkFBEmailViewController *unlinkEmailVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"unlinkFacebookEmailView"];
    [unlinkEmailVC setTextForTextBlock:@"Please enter and confirm your new password"];
    [[self navigationController] presentModalViewController:unlinkEmailVC animated:YES];
}

- (void)facebookLinkChange
{
    if ([[[[CCCoreManager sharedInstance] server] currentUser] isUserLinkedToFacebook])
    {
        
        [linkFacebookButton setTitle: @"UNLINK FACEBOOK" forState: UIControlStateNormal];
        [[self setPasswordButton] setHidden:YES];
    }
    else
    {
        CCCrewcamAlertView *updateAlert = [[CCCrewcamAlertView alloc] initWithTitle: NSLocalizedStringFromTable(@"SUCCESS_UNLINK_FB_TITLE", @"Localizable", nil)
                                                                            message: NSLocalizedStringFromTable(@"SUCCESS_UNLINK_FB_TEXT", @"Localizable", nil)
                                                                      withTextField:NO
                                                                           delegate: self
                                                                  cancelButtonTitle: nil
                                                                  otherButtonTitles:@"OK", nil];
        [updateAlert setTag:CCSuccessfulFBUnlink];
        [updateAlert show];
        
        [linkFacebookButton setTitle: @"LINK FACEBOOK" forState: UIControlStateNormal];
        [[self setPasswordButton] setHidden:NO];
    }
    
    [linkFacebookButton setEnabled:YES];
}


@end
