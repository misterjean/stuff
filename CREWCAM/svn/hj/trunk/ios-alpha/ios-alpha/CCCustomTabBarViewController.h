//
//  CCCustomTabBarViewController.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CCPostVideoForumViewController.h"

#define ALLOWED_RECORDED_VIDEO_LENGTH 90
#define ALLOWED_LIBRARY_VIDEO_LENGTH 30

@interface CCCustomTabBarViewController : UITabBarController <CCUserUpdatesDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    UIImageView *cameraImage;
    UIButton *cameraButton;
    UIImagePickerController *cameraUI;
    ccMediaSources mediaSource;
}

-(void) addCameraButton;

@end
