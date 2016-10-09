//
//  CCCameraController.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-27.
//
//

#import "CCCameraController.h"

@implementation CCCameraController
@synthesize backgroundRecordingID;
@synthesize delegate; //This was required for some reason, not sure if you need it

- (id) initWithPreviewView:(UIView *) previewView
{
    self = [super init];
    
    if (!self)
        return nil;
    
    videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    
    captureSession = [[AVCaptureSession alloc] init];
    
	if ([captureSession canAddInput:videoInput]) {
        [captureSession addInput:videoInput];
    }
    if ([captureSession canAddInput:audioInput]) {
        [captureSession addInput:audioInput];
    }
    
    cameraRecorder = [[CCCameraRecorder alloc] initWithSession:captureSession];
    [cameraRecorder setDelegate:self];
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
	[previewLayer setFrame:previewView.frame];
    
	[previewView.layer addSublayer:previewLayer];
    
    return self;
}

- (void) startPreview
{
    [captureSession startRunning];
}

- (void) stopPreview
{
    [captureSession stopRunning];
}

- (void) startNewRecording
{
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns
        // to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library
        // when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error:
        // after the recorded file has been saved.
        [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}]];
    }

    // Delete the last temporary file
    NSString *filePath = [[self tempFileURL] path];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO)
        {
        
        }
    }
    
    [cameraRecorder startRecordingWithOrientation:AVCaptureVideoOrientationPortrait toUrl:[self tempFileURL]];
}
- (void) stopRecording
{
    [cameraRecorder stopRecording];
}

- (BOOL) isRecording
{
    return [cameraRecorder isRecording];
}

- (void) toggleCamera
{
    NSError *error;
    AVCaptureDeviceInput *newVideoInput;
    AVCaptureDevicePosition position = [[videoInput device] position];
    
    if (position == AVCaptureDevicePositionBack)
        newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
    else if (position == AVCaptureDevicePositionFront)
        newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
    
    if (newVideoInput != nil) {
        
        [captureSession beginConfiguration];
        
        [captureSession removeInput:videoInput];
        
        if ([captureSession canAddInput:newVideoInput])
        {
            [captureSession addInput:newVideoInput];
            
            videoInput = newVideoInput;
        }
        else
        {
            [captureSession addInput:videoInput];
        }
        
        [captureSession commitConfiguration];
    }
}
- (BOOL) isMultipleCamerasAvailable
{
    return ([self frontFacingCamera] && [self backFacingCamera]);
}

- (void) toggleFlash
{
    if ([[self backFacingCamera] hasFlash])
    {
        if ([[self backFacingCamera] lockForConfiguration:nil])
        {
            [self backFacingCamera].flashMode = ![self backFacingCamera].flashMode;
        
            [[self backFacingCamera] unlockForConfiguration];
        }
    }
    
    if ([[self backFacingCamera] hasTorch])
    {
        if ([[self backFacingCamera] lockForConfiguration:nil])
        {
            [self backFacingCamera].torchMode = ![self backFacingCamera].torchMode;
            
            [[self backFacingCamera] unlockForConfiguration];
        }
    }
}

- (BOOL) isFlashAvailable
{
    return ([[self backFacingCamera] hasTorch] || [[self backFacingCamera] hasFlash]);
}

/* Utility functions */
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    
    return nil;
}

- (NSURL *) tempFileURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"]];
}

/* Delegate functions */
-(void)recordingDidBegin
{
    if ([[self delegate] respondsToSelector:@selector(didBeginRecording)]) {
        [[self delegate] didBeginRecording];
    }
}

-(void)recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error
{
    if ([[self delegate] respondsToSelector:@selector(didFinishRecordingWithError:andOutputFileURL:)]) {
        [[self delegate] didFinishRecordingWithError:error andOutputFileURL:outputFileURL];
    }
}

@end
