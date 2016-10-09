//
//  UIImagePickerController+CCCameraProperties.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-07-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CCConstants.h"

#define ALLOWED_RECORDED_VIDEO_LENGTH 90
#define ALLOWED_LIBRARY_VIDEO_LENGTH 30

@interface UIImagePickerController (CCCameraProperties)

- (void) setCCPropertiesForMediaSource:(ccMediaSources)mediaSource;

@end
