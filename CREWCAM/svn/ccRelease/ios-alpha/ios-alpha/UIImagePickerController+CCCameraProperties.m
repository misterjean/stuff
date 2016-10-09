//
//  UIImagePickerController+CCCameraProperties.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-07-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImagePickerController+CCCameraProperties.h"

@implementation UIImagePickerController (CCCameraProperties)

- (void) setCCPropertiesForMediaSource:(ccMediaSources)mediaSource
{
    switch (mediaSource) {
        case ccCamera:
            //Take Video
            self.allowsEditing = NO;
            self.videoMaximumDuration = ALLOWED_RECORDED_VIDEO_LENGTH;
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case ccVideoLibrary:
            //Choose Existing
            self.allowsEditing = YES;
            self.videoMaximumDuration = ALLOWED_LIBRARY_VIDEO_LENGTH;
            self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            return;
    }
    
    self.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    self.videoQuality = UIImagePickerControllerQualityTypeMedium;

}

@end
