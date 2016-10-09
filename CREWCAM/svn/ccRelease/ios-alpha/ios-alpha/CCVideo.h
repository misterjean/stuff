//
//  CCVideo.h
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCServerStoredObject.h"
#import "CoreLocation/CoreLocation.h"
#import "CCUser.h"
#import "CCComment.h"
#import "CCVideoFiles.h"

@protocol CCVideoUpdatesDelegate <NSObject>

// Optional methods implementors can implement to be notified about various changes
@optional
- (void) startingToLoadViewers;
- (void) finishedLoadingViewersWithSuccess:(BOOL) successful andError:(NSError *) error;
- (void) addedNewViewsAtIndexes:(NSArray *) addedViewsIndexes andRemovedViewsAtIndexes:(NSArray *)removedViewsIndexes;

- (void) startingToUploadVideo;
- (void) finishedUploadingVideoWithSuccess:(BOOL) successful error:(NSError *) error andVideoReference:(id<CCVideo>)video;
- (void) videoUploadProgressIsAtPercent:(int)percent;                                            

- (void) startingToLoadComments;
- (void) finishedLoadingCommentsWithSuccess:(BOOL) successful andError:(NSError *) error;
- (void) addedNewCommentsAtIndexes:(NSArray *) addedCommentIndexes andRemovedCommentsAtIndexes:(NSArray *)removedCommentIndexes;

- (void) startingToLoadThumbnail;
- (void) finishedLoadingThumbnailWithSucess:(BOOL) successful andError:(NSError *) error;

- (void) finishedDeletingVideoWithSuccess:(BOOL) successful error:(NSError *)error andVideoReference:(id<CCVideo>)video;
@end

@protocol CCVideo <CCServerStoredObject, CCVideoFilesUpdatesDelegate>

@required

//Factory Methods
+ (id<CCVideo>) createNewVideoObjectWithName:(NSString *)name creator:(id<CCUser>)creator videoPath:(NSString *)videoPath mediaSource:(ccMediaSources)mediaSource videoFiles:(id<CCVideoFiles>)videoFiles andVideoUploader:(id<CCVideoUploader>) uploader;

+ (void) loadSingleVideoInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCVideoResultBlock)block;

// To be called when the underlying videofiles are uploaded correctly
- (BOOL) completeNewVideoUpload;

// Notification Hanlder
- (BOOL) notificationReceivedWithData:(NSDictionary *)data;

// Getter/Setter methods
- (void) setName:(NSString *) name;
- (NSString *) getName;

- (BOOL) isUploading;
- (int) getUploadPercentComplete;
- (void) cancelUpload;

- (id<CCUser>) getTheOwner;

//This Functions assumes that the data has been downloaded if there was any available
- (id<CCVideoFiles>) getVideoFile;

- (NSString *) getThumbnailURL;
- (UIImage *) getThumbnail;
- (void) clearThumbnail;
- (BOOL) isLandscape;
- (NSString *) getVideoURL;

- (CLLocation *) getVideoLocation;
- (void) loadLocationPlacemarkInBackgroundWithBlock:(CCBooleanResultBlock) block;
- (NSString *) getNameOfLocation;

- (float) getVideoDuration;

- (void) loadThumbnailInBackgroundWithBlockOrNil:(CCImageResultBlock) block;

typedef enum {
    CCStatusUnknown,
    CCStatusUnwatched,
    CCStatusWatched,
}CCVideoWatchedStatus;

@property ccMediaSources videoMediaSource;

- (void) isVideoNewWithBlockOrNil:(CCIntResultBlock)block;
@property (atomic) NSInteger isNewVideo;
- (NSInteger) getWatchedStatus;

- (void) loadViewsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;
- (void) addViewInBackground:(id<CCUser>) viewer withBlockOrNil:(CCBooleanResultBlock) block;
@property (strong, atomic) NSArray *ccUsersThatViewed;
- (NSInteger) getNumberOfViews;

- (void) loadCommentsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;
- (void) addCommentInBackground:(id<CCComment>) comment withBlockOrNil:(CCBooleanResultBlock) block;
@property (strong, atomic) NSArray *ccComments;
- (NSInteger) getNumberOfComments;

// Notifier methods
@property (strong, atomic)      NSMutableArray    *videoUpdatesDelegates;  
- (void) addVideoUpdateListener:(id<CCVideoUpdatesDelegate>) delegate;
- (void) removeVideoUpdateListener:(id<CCVideoUpdatesDelegate>) delegate;

@optional

@end