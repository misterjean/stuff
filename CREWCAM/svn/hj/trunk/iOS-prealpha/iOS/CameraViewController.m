//
//  CameraViewController.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import "MainTabBarViewController.h"
@interface CameraViewController ()

@end

@implementation CameraViewController

@synthesize cameraOrientation;

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
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setCameraOrientation:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (BOOL) startCameraControllerFromViewController {
    
    /*if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;*/
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    
    cameraUI.delegate = self;
    
    
    [self setCameraOrientation:[MainTabBarViewController getVideoOrientation]];
    [self presentModalViewController: cameraUI animated: YES];
    return YES;
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    // Handle a movie capture
    NSString *moviePath = [[info objectForKey:
                            UIImagePickerControllerMediaURL] path];
    
    printf("\n\nPath: %s\n\n", moviePath.UTF8String);
    [self dismissModalViewControllerAnimated: NO];
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    //[self 
    PostVideoForumViewController *forumVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"forumView"];
    forumVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    forumVC.modalPresentationStyle = UIModalPresentationFormSheet;
    forumVC.moviePath = moviePath; 
    forumVC.orientation = [self cameraOrientation];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
        UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
    }
    
    [self presentViewController:forumVC animated:NO completion:nil];
    
}

- (void) imagePickerControllerDidCancel : (UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarHidden :NO];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)recordButton:(id)sender {
    
    [self startCameraControllerFromViewController];    
}
@end
