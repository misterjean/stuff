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
#import "CCCameraViewController.h"


@interface CCCustomTabBarViewController : UITabBarController <CCUserUpdatesDelegate>
{
    int notificationsBadgeValue;
}

@end
