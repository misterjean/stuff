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
    
    [self addCameraButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addCameraButton
{
	cameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect]; //Setup the button
    cameraButton.frame = CGRectMake(120, 420, 80, 60); // Set the frame (size and position) of the button)
	[cameraButton setTag:0]; // Assign the button a "tag" so when our "click" event is called we know which button was pressed.
	[cameraButton setSelected:true];
    [cameraButton setTitle:@"Record" forState:UIControlStateNormal];
    [self.view addSubview:cameraButton];
    [cameraButton addTarget:self action:@selector(onCameraButtonPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onCameraButtonPress:(id)sender
{
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] crews] count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lonely?" 
                                                        message:@"Hmm... You don't seem to be a member of any crews.  Click the \"+\" button to add one, or check the invites tab to see if anyone has invited you!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Sounds Good!"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.videoMaximumDuration = 90;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;

    cameraUI.delegate = self;
    
    [self presentModalViewController: cameraUI animated: YES];
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
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (videoPath)) {
        UISaveVideoAtPathToSavedPhotosAlbum (videoPath, nil, nil, nil);
    }
    
    [self presentViewController:forumVC animated:YES completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
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
