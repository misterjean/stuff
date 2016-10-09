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
@synthesize localVideoLocation;
@synthesize localThumbnailData;

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
                [delegate startingToUploadVideoFiles];
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


- (void)initialize
{
    videoFilesUpdatesDelegates = [[NSMutableArray alloc] init];
}

- (void) dealloc
{
    videoProgressTimer = nil;
    thumbnailProgressTimer = nil;
    videoUploadCallback = nil;
    
    [self setVideoImageFile:nil];
    [self setVideoMovieFile:nil];
    
    [self setLocalVideoLocation:nil];
    [self setLocalThumbnailData:nil];
    [self setVideoFilesUpdatesDelegates:nil];
}

//Required CCVideoFiles methods
+ (id<CCVideoFiles>) createNewVideoFilesWithName:(NSString *)name mediaSource:(ccMediaSources)mediaSource andVideoPath:(NSString *)videoPath
{    
    PFObject *newVideoFile = [PFObject objectWithClassName:@"VideoFile"];
    
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName] hasSuffix:@"s"])
        name = [NSString stringWithFormat:@"%@' Video",[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName]];
    else
        name = [NSString stringWithFormat:@"%@'s Video",[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName]];
    
    [newVideoFile setObject:[PFFile fileWithName:[NSString stringWithFormat:@"%@.MOV",[self alphaNumbericStringWithString:name]] contentsAtPath:videoPath] forKey:@"video"];
    
    NSData *videoImageData = [self generateThumbnailWithVideoPath:videoPath];
    
    [newVideoFile setObject:[PFFile fileWithName:[NSString stringWithFormat:@"%@.jpeg", [self alphaNumbericStringWithString:name]] data:videoImageData] forKey:@"videoThumbnail"];
    
    CCParseVideoFiles *newCCVideoFiles = [[CCParseVideoFiles alloc] initWithServerData:newVideoFile];
    
    [newCCVideoFiles setLocalVideoLocation:videoPath];
    
    [newCCVideoFiles setLocalThumbnailData:videoImageData];
    
    [newCCVideoFiles setVideoMediaSource:mediaSource];
    
    return newCCVideoFiles;
}

- (NSError *) testUploadForErrors
{
    NSError *rerror = nil;
    NSURLResponse *response = nil;
    
    NSURL *url = [NSURL URLWithString:[self getVideoMovieFileURL]];
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
                NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"%@: has no data", [self getVideoMovieFileURL]];
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

    videoUploadCallback = [block copy];
    
    [self notifyListenersThatUploadIsStarting];
    
    @try 
    {
        [[[self parseObject] objectForKey:@"video"] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            NSError *uploadError = [self testUploadForErrors];
            
            if (!succeeded || uploadError)
            {
                if (uploadError)
                    error = uploadError;
                
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload video movie file: %@", [error localizedDescription]];
                
                OSAtomicTestAndClear(YES, &isUploading);
                
                if (block)
                    block(NO,error);            
            }
            else 
            {                
                [[[self parseObject] objectForKey:@"videoThumbnail"] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                {
                    if (!succeeded)
                    {
                        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload videoImage file: %@", [error localizedDescription]];
                       
                        OSAtomicTestAndClear(YES, &isUploading);
                       
                        if (block)
                           block(NO,error);
                    }
                    else 
                    {
                        [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error)
                        {
                            if (!succeeded)
                            {
                                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload videoFile: %@", [error localizedDescription]];
                                
                                OSAtomicTestAndClear(YES, &isUploading);
                                
                                if (block)
                                    block(NO,error);
                            }
                            else 
                            {
                                
                                OSAtomicTestAndClear(YES, &isUploading);
                                
                                if (block)
                                    block(YES,nil);
                            }
                        }];
                    }
                }];
            }
        } progressBlock:^(int percentDone)
         {
             [self notifyListenersThatUploadIsAtPercent:percentDone];
         }];
    }
    @catch (NSException *exception)
    {        
        NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"%@: %@", [exception description], [exception reason]];
        NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedDescriptionKey,  descriptiveErrorString, nil];
        NSError *error = [[NSError alloc] initWithDomain:NSUnderlyingErrorKey code:0 userInfo:errorDictionary];
        
        if (block)
            block(NO,error);
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
    [imageGenerator setAppliesPreferredTrackTransform:YES];
    CGImageRef capturedImage = [imageGenerator copyCGImageAtTime:capturePoint actualTime:&actualTime error:&error];
    imageForUse = [[UIImage alloc] initWithCGImage:capturedImage];
    CGImageRelease(capturedImage);
    return UIImageJPEGRepresentation(imageForUse, 0.1);
}
     
- (BOOL) isUploading
{
    return isUploading;
}

- (void) cancelUpload
{
    if (!isUploading)
        return;
    
    if (videoMovieFile)
        [videoMovieFile cancel];
    
    if (videoImageFile)
        [videoImageFile cancel];
    
    OSAtomicTestAndClear(YES, &isUploading);
}

 - (NSString *) getVideoMovieFileURL
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [(PFFile *)[[self parseObject] objectForKey:@"video"] url];
}

- (NSString *) getVideoImageFileURL
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [(PFFile *)[[self parseObject] objectForKey:@"videoThumbnail"] url];
}

- (NSString *) getVideoMovieFileName
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [(PFFile *)[[self parseObject] objectForKey:@"videoThumbnail"] name];
}

- (NSString *) getVideoImageFileName
{
    [self checkForParseDataAndThrowExceptionIfNil];

    return [(PFFile *)[[self parseObject] objectForKey:@"video"] name];
}

@end
