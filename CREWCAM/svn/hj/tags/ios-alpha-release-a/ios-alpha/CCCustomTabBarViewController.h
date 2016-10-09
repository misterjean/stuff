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

@interface CCCustomTabBarViewController : UITabBarController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{

    UIButton *cameraButton;

}

-(void) addCameraButton;

@end
