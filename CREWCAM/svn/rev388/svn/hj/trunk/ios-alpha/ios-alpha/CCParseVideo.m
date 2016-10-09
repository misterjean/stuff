//
//  CCParseVideo.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseVideo.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

@implementation CCParseVideo

// CCVideo properties
@synthesize ccUsersThatViewed;
@synthesize ccComments;      
@synthesize videoThumbnail;
@synthesize wasVideoAddedLocally;
@synthesize isNewVideo;
@synthesize videoMediaSource;

// CCParseVideo helper methods
- (void) notifyListenersThatViewersAreAboutToBeLoaded
{
    @synchronized(videoUpdatesDelegates)
    {        
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(startingToLoadViewers)])
                [delegate startingToLoadViewers];
        }
    }
}

- (void) notifyListenersThatViewersHaveLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(finishedLoadingViewersWithSuccess:andError:)])
                [delegate finishedLoadingViewersWithSuccess:success andError:error];
        }
    }        
}

- (void) notifyListenersThatViewersHaveBeenAdded:(NSArray *) newViewIndexes andRemovedAtIndexes:(NSArray *) deletedViewIndexes
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(addedNewViewsAtIndexes:andRemovedViewsAtIndexes:)])
                [delegate addedNewViewsAtIndexes:newViewIndexes andRemovedViewsAtIndexes:deletedViewIndexes];
        }
    }
}

- (void) notifyListenersThatUploadIsStarting
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(startingToUploadVideo)])
                [delegate startingToUploadVideo];
        }
    }
}

- (void) notifyListenersThatUploadIsCompleteWithSuccess:(BOOL) successful error:(NSError *) error andVideoReference:(id<CCVideo>)video;
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(finishedUploadingVideoWithSuccess:error:andVideoReference:)])
                [delegate finishedUploadingVideoWithSuccess:successful error:error andVideoReference:video];
        }
    }
}

- (void) notifyListenersThatUploadIsAtPercent:(int) percent
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(videoUploadProgressIsAtPercent:)])
                [delegate videoUploadProgressIsAtPercent:percent];
        }
    }
}

- (void) notifyListenersThatCommentsAreAboutToBeLoaded
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(startingToLoadComments)])
                [delegate startingToLoadComments];
        }
    }
}

- (void) notifyListenersThatCommentsHaveLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(finishedLoadingCommentsWithSuccess:andError:)])
                [delegate finishedLoadingCommentsWithSuccess:success andError:error];
        }
    }
}


- (void) notifyListenersThatCommentsHaveBeenAddedAtIndexes:(NSArray *) newCommentIndexes andRemovedAtIndexes:(NSArray *) deletedCommentIndexes
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(addedNewCommentsAtIndexes:andRemovedCommentsAtIndexes:)])
                [delegate addedNewCommentsAtIndexes:newCommentIndexes andRemovedCommentsAtIndexes:deletedCommentIndexes];
        }
    }
}

- (void) notifyListenersThatThumbnailIsAboutToBeLoaded
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(startingToLoadThumbnail)])
                [delegate startingToLoadThumbnail];
        }
    }
}

- (void) notifyListenersThatThumbnailHasBeenLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(finishedLoadingThumbnailWithSucess:andError:)])
                [delegate finishedLoadingThumbnailWithSucess:success andError:error];
        }
    }
}

static NSString *className = @"Video";

// Optional CCServerStoredObject methods
- (void) purgeRelatedDataInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    
}

// Required CCServerStoredObject methods
- (void)initialize
{
    isLodingThumbnail = NO;
    isLoadingViews = NO;
    isLoadingComments = NO;
    isUploading = NO;
    uploadPercentComplete = 0;
    isNewVideo = CCStatusUnknown;
    [self setWasVideoAddedLocally:NO];
    [self setCcUsersThatViewed:[[NSMutableArray alloc] init]];
    [self setCcComments:[[NSMutableArray alloc] init]];
    [self setVideoUpdatesDelegates:[[NSMutableArray alloc] init]];
}


- (void)pullObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    OSAtomicTestAndSet(YES, &isObjectBusy);
    [super pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            OSAtomicTestAndSet(YES, &isObjectBusy);
            [[(CCParseUser *)[self getTheOwner] parseObject] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                if(!error)
                {
                    if (block)
                        block(YES,error);
                }
                else 
                {
                    if (block)
                        block(NO,error);
                }
                
                OSAtomicTestAndClear(YES, &isObjectBusy);
                
            }] ;
        }
        else 
        {
            if (block)
                block(NO,error);
        }
    }];
}

// Required CCVideo methods
+ (id<CCVideo>) createNewVideoInBackgroundWithName:(NSString *)name creator:(id<CCUser>)creator videoPath:(NSString *)videoPath delegate:(id<CCVideoUpdatesDelegate>)delegate mediaSource:(ccMediaSources)mediaSource withBlock:(CCVideoResultBlock)block
{   
    name = [self alphaNumbericStringWithString:name];
    
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName] hasSuffix:@"s"])
        name = [NSString stringWithFormat:@"%@' Video",[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName]];
    else
        name = [NSString stringWithFormat:@"%@'s Video",[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName]];
    
    // Read the duration
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];        
    AVAssetTrack* videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    Float64 durationSeconds = CMTimeGetSeconds([videoAsset duration]);
    
#if 0
    //This if block is not used. It should be used if we ever decide to do our own compression.
    if(FALSE)
    {
        //For high def video's from the library longer then 30 seconds we have to compress to lowQuality.
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Tried to upload a HD video longer then 30 seconds. Compressing to LowQuality to keep under the 10Mb limit"];
        
        [self convertVideoToLowQuailtyWithInputURL:[NSURL fileURLWithPath:videoPath] outputURL:[NSURL fileURLWithPath:videoPath] handler:^(AVAssetExportSession *exportSession)
         {
             if (exportSession.status == AVAssetExportSessionStatusCompleted)
             {
                 printf("completed\n");
             }
             else
             {
                 printf("error\n");
                 
             }
         }];
        
        
    }
#endif  
    
    PFObject *newVideo = [PFObject objectWithClassName:@"Video"];                     
    [newVideo setObject:name forKey:@"videoName"];                     
    [newVideo setObject:[creator getServerData] forKey:@"theOwner"];  
    [newVideo setObject:[NSNumber numberWithInt:0] forKey:@"viewedByCount"];                                          
    [newVideo setObject:[NSNumber numberWithInt:0] forKey:@"commentsCount"];  
    
    [newVideo setObject:[NSNumber numberWithFloat:durationSeconds] forKey:@"duration"];
    
    // Look for the transform
    if ([[videoAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0)
    {
        CGAffineTransform txf = [videoTrack preferredTransform];
        if (txf.a == 1)
        {
            [newVideo setObject:[NSNumber numberWithInt:90] forKey:@"transformDegrees"];
        }
        else
        {
            [newVideo setObject:[NSNumber numberWithInt:0] forKey:@"transformDegrees"];
        }
    }
    
    CCParseVideo *newCCVideo = [[CCParseVideo alloc] initWithServerData:newVideo];
    [newCCVideo addVideoUpdateListener:delegate];
    newCCVideo->videoMediaSource = mediaSource;
    newCCVideo->videoPath = videoPath;
    
    @try {
        [newCCVideo uploadAndSaveInBackgroundWithBlock:block];  
        
        return newCCVideo;
    }
    @catch (NSException *exception) 
    {
        NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"%@: %@", [exception description], [exception reason]];
        NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedDescriptionKey,  descriptiveErrorString, nil];
        NSError *error = [[NSError alloc] initWithDomain:NSUnderlyingErrorKey code:0 userInfo:errorDictionary];
        
        [delegate finishedUploadingVideoWithSuccess:NO error:error andVideoReference:newCCVideo];
        block(nil, NO, error);
    }
}

// This function is not used. It should be used if we ever decide to do our own compression.
#if 0
+ (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) 
     {
         handler(exportSession);
     }];
}
#endif
- (void) uploadAndSaveInBackgroundWithBlock:(CCVideoResultBlock) block
{
    OSAtomicTestAndSet(YES, &isUploading);
    
    videoResultblock = block;
    
    [self setWasVideoAddedLocally:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground) 
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredForeground) 
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    videoProgressTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(videoUploadTimeout:) userInfo:nil repeats:NO];
    
    [self notifyListenersThatUploadIsStarting];
    
    
    PFFile *tempVideo = [PFFile fileWithName:[NSString stringWithFormat:@"%@.MOV", [CCParseVideo alphaNumbericStringWithString:[self getName]]] contentsAtPath:videoPath];
    
    videoFileForUpload = tempVideo;
    @try 
    {
        [tempVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
             [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
             if (error) 
             {
                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload video file: %@", [error localizedDescription]];
                 
                 OSAtomicTestAndClear(YES, &isUploading);
                 
                 if (videoResultblock)
                     videoResultblock(self,NO,error);
                 
                 [self notifyListenersThatUploadIsCompleteWithSuccess:NO error: error andVideoReference:self];
             }
             else 
             {
                 [videoProgressTimer invalidate];
                 videoProgressTimer = nil;
                 NSData *videoImageData = [self generateThumbnailWithVideoPath:videoPath];             
                 PFFile *videoImageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpeg", [CCParseVideo alphaNumbericStringWithString:[self getName]]] data:videoImageData];
                 
                 [videoImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
                  {
                      if (error)
                      {
                          [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload videoImage file: %@", [error localizedDescription]];
                          
                          OSAtomicTestAndClear(YES, &isUploading);
                          
                          if (videoResultblock)
                              videoResultblock(self,NO,error);
                          
                          [self notifyListenersThatUploadIsCompleteWithSuccess:NO error: error andVideoReference:self];
                      }
                      else
                      {                     
                          [[self parseObject] setObject:tempVideo forKey:@"videoFile"];                     
                          [[self parseObject] setObject:videoImageFile forKey:@"videoThumbnail"];                     
                          
                          CLLocation *currentLocation = [[[CCCoreManager sharedInstance] locationManager] getCurrentLocation];
                          PFGeoPoint *pfLocation = [PFGeoPoint geoPointWithLatitude:[currentLocation coordinate].latitude longitude:[currentLocation coordinate].longitude];
                          [[self parseObject] setObject:pfLocation forKey:@"locatedAt"];
                          
                          [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
                           {
                               if(error)
                               {
                                   OSAtomicTestAndClear(YES, &isUploading);
                                   if (videoResultblock)
                                       videoResultblock(self,NO,error);
                                   
                                   [self notifyListenersThatUploadIsCompleteWithSuccess:NO error: error andVideoReference:self];
                               }
                               else
                               {
                                   
                                   [self pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
                                    {
                                        OSAtomicTestAndClear(YES, &isUploading);                                   
                                        if (error)
                                        {
                                            if (videoResultblock)
                                                videoResultblock(self,NO,error);
                                            
                                            [self notifyListenersThatUploadIsCompleteWithSuccess:NO error: error andVideoReference:self];
                                        }
                                        else
                                        {
                                            //In this block the new video will be added to the correct crews
                                            [self notifyListenersThatUploadIsCompleteWithSuccess:YES error: nil andVideoReference:self];;
                                            if (videoResultblock)
                                                videoResultblock(self, succeeded, error); 
                                        }
                                    }];
                               }
                           }];
                      }
                  }];
                 
             }
             
         } progressBlock:^(int percentDone) 
         {   
             [videoProgressTimer invalidate];
             videoProgressTimer = nil;
             videoProgressTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(videoUploadTimeout:) userInfo:nil repeats:NO];
             
             uploadPercentComplete = percentDone;
             [self notifyListenersThatUploadIsAtPercent:percentDone];
         }];
    }
    
    @catch (NSException *exception) {
        NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"%@: %@", [exception description], [exception reason]];
        NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedDescriptionKey,  descriptiveErrorString, nil];
        NSError *error = [[NSError alloc] initWithDomain:NSUnderlyingErrorKey code:0 userInfo:errorDictionary];
        
        [self notifyListenersThatUploadIsCompleteWithSuccess:NO error: error andVideoReference:self];
        block(nil, NO, error);
    }    
}

+ (void) loadSingleVideoInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCVideoResultBlock)block
{
    PFQuery *videoQuery = [PFQuery queryWithClassName:@"Video"];
    
    [videoQuery getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        id<CCVideo> videoObject;
        
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load single video: %@", [error localizedDescription]];
        }
        
        if (!objectId)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Couldn't find video matching ID %@", objectId];
        }
        else
        {
            videoObject = [[CCParseVideo alloc] initWithServerData:object];
        }
        
        block(videoObject, !error, error);
    }];
}

-(void) handleEnteredBackground
{
    if ([self isUploading] && videoProgressTimer != nil)
    {
        [videoProgressTimer invalidate];
        videoProgressTimer = nil;
    }
}

-(void) handleEnteredForeground
{
    if ([self isUploading] && videoResultblock != nil)
    {
        videoProgressTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(videoUploadTimeout:) userInfo:nil repeats:NO];
    }
}

-(void) videoUploadTimeout:(NSTimer *)timer
{
    if (videoProgressTimer == nil)
    {
        //For some reason on occasion this videoProgressTimeout will fire even though the timer is nil. This catches that.
        return;
    }
    
    //Stops timer
    [videoProgressTimer invalidate];
    videoProgressTimer = nil;
    //Video hasn't made progress in over ten seconds. Assuming failure and tearing down.
    [videoFileForUpload cancel];
    NSDictionary *errorDetail;
    [errorDetail setValue:@"Network timeout." forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"crewc.am" code:100 userInfo:errorDetail];
        
    OSAtomicTestAndClear( YES, &isUploading);
    videoResultblock(self,NO,error);
    [self notifyListenersThatUploadIsCompleteWithSuccess:NO error:error andVideoReference:self];
}

- (BOOL) notificationReceivedWithData:(NSDictionary *)data
{
    if ([[data objectForKey:@"ID"] isEqualToString:[self getObjectID]])
    {
        if ([[data objectForKey:@"type"] intValue] == CCCommentPush)
        {
            [self loadCommentsInBackgroundWithBlockOrNil:nil];
        }
        else if ([[data objectForKey:@"type"] intValue] == CCViewPush)
        {
            [self loadViewsInBackgroundWithBlockOrNil:nil];
        }
        return true;
    }
    
    return false;
}



- (void) setName:(NSString *) name
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:name forKey:@"videoName"];
}

- (NSString *) getName
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"videoName"];
}

- (BOOL) isUploading
{
    return isUploading;
}

- (int) getUploadPercentComplete
{
    return uploadPercentComplete;
}

@synthesize localCCOwner;
- (id<CCUser>) getTheOwner
{
    if (localCCOwner == nil)
    {
        [self checkForParseDataAndThrowExceptionIfNil];
        localCCOwner = [[CCParseUser alloc] initWithServerData:[[self parseObject] objectForKey:@"theOwner"]];
    }

    return localCCOwner;
}

- (NSString *) getThumbnailURL
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [(PFFile *)[[self parseObject] objectForKey:@"videoThumbnail"] url];
}

- (UIImage *) getThumbnail
{
    return videoThumbnail;
}

- (void) clearThumbnail
{
    videoThumbnail = nil;
}

- (NSString *) getVideoURL
{
    [self checkForParseDataAndThrowExceptionIfNil];

    return [(PFFile *)[[self parseObject] objectForKey:@"videoFile"] url];
}

- (CLLocation *) getVideoLocation
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    PFGeoPoint *videosLocation = [[self parseObject] objectForKey:@"locatedAt"];            
    if (videosLocation == nil)
    {
        return nil;
    }
    
    return [[CLLocation alloc] initWithLatitude:[videosLocation latitude] longitude:[videosLocation longitude]];
}

- (float) getVideoDuration
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"duration"] floatValue];
}

- (void) isVideoNewWithBlockOrNil:(CCIntResultBlock)block
{
    
    PFRelation *viewsForVideoRelation = [[self parseObject] relationforKey:@"viewedBy"];
    
    PFQuery *isVideoNewQuery = [viewsForVideoRelation query];
    [isVideoNewQuery whereKey:@"objectId" equalTo:[[[[CCCoreManager sharedInstance] server] currentUser] getUserID]];
    
    [isVideoNewQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
       if (!error)
       {
           if (number || [[[self getTheOwner] getUserID] isEqualToString:[[[[CCCoreManager sharedInstance] server] currentUser] getUserID]])
           {
               [self setIsNewVideo:CCStatusWatched];
               if (block)
                   block(isNewVideo,YES,nil);
           }
           else
           {    
               [self setIsNewVideo:CCStatusUnwatched];
               if (block)
                   block(isNewVideo,YES,nil);
           }
       }
    }];
}

- (NSInteger) getWatchedStatus
{
    return isNewVideo;
}

- (void) loadThumbnailInBackground
{    
    // Do we already have the thumbnail?
    if (videoThumbnail)
        return;
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Are we already loading it?
    if (OSAtomicTestAndSet(YES, &isLodingThumbnail))
        return;
    
    [self notifyListenersThatThumbnailIsAboutToBeLoaded];
    
    // Start a new thread
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {        
        // Download the image, and set the thumbnail to a new UIImage
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self getThumbnailURL]]];            
        
        UIImage *thumbnailImage = [[UIImage alloc] initWithData:imageData] ;
        
        if ([[[self parseObject] objectForKey:@"transformDegrees"] intValue] != 0)
        {
            thumbnailImage = [UIImage imageWithCGImage:thumbnailImage.CGImage scale:thumbnailImage.scale orientation:UIImageOrientationUp];
        }
        
        [self setVideoThumbnail:thumbnailImage];
        
        // Push a function unto the main thread
        dispatch_async( dispatch_get_main_queue(), ^
        {
            OSAtomicTestAndClear(YES, &isObjectBusy);
            
            [self notifyListenersThatThumbnailHasBeenLoadedWithSuccess:YES andError:nil];
            
            if (OSAtomicTestAndClear(YES, &isLodingThumbnail))
                return;
        });
    });
}

- (void) loadViewsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    if (OSAtomicTestAndSetBarrier(1, &isLoadingViews))        
        return;
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    PFRelation *videosViews = [[self parseObject] relationforKey:@"viewedBy"];
    PFQuery *videosViewsQuery = [videosViews query];
    [videosViewsQuery orderByDescending:@"createdAt"];    
    
    [self notifyListenersThatViewersAreAboutToBeLoaded];
    
    [videosViewsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
    {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load video's views for video %@: %@", [self getObjectID], [error localizedDescription]];                    
        }
        else 
        {
            [self handleNewViews:objects];
        }
        
        OSAtomicTestAndClear(YES, &isObjectBusy);
        
        if (block)
            block((error == nil ? YES : NO), error);
        
        [self notifyListenersThatViewersHaveLoadedWithSuccess:(error == nil ? YES : NO) andError:error];
        
        OSAtomicTestAndClearBarrier(1, &isLoadingViews);                    
    }];        
}

- (void) handleNewViews:(NSArray *) pfObjects
{
    NSMutableArray *allViews = [[NSMutableArray alloc] init];
    NSMutableArray *newViewsIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *oldViewsIndexes = [[NSMutableArray alloc] init];    
    
    for(PFObject *pfView in pfObjects)
    {
        CCParseUser *ccViewer = [[CCParseUser alloc] initWithServerData:pfView];                
        [allViews addObject:ccViewer];
    }    
    

    [self handleNewCCObjects:allViews removedObjectIndexes:oldViewsIndexes addedObjectIndexes:newViewsIndexes finalArrayOfObjects:ccUsersThatViewed];
    
    @synchronized([self parseObject])
    {
        [[self parseObject] setObject:[NSNumber numberWithInt:[ccUsersThatViewed count]] forKey:@"viewedByCount"];
    }
    
    if ([newViewsIndexes count] > 0 || [oldViewsIndexes count] > 0)
        [self notifyListenersThatViewersHaveBeenAdded:newViewsIndexes andRemovedAtIndexes:oldViewsIndexes];
}

- (void) addViewInBackground:(id<CCUser>) viewer withBlockOrNil:(CCBooleanResultBlock) block
{
    switch ([self isNewVideo])
    {
        case CCStatusWatched:
            return;
            break;
        case CCStatusUnwatched:
        {
            [self addViewInBackgroundInner:viewer withBlockOrNil:block];
            break;
        }
        case CCStatusUnknown:
        {
            [self isVideoNewWithBlockOrNil:^(int CCWatchedStatus, BOOL succeded, NSError *error)
            {
                if (succeded)
                {
                    if (CCWatchedStatus == CCStatusUnwatched)
                    {
                        [self addViewInBackgroundInner:viewer withBlockOrNil:block];
                    }
                }
            }];
            break;
        }
            
        default:
            break;
    }
}


- (void) addViewInBackgroundInner:(id<CCUser>) viewer withBlockOrNil:(CCBooleanResultBlock) block
{
    PFObject *viewerObject = [PFUser objectWithoutDataWithClassName:@"_User" objectId:[viewer getObjectID]];
    
    PFRelation *viewersRelation = [[self parseObject] relationforKey:@"viewedBy"];
    
    [viewersRelation addObject:viewerObject];
    [[self parseObject] incrementKey:@"viewedByCount"];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Add the relationship to the existing object
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
     {              
         if (!error)
         {
             [self setIsNewVideo:CCStatusWatched];
             [[self ccUsersThatViewed] insertObject:viewer atIndex:0];
             [self notifyListenersThatViewersHaveBeenAdded:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0] , nil] andRemovedAtIndexes:nil];
             
             NSMutableArray *crewsToNotifyArray = [[NSMutableArray alloc] init];
             
             for (id<CCCrew> currentCrew in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews])
             {
                 if ([CCParseCrew isObjectInArray:self arrayOfCCServerStoredObjects:[currentCrew ccVideos]])
                     [crewsToNotifyArray addObject:[currentCrew getChannelName]];
             }
             
             NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[[[CCCoreManager sharedInstance] server] currentUser] getObjectID], @"src_User",
                                          [NSNumber numberWithInt:CCViewPush], @"type",
                                          [self getObjectID], @"ID",
                                          nil];
             
             [[[CCCoreManager sharedInstance] server] sendNotificationWithData:messageData ToChannels:crewsToNotifyArray];                    
             
             [[CCCoreManager sharedInstance] recordMetricEvent:@"Viewed video" withProperties:nil];
         }          
         
         OSAtomicTestAndClear(YES, &isObjectBusy);
         
         if (block)
             block(succeeded, error);
     }]; 
}

- (NSInteger) getNumberOfViews
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"viewedByCount"] integerValue];
}

- (void) loadCommentsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    if (OSAtomicTestAndSetBarrier(1, &isLoadingComments))        
        return;
    
    PFRelation *videosComments = [[self parseObject] relationforKey:@"comments"];
    PFQuery *videosCommentsQuery = [videosComments query];
    [videosCommentsQuery orderByDescending:@"createdAt"];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    [self notifyListenersThatCommentsAreAboutToBeLoaded];
    
    [videosCommentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
     {
         if (error)
         {
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load video's comments for video %@: %@", [self getObjectID], [error localizedDescription]];       
             
             OSAtomicTestAndClear(YES, &isObjectBusy);
             
             if (block)
                 block(YES, error);
             
             [self notifyListenersThatCommentsHaveLoadedWithSuccess:(error == nil ? YES : NO) andError:error];
             
             OSAtomicTestAndClearBarrier(1, &isLoadingComments);   
         }
         else 
         {
             // Iterate through all the videos, create an array of pointers to users, and fetch all their data
             NSMutableArray *pfUsersToBeFetched = [[NSMutableArray alloc] initWithCapacity:[objects count]];
             for (PFObject *videoObject in objects)
             {
                 [pfUsersToBeFetched addObject:[videoObject objectForKey:@"commenter"]];
             }
             
             [PFObject fetchAllIfNeededInBackground:pfUsersToBeFetched block:^(NSArray *userObjects, NSError *error) 
             {
                 if (error)
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load video's comments for video %@: %@", [self getObjectID], [error localizedDescription]];                    
                 }
                 else 
                 {
                    [self handleNewComments:objects];
                 }
                 
                 OSAtomicTestAndClear(YES, &isObjectBusy);
                 
                 if (block)
                     block((error == nil ? YES : NO), error);
                 
                 [self notifyListenersThatCommentsHaveLoadedWithSuccess:(error == nil ? YES : NO) andError:error];
                 
                 OSAtomicTestAndClearBarrier(1, &isLoadingComments);                    
             }];   
          }                            
     }];        
}

- (void) handleNewComments:(NSArray *) pfObjects
{
    NSMutableArray *allComments = [[NSMutableArray alloc] init];
    NSMutableArray *newCommentsIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *removedVideoIndexes = [[NSMutableArray alloc] init];
    
    for(int commentIndex = 0; commentIndex < [pfObjects count]; commentIndex++)
    {
        PFObject *pfComment = [pfObjects objectAtIndex:commentIndex];
        CCParseComment *ccComment = [[CCParseComment alloc] initWithServerData:pfComment];                
        [allComments addObject:ccComment];
    }    
    
    [self handleNewCCObjects:allComments removedObjectIndexes:removedVideoIndexes addedObjectIndexes:newCommentsIndexes finalArrayOfObjects:ccComments];
    
    @synchronized([self parseObject])
    {
        [[self parseObject] setObject:[NSNumber numberWithInt:[ccComments count]] forKey:@"commentsCount"];    
    }
    
    if ([removedVideoIndexes count] > 0 || [newCommentsIndexes count] > 0)
        [self notifyListenersThatCommentsHaveBeenAddedAtIndexes:newCommentsIndexes andRemovedAtIndexes:removedVideoIndexes];
}

- (void) addCommentInBackground:(id<CCComment>) comment withBlockOrNil:(CCBooleanResultBlock) block
{
    PFObject *commentObject = [PFObject objectWithoutDataWithClassName:@"Comment" objectId:[comment getObjectID]];
    
    PFRelation *commentRelation = [[self parseObject] relationforKey:@"comments"];
    
    [commentRelation addObject:commentObject];
    [[self parseObject] incrementKey:@"commentsCount"];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {                
        if (!error)
        {
            // Save the comment locally
            [ccComments insertObject:comment atIndex:0];
            
            
            [self notifyListenersThatCommentsHaveBeenAddedAtIndexes:[[NSArray alloc] initWithObjects: [NSIndexPath indexPathForRow:0 inSection:0], nil] andRemovedAtIndexes:nil]; 
        }
        else
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to add comment to video: %@", [error localizedDescription]];
        }
        
        OSAtomicTestAndClear(YES, &isObjectBusy);
        
        if (block)
            block(succeeded, error);
    }];
}

- (NSInteger) getNumberOfComments
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"commentsCount"] integerValue];
}

@synthesize videoUpdatesDelegates;
- (void) addVideoUpdateListener:(id<CCVideoUpdatesDelegate>) delegate
{
    @synchronized(videoUpdatesDelegates)
    {
        if (![videoUpdatesDelegates containsObject:delegate])
            [videoUpdatesDelegates addObject:delegate];
    }
}

- (void) removeVideoUpdateListener:(id<CCVideoUpdatesDelegate>) delegate
{
    @synchronized(videoUpdatesDelegates)
    {
        if ([videoUpdatesDelegates containsObject:delegate])
            [videoUpdatesDelegates removeObject:delegate];    
    }
}

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

- (NSData *)generateThumbnailWithVideoPath:(NSString *)thumbnailVideoPath
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
    
    return UIImageJPEGRepresentation(imageForUse, 0.1);
}

@end
