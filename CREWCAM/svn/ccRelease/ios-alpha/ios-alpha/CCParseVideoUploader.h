//
//  CCParseVideoUploader.h
//  Crewcam
//
//  Created by Ryan Brink on 12-07-19.
//
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

#import "CCVideoUploader.h"
#import "CCParseVideoFiles.h"
#import "CCParseVideo.h"

@interface CCParseVideoUploader : NSObject <CCVideoUploader, PF_FBRequestDelegate>
{
    CCBooleanResultBlock    videoUploadCompletionBlock;
    NSError                 *lastError;
    BOOL                    isFirstAttempt;
}

@end
