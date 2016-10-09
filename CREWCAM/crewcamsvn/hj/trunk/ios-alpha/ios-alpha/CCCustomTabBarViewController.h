//
//  CCCustomTabBarViewController.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPostVideoForumViewController.h"
#import "UIImagePickerController+CCCameraProperties.h"
#import "UIColor+CrewcamColors.h"
#import "CCTutorialPopover.h"


@interface CCCustomTabBarViewController : UITabBarController <CCUserUpdatesDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    UIImageView                 *cameraImage;
    UIButton                    *cameraButton;
    UIImagePickerController     *cameraUI;
    ccMediaSources mediaSource;
    int notificationsBadgeValue;
}

@end
