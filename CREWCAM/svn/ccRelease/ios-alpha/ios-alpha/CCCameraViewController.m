//
//  CCCameraViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-27.
//
//

#import "CCCameraViewController.h"

@interface CCCameraViewController ()

@end

@implementation CCCameraViewController
@synthesize cameraView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.view addCrewcamTitleToViewController:@"Record"];
    
    cameraController = [[CCCameraController alloc] initWithPreviewView:cameraView];
    [cameraController setDelegate:self];
    
    if (![cameraController isMultipleCamerasAvailable])
    {
        // Hide button
    }
    
    if (![cameraController isFlashAvailable])
    {
        // Hide button
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [cameraController startPreview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecordButtonPressed) name:CC_CLICKED_RECORD_TAB_BAR_ITEM object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [cameraController stopPreview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onBackButtonPressed
{
    
}

- (void) onRecordButtonPressed
{
    if (![cameraController isRecording])
    {
        [cameraController startNewRecording];
    }
    else
    {
        [cameraController stopRecording];
    }
}

#warning complete this unload
- (void)viewDidUnload
{
    [self setCameraView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)didPressLibraryButton:(id)sender {
    [cameraController stopPreview];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    
    if (!mediaBrowserVC)
        mediaBrowserVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mediaBrowserViewController"];
    
    [[self navigationController] pushViewController:mediaBrowserVC animated:YES];
}

- (IBAction)didPressFlashButton:(id)sender {
    [cameraController toggleFlash];
}

- (IBAction)didPressCameraButton:(id)sender {
    [cameraController toggleCamera];    
}

- (void) didFinishRecordingWithError:(NSError *) error andOutputFileURL:(NSURL *) anOutputURL
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    
    if (!forumVC)
        forumVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PostVideoForumView"];
    
    [forumVC setVideoPath:[anOutputURL path]];
    [forumVC setMediaSource:ccCamera];
    [forumVC setStoredNavigationController:self];
    
    UISaveVideoAtPathToSavedPhotosAlbum([anOutputURL path], nil, nil, nil);
    
    [self presentViewController:forumVC animated:YES completion:nil];
}

@end
