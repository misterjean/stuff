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
#import "CCServerPostObjectDelegate.h"
#import "CCComment.h"

@protocol CCVideo <CCServerStoredObject>

@required
// Required methods
- (void)like;
- (id<CCVideo>)initLocalVideoWithName:(NSString *)videoName createdBy:(id<CCUser>)creator videoFile:(NSString *)videoFilePath crews:(NSArray *)crews;
- (void)uploadVideoWithProgressIndicatorOrNil:(id<CCServerUploadVideoDelegate>)delegate block:(CCBooleanResultBlock)block;
- (void)loadThumbnailWithNewThread:(Boolean) useNewThread;
- (void)addWatchedByWithUser:(id<CCUser>)user;
-(void) addComment:(NSString *) text;

// Required properties
@property (strong, nonatomic) CLLocation                                    *location;
@property (strong, nonatomic) NSMutableArray                                *likes;
@property (strong, nonatomic) id<CCUser>                                    owner;
@property (strong, nonatomic) NSDate                                        *createdDate;
@property (strong, nonatomic) NSString                                      *localTempVideoFilePath;
@property (strong, nonatomic) NSString                                      *videoURL;
@property (strong, nonatomic) NSString                                      *videoImageURL;
@property (strong, nonatomic) NSData                                        *videoImageData;
@property (strong, nonatomic) NSArray                                       *videoCrews;
@property (strong, nonatomic) NSMutableArray                                *usersThatWatched;
@property (strong, nonatomic) NSMutableArray                                *comments;

@optional

@end