//
//  CCCameraController.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-27.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CCCameraRecorder.h"

@protocol CCCameraControllerDelegate <NSObject>

@optional
- (void) didBeginRecording;
- (void) didFinishRecordingWithError:(NSError *) error andOutputFileURL:(NSURL *) anOutputURL;

@end

@interface CCCameraController : NSObject <CCCameraRecorderDelegate>
{
    AVCaptureSession                *captureSession;
    AVCaptureVideoPreviewLayer      *previewLayer;
    
    AVCaptureDeviceInput            *videoInput;
    AVCaptureDeviceInput            *audioInput;
    
    CCCameraRecorder                *cameraRecorder;
}
@property (strong, nonatomic) id<CCCameraControllerDelegate>    delegate;
@property (nonatomic, assign) UIBackgroundTaskIdentifier        backgroundRecordingID;

- (id) initWithPreviewView:(UIView *) previewView;

- (void) startPreview;
- (void) stopPreview;

- (void) startNewRecording;
- (void) stopRecording;
- (BOOL) isRecording;

- (void) toggleCamera;
- (BOOL) isMultipleCamerasAvailable;
- (void) toggleFlash;
- (BOOL) isFlashAvailable;

@end
