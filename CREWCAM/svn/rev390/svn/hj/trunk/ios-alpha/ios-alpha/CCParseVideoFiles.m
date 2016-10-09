//
//  CCParseVideoFiles.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseVideoFiles.h"

@implementation CCParseVideoFiles
@synthesize videoImageFile;
@synthesize videoMovieFile;
@synthesize videoFilesUpdatesDelegates;
@synthesize videoMediaSource;

- (void) addVideoFilesUpdateListener:(id<CCVideoUpdatesDelegate>) delegate
{
    @synchronized(videoFilesUpdatesDelegates)
    {
        if (![videoFilesUpdatesDelegates containsObject:delegate])
            [videoFilesUpdatesDelegates addObject:delegate];
    }
}

- (void) removeVideoFilesUpdateListener:(id<CCVideoUpdatesDelegate>) delegate
{
    @synchronized(videoFilesUpdatesDelegates)
    {
        if ([videoFilesUpdatesDelegates containsObject:delegate])
            [videoFilesUpdatesDelegates removeObject:delegate];    
    }
}

- (void) notifyListenersThatUploadIsStarting
{
    @synchronized(videoFilesUpdatesDelegates)
    {
        for (id<CCVideoFilesUpdatesDelegate> delegate in videoFilesUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(startingToUploadVideoFiles)])
                [delegate startingToUplaodVideoFiles];
        }
    }
}

- (void) notifyListenersThatUploadIsCompleteWithSuccess:(BOOL) successful error:(NSError *) error
{
    @synchronized(videoFilesUpdatesDelegates)
    {
        for (id<CCVideoFilesUpdatesDelegate> delegate in videoFilesUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(finishedUploadingVideoFilesWithSucces:error:andVideoFilesReference:)])
                [delegate finishedUploadingVideoFilesWithSucces:successful error:error andVideoFilesReference:self];
        }
    }
}

- (void) notifyListenersThatUploadIsAtPercent:(int) percent
{
    @synchronized(videoFilesUpdatesDelegates)
    {
        for (id<CCVideoFilesUpdatesDelegate> delegate in videoFilesUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(videoFilesUploadProgressIsAtPercent:)])
                [delegate videoFilesUploadProgressIsAtPercent:percent];
        }
    }
}

//Required CCVideoFiles methods
+ (id<CCVideoFiles>) createNewVideoFilesWithName:(NSString *)name mediaSource:(ccMediaSources)mediaSource delegate:(id<CCVideoFilesUpdatesDelegate>)delegate andVideoPath:(NSString *)videoPath
{
    
    CCParseVideoFiles *newCCVideoFiles = [[CCParseVideoFiles alloc] init];
    
    newCCVideoFiles->videoFilesUpdatesDelegates = [[NSMutableArray alloc] init];
    
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName] hasSuffix:@"s"])
        name = [NSString stringWithFormat:@"%@' Video",[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName]];
    else
        name = [NSString stringWithFormat:@"%@'s Video",[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName]];
    
    
    [newCCVideoFiles setVideoMovieFile:[PFFile fileWithName:[NSString stringWithFormat:@"%@.MOV",[self alphaNumbericStringWithString:name]] contentsAtPath:videoPath]];
    
    NSData *videoImageData = [self generateThumbnailWithVideoPath:videoPath];

    [newCCVideoFiles setVideoImageFile:[PFFile fileWithName:[NSString stringWithFormat:@"%@.jpeg", [self alphaNumbericStringWithString:name]] data:videoImageData]];
     
    [newCCVideoFiles setVideoMediaSource:mediaSource];
    
    [newCCVideoFiles addVideoFilesUpdateListener:delegate];
    
    return newCCVideoFiles;
}

- (NSError *) testUploadForErrors
{
    NSError *rerror = nil;
    NSURLResponse *response = nil;
    
    NSURL *url = [NSURL URLWithString:[[self videoMovieFile] url]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&rerror];
    
    if ([response isMemberOfClass:[NSHTTPURLResponse class]] || rerror ) {
        
        if ([[[((NSHTTPURLResponse *)response) allHeaderFields] objectForKey:@"Content-Length"] intValue] == 0  || rerror)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"All Header Fields: %@", [((NSHTTPURLResponse *)response) allHeaderFields]];
            
            NSError *error;
            
            if (rerror)
            {
                error = rerror;
            }
            else 
            {
                NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"%@: has no data", [[self videoMovieFile] url]];
                NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedDescriptionKey,  descriptiveErrorString, nil];
                error = [[NSError alloc] initWithDomain:NSUnderlyingErrorKey code:0 userInfo:errorDictionary]; 
            }
            
            return error;
        }
        
    }
    return nil;

}

- (void) uploadAndSaveInBackgroundWithBlock:(CCBooleanResultBlock)block
{
    OSAtomicTestAndSet(YES, &isUploading);
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground) 
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredForeground) 
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    videoProgressTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(videoUploadTimeout:) userInfo:[block copy] repeats:NO];
    
    [self notifyListenersThatUploadIsStarting];
    @try 
    {
        [[self videoMovieFile] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
            
            [self invalidateUploadTimer];
            
            NSError *uploadError = [self testUploadForErrors];
            
            if (!succeeded || uploadError)
            {
                if (uploadError)
                    error = uploadError;
                
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload video movie file: %@", [error localizedDescription]];
                
                OSAtomicTestAndClear(YES, &isUploading);
                
                if (block)
                    block(NO,error);
                
                [self notifyListenersThatUploadIsCompleteWithSuccess:NO error: error];
            }
            else 
            {
                [[self videoImageFile] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                {
                   if (!succeeded)
                   {
                       [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload videoImage file: %@", [error localizedDescription]];
                       
                       OSAtomicTestAndClear(YES, &isUploading);
                       
                       if (block)
                           block(NO,error);
                       
                       [self notifyListenersThatUploadIsCompleteWithSuccess:NO error: error];   
                   }
                   else 
                   {
                       OSAtomicTestAndClear(YES, &isUploading);
                       
                       if (block)
                           block(YES,nil);
                       
                       [self notifyListenersThatUploadIsCompleteWithSuccess:YES error:nil];
                   }
                        
                }];
            }
            
        } progressBlock:^(int percentDone)
         {
             [self invalidateUploadTimer];
             videoProgressTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(videoUploadTimeout:) userInfo:[block copy] repeats:NO];
             
             [self notifyListenersThatUploadIsAtPercent:percentDone];
             
         }];
    }
    @catch (NSException *exception)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        [self invalidateUploadTimer];
        
        NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"%@: %@", [exception description], [exception reason]];
        NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedDescriptionKey,  descriptiveErrorString, nil];
        NSError *error = [[NSError alloc] initWithDomain:NSUnderlyingErrorKey code:0 userInfo:errorDictionary];
        
        if (block)
            block(NO,error);
        
        [self notifyListenersThatUploadIsCompleteWithSuccess:NO error: error];
    }     
}

//Helper Methods                                        
+ (NSString *) alphaNumbericStringWithString:(NSString *) string
{
    NSCharacterSet *nonalphanumericSet = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
    NSString *alphaNumericString =  [[string componentsSeparatedByCharactersInSet:nonalphanumericSet] componentsJoinedByString:@""];
    if([alphaNumericString length] == 0)
    {
        alphaNumericString = @"";
    }
    return alphaNumericString;
}
     
 
+ (NSData *)generateThumbnailWithVideoPath:(NSString *)thumbnailVideoPath
{
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:thumbnailVideoPath] options:nil];
    
    Float64 durationSeconds = CMTimeGetSeconds([videoAsset duration]);
    
    CMTime capturePoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    CMTime actualTime;
    UIImage *imageForUse;
    NSError *error;
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    CGImageRef capturedImage = [imageGenerator copyCGImageAtTime:capturePoint actualTime:&actualTime error:&error];
    imageForUse = [[UIImage alloc] initWithCGImage:capturedImage scale:(CGFloat)1.0 orientation:(UIImageOrientation)UIImageOrientationRight];
    CGImageRelease(capturedImage);
    return UIImageJPEGRepresentation(imageForUse, 0.1);
}
     
- (BOOL) isUploading
{
    return isUploading;
}

- (void) invalidateUploadTimer
{
    if (videoProgressTimer != nil)
    {
        [videoProgressTimer invalidate];
        videoProgressTimer = nil;
    }
}

-(void) videoUploadTimeout:(NSTimer *)timer
{
    if (videoProgressTimer == nil)
    {
        //For some reason on occasion this videoProgressTimeout will fire even though the timer is nil. This catches that.
        return;
    }
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    CCBooleanResultBlock block = timer.userInfo;
    
    //Stops timer
    [self invalidateUploadTimer];
    //Video hasn't made progress in over ten seconds. Assuming failure and tearing down.
    [videoMovieFile cancel];
    NSDictionary *errorDetail;
    [errorDetail setValue:@"Network timeout." forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"crewc.am" code:100 userInfo:errorDetail];
    
    OSAtomicTestAndClear(YES, &isUploading);
    
    if (block)
        block(NO,error);
    
    [self notifyListenersThatUploadIsCompleteWithSuccess:NO error:error];
}

-(void) handleEnteredBackground
{
    if ([self isUploading])
    {
        [self invalidateUploadTimer];
    }
}

-(void) handleEnteredForeground
{
    if ([self isUploading])
    {
        [self invalidateUploadTimer];
        videoProgressTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(videoUploadTimeout:) userInfo:nil repeats:NO];
    }
}

@end
