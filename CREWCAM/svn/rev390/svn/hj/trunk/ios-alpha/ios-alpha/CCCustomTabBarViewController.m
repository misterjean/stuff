//
//  CCCustomTabBarViewController.m
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCustomTabBarViewController.h"

@interface CCCustomTabBarViewController ()

@end

@implementation CCCustomTabBarViewController

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
    [[self tabBar] setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BAR_Bottom" ofType:@"png"]]];        
    
    // MY CREWS
    UIImage *tabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_TAB_Mycrews" ofType:@"png"]];
    UIImage *selectedTabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_TAB_Mycrews_ACT" ofType:@"png"]];
    UITabBarItem *myCrewsItem = [[[self tabBar] items] objectAtIndex:MY_CREWS_TAB_BAR_INDEX];
    [myCrewsItem setFinishedSelectedImage:selectedTabImage withFinishedUnselectedImage:tabImage];
    [myCrewsItem setTitle:@""];
    
    // JOIN CREWS
    tabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_TAB_Join" ofType:@"png"]];
    selectedTabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_TAB_Join_ACT" ofType:@"png"]];
    myCrewsItem = [[[self tabBar] items] objectAtIndex:JOIN_TAB_TAB_BAR_INDEX];
    [myCrewsItem setFinishedSelectedImage:selectedTabImage withFinishedUnselectedImage:tabImage];
    [myCrewsItem setTitle:@""];
    
    // INVITES
    tabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_TAB_Invites" ofType:@"png"]];
    selectedTabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_TAB_Invites_ACT" ofType:@"png"]];
    myCrewsItem = [[[self tabBar] items] objectAtIndex:INVITES_TAB_BAR_INDEX];
    [myCrewsItem setFinishedSelectedImage:selectedTabImage withFinishedUnselectedImage:tabImage];
    [myCrewsItem setTitle:@""];
    
    // NOTIFICATIONS
    tabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_TAB_MyFeed" ofType:@"png"]];
    selectedTabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_TAB_MyFeed_ACT" ofType:@"png"]];
    myCrewsItem = [[[self tabBar] items] objectAtIndex:NOTIFICATIONS_TAB_BAR_INDEX];
    [myCrewsItem setFinishedSelectedImage:selectedTabImage withFinishedUnselectedImage:tabImage];
    [myCrewsItem setTitle:@""];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
       [[[[CCCoreManager sharedInstance] server] currentUser] loadInvitesInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
           [[[[CCCoreManager sharedInstance] server] currentUser] loadNotificationsInBackgroundWithBlockOrNil:nil];
             
       }]; 
    }];
    
    // Subscribe to anybody asking to see the notifications tab
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNotificationsTab:) name:CC_SHOW_NOTIFICATIONS_TAB object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showInviteTab:) name:CC_SHOW_CREW_INVITES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewsTab:) name:CC_SHOW_CREWS_MEMBERS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewsTab:) name:CC_SHOW_VIDEO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewsTab:) name:CC_SHOW_VIDEOS_COMMENTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCrewsTab:) name:CC_SHOW_CREWS_MEMBERS_NOTIFICATION object:nil];  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationsViewed:) name:CC_NOTIFICATIONS_VIEWED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReturnFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self addCameraButton];
}

- (void) handleReturnFromBackground
{
    id<CCServer> server = [[CCCoreManager sharedInstance] server];
    id<CCUser> currentUser = [server currentUser];
    
    // Reload global settings
    [server loadGlobalSettingsInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // Refresh the current user
        [currentUser pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            if ([server globalSettings].isInLockdown &&
                ![currentUser isUserDeveloper])
            {
                NSString *lockdownAlertTitle = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_LOCKDOWN_ALERT_TITLE_KEY
                                                                                                   withDefault:NSLocalizedStringFromTable(@"LOCKDOWN", @"Localizable", nil)];
                
                NSString *lockdownAlertMessage = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_LOCKDOWN_ALERT_MESSAGE_KEY
                                                                                                   withDefault:NSLocalizedStringFromTable(@"LOCKDOWN", @"Localizable", nil)];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lockdownAlertTitle
                                                   message:lockdownAlertMessage
                                                  delegate:nil 
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
                [alert show];
                

                [self dismissModalViewControllerAnimated:YES];
                [currentUser logOutUserInBackground];
                
                return;
            }            
        }];
    }];
}

- (void) notificationsViewed: (id) sender
{
    notificationsBadgeValue = 0;
    [self setUIElementsBasedOnNotifications];
}

- (void) showNotificationsTab: (id) sender
{
    [self setSelectedIndex:NOTIFICATIONS_TAB_BAR_INDEX];
}

- (void) showInviteTab: (id) sender
{
    [self setSelectedIndex:INVITES_TAB_BAR_INDEX];
}

- (void) showCrewsTab: (id) sender
{
    [self setSelectedIndex:MY_CREWS_TAB_BAR_INDEX];
}

- (void)viewDidAppear:(BOOL)animated
{
    cameraUI = nil;
    cameraUI = [[UIImagePickerController alloc] init]; 
    [super viewDidAppear:animated];
}

- (void) setUIElementsBasedOnInvites
{        
    UITabBarItem *invitesTabBarItem = [[[self tabBar] items] objectAtIndex:INVITES_TAB_BAR_INDEX];
    
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] count] > 0)
    {
        [invitesTabBarItem setBadgeValue:[[NSString alloc] initWithFormat:@"%d", [[[[[CCCoreManager sharedInstance] server] currentUser] ccInvites] count]]];
    }
    else 
    {
        [invitesTabBarItem setBadgeValue:nil];
    }                                                                                     
}

- (void) finishedReloadingAllInvitesWithSucces:(BOOL) successful andError:(NSError *) error
{
    [self setUIElementsBasedOnInvites];
}

- (void) addedNewInvitesAtIndexes:(NSArray *) addedInviteIndexes andRemovedInvitesAtIndexes:(NSArray *)removedInviteIndexes
{
    [self setUIElementsBasedOnInvites];
}

- (void) setUIElementsBasedOnNotifications
{        
    UITabBarItem *notificationsTabBarItem = [[[self tabBar] items] objectAtIndex:NOTIFICATIONS_TAB_BAR_INDEX];
    
    if (notificationsBadgeValue > 0)
    {
        [notificationsTabBarItem setBadgeValue:[[NSString alloc] initWithFormat:@"%d", notificationsBadgeValue]];
    }
    else 
    {
        [notificationsTabBarItem setBadgeValue:nil];
    }
}

- (void) addedNewNotificationsAtIndexes:(NSArray *)addedNotificationIndexes andRemovedNotificationsAtIndexes:(NSArray *)removedNotificationIndexes
{
    if([self selectedIndex] == 3)
    {
        return;
    }
    
    for (int notificationIndex = 0; notificationIndex < [addedNotificationIndexes count]; notificationIndex++)
    {
        //Check if the newly loaded notifications have already been viewed.
        int addedNotificationIndex = [[addedNotificationIndexes objectAtIndex:notificationIndex] row];
        if (![[[[[[CCCoreManager sharedInstance] server] currentUser] ccNotifications] objectAtIndex:addedNotificationIndex] getIsViewed])
        {
            notificationsBadgeValue++;
        }
    }
 
    notificationsBadgeValue -= [removedNotificationIndexes count];
    
    [self setUIElementsBasedOnNotifications];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserUpdateListener:self];
    
    cameraImage = nil;
    cameraButton = nil;
    cameraUI = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addCameraButton
{
	UIImage *recordImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_REC" ofType:@"png"]]; //Setup the button

    CGRect recordButton = CGRectMake(130, 400, 60, 60);
    cameraImage = [[UIImageView alloc] initWithImage:recordImage];
    cameraImage.frame = recordButton; // Set the frame (size and position) of the button)
    cameraImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:cameraImage];
    
    cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = recordButton; 
	[cameraButton setTag:0]; // Assign the button a "tag" so when our "click" event is called we know which button was pressed.      
    
    [self.view addSubview:cameraButton];
    [cameraButton addTarget:self action:@selector(onCameraButtonPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onCameraButtonPress:(id)sender
{       
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lonely?" 
                                                        message:NSLocalizedStringFromTable(@"LONELY_ADD_CREWS_TEXT", @"Localizable", nil) 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Sounds Good!"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if ([[[CCCoreManager sharedInstance] server] uploaderIsBusy])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait..." 
                                                        message:@"A video is currently uploading... Please wait for it to finish before recording another video!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take Video", @"Choose Existing", nil];
        

        UIImageView* backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG_Share.png"]];
        [actionSheet addSubview:backgroundImage];
        [actionSheet sendSubviewToBack:backgroundImage];        
        
        [actionSheet showInView:self.view];
    } 
    else 
    {
        mediaSource = ccVideoLibrary;
        [cameraUI setCCPropertiesForMediaSource:mediaSource];
        cameraUI.delegate = self;            

        [self presentModalViewController: cameraUI animated: YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            //Take Video
            mediaSource = ccCamera;
            [cameraUI setCCPropertiesForMediaSource:mediaSource];
            break;
        case 1:
            //Choose Existing
            mediaSource = ccVideoLibrary;
            [cameraUI setCCPropertiesForMediaSource:mediaSource];
            break;
        default:
            return;
    }

    cameraUI.delegate = self;
        
    [self presentModalViewController: cameraUI animated: YES];    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([[navigationController viewControllers] indexOfObject:viewController] == 0)
    {
        [viewController setTitle:@"Videos"];
    }
    if ([[UIScreen mainScreen] scale] == 0x40000000)
    {
        [[navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
        [[navigationController navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    else 
    {
        [[navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }    
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info 
{
    // Handle a movie capture
    NSString *videoPath = [[info objectForKey:
                            UIImagePickerControllerMediaURL] path];  
    
    [self dismissModalViewControllerAnimated: NO];
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    //[self 
    CCPostVideoForumViewController *forumVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PostVideoForumView"];
    forumVC.videoPath = videoPath;
    forumVC.mediaSource = mediaSource;
    
    [self presentViewController:forumVC animated:YES completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideExistingTabBar
{
	for(UIView *view in self.view.subviews)
	{
		if([view isKindOfClass:[UITabBar class]])
		{
			view.hidden = YES;
			break;
		}
	}
}

@end
