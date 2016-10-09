//
//  CCCameraRecorder.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-27.
//
//

#import "CCCameraRecorder.h"

@implementation CCCameraRecorder
@synthesize delegate;

#warning Limit to 90 seconds (or whatever)
- (id) initWithSession:(AVCaptureSession *)aSession
{
    self = [super init];
    if (self != nil) {
        movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];

        if ([aSession canAddOutput:movieFileOutput])
            [aSession addOutput:movieFileOutput];
        
        session = aSession;
        
        if ([session canSetSessionPreset:AVCaptureSessionPresetLow])
            [session setSessionPreset:AVCaptureSessionPresetLow];
    }
    
    return self;
}

-(BOOL)recordsVideo
{
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[movieFileOutput connections]];
    return [videoConnection isActive];
}

-(BOOL)recordsAudio
{
    AVCaptureConnection *audioConnection = [self connectionWithMediaType:AVMediaTypeAudio fromConnections:[movieFileOutput connections]];
    return [audioConnection isActive];
}

-(BOOL) isRecording
{
    return [movieFileOutput isRecording];
}

-(void)startRecordingWithOrientation:(AVCaptureVideoOrientation) videoOrientation toUrl:(NSURL *) anOutputURL
{
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[movieFileOutput connections]];
    
    if ([videoConnection isVideoOrientationSupported])
        [videoConnection setVideoOrientation:videoOrientation];
    
    [movieFileOutput startRecordingToOutputFileURL:anOutputURL recordingDelegate:self];
}

-(void)stopRecording
{
    [movieFileOutput stopRecording];
}

/* Utility functions */
 
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [[port mediaType] isEqual:mediaType] ) {
                return connection;
            }
        }
    }
    return nil;
}

- (void)             captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                   fromConnections:(NSArray *)connections
{
    if ([[self delegate] respondsToSelector:@selector(recordingDidBegin)]) {
        [[self delegate] recordingDidBegin];
    }
}

- (void)              captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)anOutputFileURL
                    fromConnections:(NSArray *)connections
                              error:(NSError *)error
{
#warning Handle errors
    if ([[self delegate] respondsToSelector:@selector(recordingDidFinishToOutputFileURL:error:)]) {
        [[self delegate] recordingDidFinishToOutputFileURL:anOutputFileURL error:error];
    }
}

@end
