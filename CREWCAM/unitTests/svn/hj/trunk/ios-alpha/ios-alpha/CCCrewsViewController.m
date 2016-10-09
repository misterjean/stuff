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
@synthesize crewsTableView;
@synthesize crewsActivityLabel;
@synthesize activityIndicator;

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
    
    [crewsTableView setDelegate:self];
    [crewsTableView setDataSource:self];
    
    [[[self navigationController] navigationBar] setClipsToBounds:NO];
    [[[self navigationController] navigationBar] setOpaque:YES];   
    if ([[UIScreen mainScreen] scale] == 0x40000000)
    {        
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
        [[[self navigationController] navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    else 
    {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Logout" target:self action:@selector(onLogoutButtonPressed:)]];
    
    [[self navigationItem] setRightBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Add" target:self action:@selector(onAddButtonPressed:)]];
        
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewForNotification:) name:CC_SHOW_CREWS_MEMBERS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewForNotification:) name:CC_SHOW_VIDEO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewForNotification:) name:CC_SHOW_VIDEOS_COMMENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewForNotification:) name:CC_SHOW_CREWS_MEMBERS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningHandler) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}


- (void) didReceiveMemoryWarningHandler
{
    [self viewDidUnload];
    
    [self viewDidLoad];
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

- (void) onAddButtonPressed:(id) sender
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    CCInviteViewController *inviteView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"newCrewView"];
    [inviteView setStoredNavigationController:[self navigationController]];
    [self presentModalViewController:inviteView animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewsInBackgroundWithBlockOrNil:nil];
}

- (void) setUIElementsBasedOnCurrentCrews
{
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] count] > 0)
    {
        [crewsTableView setHidden:NO];
        [crewsActivityLabel setHidden:YES];
    }
    else 
    {
        NSString *noCrewsMessage = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_NO_CREWS_MESSAGE_KEY withDefault:@"No crews.  Add or join one!"];
        [crewsActivityLabel setText:noCrewsMessage];
        [crewsActivityLabel setHidden:NO];
        [crewsTableView setHidden:YES];
    }
}

- (void) startingToReloadAllCrews
{
    [crewsActivityLabel setText:@"Loading crews..."];
}

- (void) finishedLoadingAllCrewsWithSuccess:(BOOL) successful andError:(NSError *) error
{
    for (id<CCCrew> crew in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews]) {
        [crew loadUnwatchedVideoCountInBackgroundWithBlockOrNil:nil];
    }
    
    [activityIndicator setHidden:YES];
    [self setUIElementsBasedOnCurrentCrews];
    [crewsTableView reloadData];

}

- (void) addedNewCrewsAtIndexes:(NSArray *) newCrewsIndexes andRemovedCrewsAtIndexes:(NSArray *) deletedCrewsIndexes
{        
    [self setUIElementsBasedOnCurrentCrews];
    
    [crewsTableView beginUpdates];
    
    [crewsTableView deleteRowsAtIndexPaths:deletedCrewsIndexes withRowAnimation:UITableViewRowAnimationFade];
    [crewsTableView insertRowsAtIndexPaths:newCrewsIndexes withRowAnimation:UITableViewRowAnimationFade];            
    
    [crewsTableView endUpdates];   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"crewTableCell";
    CCCrewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id<CCCrew> thisCrew = [[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] objectAtIndex:[indexPath row]];
    
    if (cell == nil)
    {
        cell = [[CCCrewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setCrew:thisCrew];
    
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
    
    [self loadViewForCrew:[[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] objectAtIndex:[indexPath row]] Animated:YES];    
}

- (void)viewDidUnload
{

    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserUpdateListener:self];
    
    crewForComment = nil;
    videoForComment = nil;
    
    [self setCrewsTableView:nil];
    [self setCrewsActivityLabel:nil];
    [self setActivityIndicator:nil];
    
    [super viewDidUnload];
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
    // Release any retained subviews of the main view.
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
        CCWelcomeViewController *welcomeVC = (CCWelcomeViewController*)[navController topViewController];
        [welcomeVC setIsNewUser:NO];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
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
                [[self navigationController] dismissViewControllerAnimated:YES completion:^{
                    
                }];  
            }
        }
            
        default:
            break;
            
    }
    
}


- (IBAction)onLogoutButtonPressed:(id)sender {
    
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedStringFromTable(@"LOGOUT_CONFIRM_TITLE", @"Localizable", nil) 
                                                          message: NSLocalizedStringFromTable(@"LOGOUT_CONFIRM_TEXT", @"Localizable", nil) 
                                                         delegate: self 
                                                cancelButtonTitle: @"Cancel" 
                                                otherButtonTitles:@"Logout", nil];
    
    [updateAlert setTag:CCLogoutAlert];
    [updateAlert show];
    
}    



@end
