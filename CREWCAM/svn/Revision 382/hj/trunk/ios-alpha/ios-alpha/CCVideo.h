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
@end

@protocol CCVideo <CCServerStoredObject>

@required
@property                       BOOL             wasVideoAddedLocally;

//Factory Methods
+ (id<CCVideo>) createNewVideoInBackgroundWithName:(NSString *)name creator:(id<CCUser>)creator videoPath:(NSString *)videoPath delegate:(id<CCVideoUpdatesDelegate>)delegate withBlock:(CCVideoResultBlock)block;

+ (void) loadSingleVideoInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCVideoResultBlock)block;

- (void) uploadAndSaveInBackgroundWithBlock:(CCVideoResultBlock) block;

// Notification Hanlder
- (BOOL) notificationReceivedWithData:(NSDictionary *)data;

// Getter/Setter methods
- (void) setName:(NSString *) name;
- (NSString *) getName;

- (BOOL) isUploading;
- (int) getUploadPercentComplete;

@property (strong, nonatomic) id<CCUser> localCCOwner;
- (id<CCUser>) getTheOwner;

- (NSString *) getThumbnailURL;
- (UIImage *) getThumbnail;
- (void) clearThumbnail;

- (NSString *) getVideoURL;

- (CLLocation *) getVideoLocation;

- (float) getVideoDuration;

- (void) loadThumbnailInBackground;

typedef enum {
    CCStatusUnknown,
    CCStatusUnwatched,
    CCStatusWatched,
}CCVideoWatchedStatus;
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