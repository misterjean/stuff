//
//  CCParseVideo.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCVideo.h"
#import "CCUser.h"
#import "CCCrew.h"
#import <Parse/Parse.h>
#import "CCParseUser.h"
#import "CCParseObject.h"
#import "CCParseComment.h"
#import "CCServerStoredObject.h"
#import "CCCrew.h"
#import "CCCoreManager.h"
#import "CCParseVideoFiles.h"

@interface CCParseVideo : CCParseObject <CCVideo>
{
    uint32_t                isLodingThumbnail;
    uint32_t                isLoadingViews;
    uint32_t                isLoadingComments;
    uint32_t                isUploading;
    int                     uploadPercentComplete;
    NSTimer                 *videoProgressTimer;
    id<CCVideoUploader>     videoUploader;
    NSString                *videoPath;
    CLPlacemark             *locationPlacemark;
}

// CCParseVideo properties
@property (strong, atomic)      NSMutableArray   *ccUsersThatViewed;        // An array of CCUsers that have watched this video.
@property (strong, atomic)      NSMutableArray   *ccComments;               // An array of CCComments that have watched this video.  
@property (strong, nonatomic)   UIImage          *videoThumbnail;

@end
