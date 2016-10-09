//
//  CCParseVideoFiles.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCVideoFiles.h"
#import "CCUser.h"
#import "CCServerStoredObject.h"
#import "Parse/Parse.h"
#import "CCParseObject.h"
#import "CCCoreManager.h"

@interface CCParseVideoFiles : CCParseObject <CCVideoFiles>
{
    uint32_t isUploading;
    NSTimer  *videoProgressTimer;
}
@property (strong, nonatomic) PFFile *videoImageFile;
@property (strong, nonatomic) PFFile *videoMovieFile;

@end
