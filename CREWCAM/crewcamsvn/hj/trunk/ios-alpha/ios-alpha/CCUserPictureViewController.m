//
//  CCUserPictureViewController.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-07-31.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCUserPictureViewController.h"

@interface CCUserPictureViewController ()

@end

@implementation CCUserPictureViewController
@synthesize cameraUI;
@synthesize photoDispay;
@synthesize imageViewHolder;
@synthesize takePhotoButton;
@synthesize doneButton;
@synthesize facebookButton;
@synthesize linerHolderView;
@synthesize instructionText;
@synthesize newUserProcess;
@synthesize activityIndicator;

static BOOL takenWithCamera;

- (void)viewDidUnload
{
    [self setPhotoDispay:nil];
    [self setImageViewHolder:nil];
    [self setTakePhotoButton:nil];
    [self setDoneButton:nil];
    [self setFacebookButton:nil];
    [self setLinerHolderView:nil];
    [self setInstructionText:nil];
    [self setActivityIndicator:nil];
    [self setCameraUI:nil];
    
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    takenWithCamera = YES;

    if (newUserProcess)
    {
        [[self facebookButton] setHidden:YES];
        [[self takePhotoButton] setFont:[UIFont getSteelfishFontForSize:25]];
        [[self doneButton] setTitle:@"SKIP" forState:UIControlStateNormal];
        [[self takePhotoButton] setFrame:CGRectMake(87, 237, 75, [[self takePhotoButton] frame].size.height)];
    }
    else 
    {   
        [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)];
        
        [[self imageViewHolder] setFrame:CGRectMake(115, 120, 91, 91)];
        
        [[self takePhotoButton] setFrame:CGRectMake(119, 237, [[self takePhotoButton] frame].size.width , [[self takePhotoButton] frame].size.height)];
        
        [[self doneButton] setHidden:YES];
        
        [[self linerHolderView] setHidden:YES];
        
        [[self instructionText] setHidden:YES];
    }
    
    
    [[[[CCCoreManager sharedInstance] server] currentUser] getProfilePictureInBackgroundWithBlock:^(UIImage *image, NSError *error) {
        [[self photoDispay] setImage:image];
    }];
}

- (IBAction)onBackButtonPressed:(id)sender 
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)selectCustomPhoto:(id)sender
{
    cameraUI = nil;
    cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
        
        takenWithCamera = NO;
        UIImageView* backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG_Share.png"]];
        [actionSheet addSubview:backgroundImage];
        [actionSheet sendSubviewToBack:backgroundImage]; 
        if ([[[self parentViewController] tabBarController] tabBar])
            [actionSheet showFromTabBar:[[[self parentViewController] tabBarController] tabBar]];
        else 
            [actionSheet showInView:[self view]];
        
        
    } 
    else 
    {
        cameraUI.delegate = self; 
        [cameraUI setAllowsEditing: YES];
        [cameraUI setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        [self presentModalViewController: cameraUI animated: YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            //Take Photo
            takenWithCamera = YES;
            [cameraUI setAllowsEditing: YES];
            [cameraUI setSourceType:UIImagePickerControllerSourceTypeCamera];
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerSourceTypeCamera])
                [cameraUI setCameraDevice:UIImagePickerControllerCameraDeviceFront];
            [cameraUI setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
            break;
        case 1:
            //Choose Existing
            takenWithCamera = NO;
            [cameraUI setAllowsEditing: YES];
            [cameraUI setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        default:
            return;
    }
    
    cameraUI.delegate = self;
    
    [self presentModalViewController: cameraUI animated: YES];    
}


- (IBAction)selectFBPhoto:(id)sender
{
    if (![[[[CCCoreManager sharedInstance] server] currentUser] isUserLinkedToFacebook])
    {
        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Facebook" message:@"You are not linked with a Facebook account. Link yourself to your Facebook account in order to use your Facebook profile picture." withTextField:NO delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        
        [alert show];
        
        return;
    }
    
    [[[[CCCoreManager sharedInstance] server] currentUser] setProfilePicture:nil];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] getProfilePictureInBackgroundWithBlock:^(UIImage *image, NSError *error) {
        [[self photoDispay] setImage:image];
    }];
}

- (IBAction)onDoneButtonPressed:(id)sender
{
    [[[[CCCoreManager sharedInstance] server] currentUser] pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
     {    
         [activityIndicator setHidden:NO];    
         UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
         UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainTabView"];        
         [self presentViewController:mainTabView animated:YES completion:^{
             [[self navigationController] popToRootViewControllerAnimated:NO];   
         }];
     }];    
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info 
{
    // Handle a movie capture
    UIImage *picture = [info objectForKey:
                            UIImagePickerControllerEditedImage]; 
    
    UIImage *uneditedPicture = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (takenWithCamera)
        UIImageWriteToSavedPhotosAlbum(uneditedPicture, nil, nil, nil);
    
    [[[[CCCoreManager sharedInstance] server] currentUser] setProfilePicture:picture];
    
    [self dismissModalViewControllerAnimated: NO];
    
    [[self doneButton] setTitle:@"DONE" forState:UIControlStateNormal];

    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
