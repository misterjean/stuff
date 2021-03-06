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
    UIImage *tabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_MyCrews" ofType:@"png"]];
    UIImage *selectedTabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_MyCrews_ACT" ofType:@"png"]];
    UITabBarItem *myCrewsItem = [[[self tabBar] items] objectAtIndex:MY_CREWS_TAB_BAR_INDEX];
    [myCrewsItem setFinishedSelectedImage:selectedTabImage withFinishedUnselectedImage:tabImage];
    [myCrewsItem setTitle:@""];
    
    // JOIN CREWS
    tabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Join" ofType:@"png"]];
    selectedTabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Join_ACT" ofType:@"png"]];
    myCrewsItem = [[[self tabBar] items] objectAtIndex:JOIN_TAB_TAB_BAR_INDEX];
    [myCrewsItem setFinishedSelectedImage:selectedTabImage withFinishedUnselectedImage:tabImage];
    [myCrewsItem setTitle:@""];
    
    // INVITES
    tabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Invites" ofType:@"png"]];
    selectedTabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Invites_ACT" ofType:@"png"]];
    myCrewsItem = [[[self tabBar] items] objectAtIndex:INVITES_TAB_BAR_INDEX];
    [myCrewsItem setFinishedSelectedImage:selectedTabImage withFinishedUnselectedImage:tabImage];
    [myCrewsItem setTitle:@""];
    
    // ADD TO CREW
    tabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_NewCrew" ofType:@"png"]];
    selectedTabImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_NewCrew_ACT" ofType:@"png"]];
    myCrewsItem = [[[self tabBar] items] objectAtIndex:NEW_CREW_TAB_BAR_INDEX];
    [myCrewsItem setFinishedSelectedImage:selectedTabImage withFinishedUnselectedImage:tabImage];
    [myCrewsItem setTitle:@""];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
       [[[[CCCoreManager sharedInstance] server] currentUser] loadInvitesInBackgroundWithBlockOrNil:nil]; 
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CCCrewBasedPushNotificationReceived:) name:@"CCVideoPushNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CCCrewBasedPushNotificationReceived:) name:@"CCCommentPushNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CCInvitePushNotificationReceived:) name:@"CCInvitePushNotification" object:nil];
    
    cameraUI = [[UIImagePickerController alloc] init];
    
    [self addCameraButton];
}

- (void)viewDidAppear:(BOOL)animated
{
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

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
                                                        message:@"Hmm... You don't seem to be a member of any crews.  Click the \"+\" button to add one, or check the invites tab to see if anyone has invited you!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Sounds Good!"
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
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.videoMaximumDuration = ALLOWED_VIDEO_LENGTH;
        
        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        cameraUI.allowsEditing = YES;
        
        cameraUI.delegate = self;            

        [self presentModalViewController: cameraUI animated: YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            cameraUI.allowsEditing = NO;
            cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            cameraUI.allowsEditing = YES;
            cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            return;
    }
    
    cameraUI.videoMaximumDuration = ALLOWED_VIDEO_LENGTH;
        
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];

    cameraUI.delegate = self;
    
    cameraUI.videoQuality = UIImagePickerControllerQualityTypeMedium;
        
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


- (void) CCCrewBasedPushNotificationReceived:(NSNotification *)CCVideoPushNotification
{
    [self setSelectedIndex:MY_CREWS_TAB_BAR_INDEX];
}

- (void) CCInvitePushNotificationReceived:(NSNotification *)CCInvitePushNotification
{
    [self setSelectedIndex:INVITES_TAB_BAR_INDEX];
}

@end
