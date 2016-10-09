//
//  CCVideoUploader.h
//  Crewcam
//
//  Created by Ryan Brink on 12-07-19.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CCVideo.h"
#import "CCVideoFiles.h"
#import "CCCoreManager.h"
#import "CCCrewcamAlertView.h"

@protocol CCVideoUploader <NSObject, CCCrewcamAlertViewDelegate>
@property (strong, nonatomic) id<CCVideoFiles>      videoFiles;
@property (strong, nonatomic) NSMutableArray        *crewsForVideo;
@property (strong, nonatomic) NSMutableArray        *videoObjectsForCrews;
@property (strong, nonatomic) NSString *            videoName;
@property                     ccMediaSources        mediaSource;
@property                     BOOL                  postToFacebook;

- (id) initWithVideoName:(NSString *)name andCurrentVideoPath:(NSString *)currentVideoLocation forCrews:(NSArray *)crews andMediaSource:(ccMediaSources)videoMediaSource andAddToFacebook:(BOOL)addToFacebook;
- (void) startUploadInBackgroundWithBlock:(CCBooleanResultBlock) block;
- (void) cancelUpload;

@end
