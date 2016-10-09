//
//  CCCameraRecorder.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-27.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CCCameraRecorderDelegate
@required
-(void) recordingDidBegin;
-(void) recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error;
@end

@interface CCCameraRecorder : NSObject <AVCaptureFileOutputRecordingDelegate>
{
    AVCaptureMovieFileOutput        *movieFileOutput;
    AVCaptureSession                *session;
}

@property (strong, nonatomic) id<NSObject, CCCameraRecorderDelegate> delegate;

- (id) initWithSession:(AVCaptureSession *)aSession;
-(BOOL) recordsVideo;
-(BOOL) recordsAudio;
-(BOOL) isRecording;
-(void)startRecordingWithOrientation:(AVCaptureVideoOrientation) videoOrientation toUrl:(NSURL *) anOutputURL;
- (void) stopRecording;
@end
