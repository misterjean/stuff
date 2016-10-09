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

@interface CCParseVideo ()
@property (strong, nonatomic) id<CCUser> localCCOwner;
@property (strong, nonatomic) id<CCVideoFiles> localCCVideoFile;
@end

@implementation CCParseVideo

// CCVideo properties
@synthesize ccUsersThatViewed;
@synthesize ccComments;      
@synthesize videoThumbnail;
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

- (void) notifyListenersThatVideoDeleteIsCompleteWithSuccess:(BOOL) successful error:(NSError *) error andVideoReference:(id<CCVideo>)video;
{
    @synchronized(videoUpdatesDelegates)
    {
        for(id<CCVideoUpdatesDelegate> delegate in videoUpdatesDelegates)
        {
            if ([delegate respondsToSelector:@selector(finishedDeletingVideoWithSuccess:error:andVideoReference:)])
                [delegate finishedDeletingVideoWithSuccess:successful error:error andVideoReference:video];
        }
    }
}

static NSString *className = @"Video";

// Optional CCServerStoredObject methods

- (void) deleteObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    [super deleteObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
     {
         if (succeeded)
         {
             [self notifyListenersThatVideoDeleteIsCompleteWithSuccess:succeeded error:error andVideoReference:self];
             
             if (block)
             {
                 block(succeeded, error);
             }
         }
             
     }];
}

- (void) purgeRelatedDataInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    [self startPurgingDatabaseOfNotificationsRelatedToVideo];
    [self loadCommentsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        for(int commentsIndex = 0; commentsIndex < [[self ccComments] count]; commentsIndex++)
        {
            [[[self ccComments] objectAtIndex:commentsIndex] deleteObjectWithBlockOrNil:nil];
        }
        [[self ccComments] removeAllObjects];
        if (block)
        {
            block(YES, nil);
        }
    }];
    
    
}

- (void) startPurgingDatabaseOfNotificationsRelatedToVideo
{
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notification"];
    [notificationQuery whereKey:@"targetObjectId" equalTo:[self getObjectID]];
    
    [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // Delete all the notifications
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            for(PFObject *notification in objects)
            {
                [notification delete];
            }
        });
    }];
}

// Required CCServerStoredObject methods
- (void)initialize
{
    isLodingThumbnail = NO;
    isLoadingViews = NO;
    isLoadingComments = NO;
    isUploading = NO;
    isNewVideo = CCStatusUnknown;
    [self setCcUsersThatViewed:[[NSMutableArray alloc] init]];
    [self setCcComments:[[NSMutableArray alloc] init]];
    [self setVideoUpdatesDelegates:[[NSMutableArray alloc] init]];
}

- (void) dealloc
{
    [self setLocalCCOwner:nil];
    
    videoProgressTimer = nil;
    videoUploader = nil;
    videoPath = nil;
    locationPlacemark = nil;
    
    [self setCcUsersThatViewed:nil];
    [self setCcComments:nil];
    [self setVideoThumbnail:nil];    
    [self setCcComments:nil];
    [self setVideoUpdatesDelegates:nil];
}

- (void)pullObjectWithBlockOrNil:(CCBooleanResultBlock)block
{    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    [super pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            OSAtomicTestAndSet(YES, &isObjectBusy);
            [[(CCParseUser *)[self getTheOwner] parseObject] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {                

                if (!error)
                {
                    OSAtomicTestAndSet(YES, &isObjectBusy);
                    [[(CCParseVideoFiles *)[self getVideoFile] parseObject] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (block)
                            block(!error, error);
                        
                        OSAtomicTestAndClear(YES, &isObjectBusy);
                    }];
                }
                else 
                {
                    if (block)
                        block(NO,error);
                    
                    OSAtomicTestAndClear(YES, &isObjectBusy);
                }
            }] ;
        }
        else 
        {
            if (block)
                block(NO,error);
            
            OSAtomicTestAndClear(YES, &isObjectBusy);
        }
    }];
}

// Required CCVideo methods
+ (id<CCVideo>) createNewVideoObjectWithName:(NSString *)name creator:(id<CCUser>)creator videoPath:(NSString *)videoPath mediaSource:(ccMediaSources)mediaSource videoFiles:(id<CCVideoFiles>)videoFiles andVideoUploader:(id<CCVideoUploader>) uploader
{   
    if ([[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName] hasSuffix:@"s"])
        name = [NSString stringWithFormat:@"%@' Video",[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName]];
    else
        name = [NSString stringWithFormat:@"%@'s Video",[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName]];
    
    // Read the duration
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];        
    AVAssetTrack* videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    Float64 durationSeconds = CMTimeGetSeconds([videoAsset duration]);
    
    PFObject *newVideo = [PFObject objectWithClassName:@"Video"];                     
    [newVideo setObject:name forKey:@"videoName"];                     
    [newVideo setObject:[creator getServerData] forKey:@"theOwner"];  
    [newVideo setObject:[NSNumber numberWithInt:0] forKey:@"viewedByCount"];                                          
    [newVideo setObject:[NSNumber numberWithInt:0] forKey:@"commentsCount"];  
    
    [newVideo setObject:[NSNumber numberWithFloat:durationSeconds] forKey:@"duration"];
    
    // Look for the portrait/landscape
    if ([[videoAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0)
    {
        CGAffineTransform txf = [videoTrack preferredTransform];
        if (txf.a == 1 || txf.a == -1)
        {
            [newVideo setObject:[NSNumber numberWithBool:YES] forKey:@"isLandscape"];
        }
        else
        {
            [newVideo setObject:[NSNumber numberWithBool:NO] forKey:@"isLandscape"];
        }
    }
    
    //New videos no longer need to set transform degrees
    [newVideo setObject:[NSNumber numberWithInt:0] forKey:@"transformDegrees"];
    
    [newVideo setObject:[[(CCParseVideoFiles *)videoFiles parseObject] objectForKey:@"video"]  forKey:@"videoFile"];                     
    [newVideo setObject:[[(CCParseVideoFiles *)videoFiles parseObject] objectForKey:@"videoThumbnail"] forKey:@"videoThumbnail"];
    [newVideo setObject:[(CCParseVideoFiles *)videoFiles parseObject] forKey:@"videoFileObject"];
    
    CLLocation *currentLocation = [[[CCCoreManager sharedInstance] locationManager] getCurrentLocation];
    PFGeoPoint *pfLocation = [PFGeoPoint geoPointWithLatitude:[currentLocation coordinate].latitude longitude:[currentLocation coordinate].longitude];
    [newVideo setObject:pfLocation forKey:@"locatedAt"];
    
    CCParseVideo *newCCVideo = [[CCParseVideo alloc] initWithServerData:newVideo];
    newCCVideo->videoMediaSource = mediaSource;
    newCCVideo->videoUploader = uploader;
    
    [videoFiles addVideoFilesUpdateListener:newCCVideo];
    
    return newCCVideo;
}

+ (void) loadSingleVideoInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCVideoResultBlock)block
{
    PFQuery *videoQuery = [PFQuery queryWithClassName:@"Video"];
    [videoQuery includeKey:@"theOwner"];
    [videoQuery includeKey:@"videoFileObject"];

    [videoQuery getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        id<CCVideo> videoObject;
        
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load single video: %@", [error localizedDescription]];
            block(videoObject, NO,error);
            return;
        }
        
        if (!objectId)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Couldn't find video matching ID %@", objectId];
            if (block)
                block(videoObject, NO,error);
        }
        else
        {
            videoObject = [[CCParseVideo alloc] initWithServerData:object];
            
            if (block)
                block(videoObject,!error, error);
        }
    }];
}

- (void) startingToUploadVideoFiles
{
    OSAtomicTestAndSet(YES, &isUploading);
    uploadPercentComplete = 0;
    [self notifyListenersThatUploadIsStarting];
}

// Blocking push and pull
- (BOOL) completeNewVideoUpload
{
    NSCondition *saveCompleteCondition = [[NSCondition alloc] init];
    __block BOOL wasSuccessful = NO;
    
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        wasSuccessful = succeeded;
        [saveCompleteCondition signal];
    }];
    
    [saveCompleteCondition lock];
    [saveCompleteCondition wait];
    [saveCompleteCondition unlock];
    
    if (!wasSuccessful)
        return wasSuccessful;
    
    [self pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        wasSuccessful = succeeded;
        [saveCompleteCondition signal];
    }];
    
    [saveCompleteCondition lock];
    [saveCompleteCondition wait];
    [saveCompleteCondition unlock];
    
    return wasSuccessful;
}

- (void) finishedUploadingVideoFilesWithSucces:(BOOL)successful error:(NSError *)error forUploader:(id<CCVideoUploader>)videoUploader
{
    OSAtomicTestAndClear(YES, &isUploading);    
    [self notifyListenersThatUploadIsCompleteWithSuccess:successful error: error andVideoReference:self];    
}

- (void) videoFilesUploadProgressIsAtPercent:(int)percent
{
    uploadPercentComplete = percent;
    [self notifyListenersThatUploadIsAtPercent:percent];
}

- (BOOL) notificationReceivedWithData:(NSDictionary *)data
{
    if ([[data objectForKey:@"ID"] isEqualToString:[self getObjectID]])
    {
        if ([[data objectForKey:@"type"] intValue] == ccCommentPushNotification)
        {
            [self loadCommentsInBackgroundWithBlockOrNil:nil];
        }
        else if ([[data objectForKey:@"type"] intValue] == ccViewPushNotification)
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

- (BOOL) isLandscape
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"isLandscape"] boolValue];
}

- (void) cancelUpload
{
    if (![self isUploading])
        return;
    
    [videoUploader cancelUpload];
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

@synthesize localCCVideoFile;
- (id<CCVideoFiles>) getVideoFile
{
    if (localCCVideoFile == nil)
    {
        [self checkForParseDataAndThrowExceptionIfNil];
        
        localCCVideoFile = [[CCParseVideoFiles alloc] initWithServerData:[[self parseObject] objectForKey:@"videoFileObject"]];
    }
    
    if (![localCCVideoFile getServerData] && ![[localCCVideoFile getServerData] isKindOfClass:[NSNull class]])
        return nil;
    
    return localCCVideoFile;
}

- (NSString *) getThumbnailURL
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    NSString *url;
    
    if ([self getVideoFile])
        url = [[self getVideoFile] getVideoImageFileURL];
    else
        url = [(PFFile *)[[self parseObject] objectForKey:@"videoThumbnail"] url];
    
    return url;
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
    
    NSString * url;
    
    if ([self getVideoFile])
        url = [[self getVideoFile] getVideoMovieFileURL];
    else 
        url = [(PFFile *)[[self parseObject] objectForKey:@"videoFile"] url];

    return url;
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

- (void) loadLocationPlacemarkInBackgroundWithBlock:(CCBooleanResultBlock) block
{
    if (locationPlacemark)
    {
        block(YES, nil);
        return;
    }
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    NSCondition *geoCodeCompleteCondition = [[NSCondition alloc] init];
    
    __block NSError *geoCodeError;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [geoCoder reverseGeocodeLocation:[self getVideoLocation] completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if (error)
                block(NO, error);
            
            for (CLPlacemark * placemark in placemarks) {
                locationPlacemark = placemark;
                break;
            }
            
            geoCodeError = error;
            
            [geoCodeCompleteCondition signal];
        }];
        
        [geoCodeCompleteCondition lock];
        [geoCodeCompleteCondition wait];
        [geoCodeCompleteCondition unlock];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(locationPlacemark != nil, geoCodeError);
        });
    });
}

- (NSString *) getNameOfLocation
{
    if (!locationPlacemark || ![locationPlacemark locality] || ![locationPlacemark administrativeArea])
        return @"Unknown";
    
    return [NSString stringWithFormat:@"%@, %@", [locationPlacemark locality], [locationPlacemark administrativeArea]];
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

- (void) loadThumbnailInBackgroundWithBlockOrNil:(CCImageResultBlock) block
{    
    // Do we already have the thumbnail?
    if (videoThumbnail)
    {
        if (block)
            block(videoThumbnail, nil);
        
        [self notifyListenersThatThumbnailHasBeenLoadedWithSuccess:YES andError:nil];
        
        return;
    }
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Are we already loading it?
    if (OSAtomicTestAndSet(YES, &isLodingThumbnail))
        return;
    
    [self notifyListenersThatThumbnailIsAboutToBeLoaded];
    
    // Start a new thread
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSData *imageData;
        if (isUploading)
        {
            imageData = [[videoUploader videoFiles] localThumbnailData];
        }
        else
        {
            imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self getThumbnailURL]]];            
        }
            
        // Download the image, and set the thumbnail to a new UIImage
        UIImage *thumbnailImage = [[UIImage alloc] initWithData:imageData] ;
        
        if ([[[self parseObject] objectForKey:@"transformDegrees"] intValue] != 0)
        {
            thumbnailImage = [UIImage imageWithCGImage:thumbnailImage.CGImage scale:thumbnailImage.scale orientation:UIImageOrientationUp];
        }
        
        [self setVideoThumbnail:thumbnailImage];
        
        // Push a function unto the main thread
        dispatch_async( dispatch_get_main_queue(), ^
        {
            [self notifyListenersThatThumbnailHasBeenLoadedWithSuccess:YES andError:nil];
            
            if (block)
                block(thumbnailImage, nil);
            
            OSAtomicTestAndClear(YES, &isObjectBusy);
            OSAtomicTestAndClear(YES, &isLodingThumbnail);
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


- (void) addViewInBackgroundInnerInner:(id<CCUser>) viewer video:(id<CCVideo>)videoToPush forCrew:(id<CCCrew>)crew withBlockOrNil:(CCBooleanResultBlock)block
{
    
    PFObject *viewerObject = [PFUser objectWithoutDataWithClassName:@"_User" objectId:[viewer getObjectID]];
    
    PFRelation *viewersRelation = [[videoToPush getServerData] relationforKey:@"viewedBy"];
    
    [viewersRelation addObject:viewerObject];
    [[videoToPush getServerData] incrementKey:@"viewedByCount"];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Add the relationship to the existing object
    
    [videoToPush pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
     {              
         if (!error)
         {
             [videoToPush setIsNewVideo:CCStatusWatched];
             [[(CCParseVideo *) videoToPush ccUsersThatViewed] insertObject:viewer atIndex:0];
             [(CCParseVideo *)videoToPush notifyListenersThatViewersHaveBeenAdded:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0] , nil] andRemovedAtIndexes:nil];
             
             NSMutableArray *crewsToNotifyArray = [[NSMutableArray alloc] init];
             
             for (id<CCCrew> currentCrew in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews])
             {
                 if ([CCParseCrew isObjectInArray:videoToPush arrayOfCCServerStoredObjects:[currentCrew ccVideos]])
                     [crewsToNotifyArray addObject:[currentCrew getChannelName]];
             }
             
             NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[[[CCCoreManager sharedInstance] server] currentUser] getObjectID], @"src_User",
                                          [NSNumber numberWithInt:ccViewPushNotification], @"type",
                                          [videoToPush getObjectID], @"ID",
                                          nil];
             
             if (videoToPush == self)
             {
                 NSString *viewMessage = [NSString stringWithFormat:@"%@ has viewed one of your videos!", [[[[CCCoreManager sharedInstance] server] currentUser] getName]];
                 
                 [CCParseNotification createNewNotificationInBackgroundWithType:ccNewViewNotification andTargetUser:[videoToPush getTheOwner] andSourceUser:[[[CCCoreManager sharedInstance] server] currentUser] andTargetObject:videoToPush andTargetCrewOrNil:crew andMessage:viewMessage];
             }
             
             [[[CCCoreManager sharedInstance] server] sendNotificationWithData:messageData ToChannels:crewsToNotifyArray];                    
         }
         else if (error)
         {
             [[videoToPush getServerData] incrementKey:@"viewedByCount" byAmount:[NSNumber numberWithInt: -1]];   
         }
         
         OSAtomicTestAndClear(YES, &isObjectBusy);
         
         if (block)
             block(succeeded, error);
     }]; 
}

- (void) addViewInBackgroundInner:(id<CCUser>) viewer withBlockOrNil:(CCBooleanResultBlock) block
{
    if ([self getVideoFile])
    {
        PFQuery *videosToMarkAsViewedQuery = [PFQuery queryWithClassName:@"Video"];
        [videosToMarkAsViewedQuery whereKey:@"videoFileObject" equalTo:[(CCParseVideoFiles *)[self getVideoFile] parseObject]];
        
        [videosToMarkAsViewedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray *videosIDsToPotentiallyAddViews = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            
            for (PFObject *videoObject in objects)
            {
                [videosIDsToPotentiallyAddViews addObject:[videoObject objectId]];
            }            
            
            for (id<CCCrew> crew in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] )
            {
                PFRelation *crewVideosToTest = [[crew getServerData] relationforKey:@"videos"];
                PFQuery *crewVideosToTestQuery = [crewVideosToTest query];
                [crewVideosToTestQuery whereKey:@"objectId" containedIn:videosIDsToPotentiallyAddViews];
                
                [crewVideosToTestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                   if ([objects count] == 1)
                   {
                       id<CCVideo> video = [[CCParseVideo alloc] initWithServerData:[objects objectAtIndex:0]];
                       
                       id<CCVideo> videoToPush;
                       
                       if ([[self getObjectID] isEqualToString:[video getObjectID]])
                           videoToPush = self;
                       else 
                           videoToPush = video;
                       
                       if ([CCParseCrew isObjectInArray:videoToPush arrayOfCCServerStoredObjects:[crew ccVideos]])
                       {
                           int indexOfLocalVideo = [CCParseObject indexForCCServerStoredObject:videoToPush inArrayOfCCServerStoredObjects:[crew ccVideos]];
                           
                           videoToPush = [[crew ccVideos] objectAtIndex:indexOfLocalVideo];
                       }
                       
                       [self addViewInBackgroundInnerInner:viewer video:videoToPush forCrew:crew withBlockOrNil:[block copy]];
                   }
                }];
            }
        }];
    }
    else 
    {
        [self addViewInBackgroundInnerInner:viewer video:self forCrew:nil withBlockOrNil:[block copy]];
    }
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
             for (PFObject *commentObject in objects)
             {
                 [pfUsersToBeFetched addObject:[commentObject objectForKey:@"commenter"]];
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
            [[self parseObject] incrementKey:@"commentsCount" byAmount:[NSNumber numberWithInt: -1]];
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

@end
