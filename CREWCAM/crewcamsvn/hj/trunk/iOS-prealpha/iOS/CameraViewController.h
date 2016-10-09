//
//  CameraViewController.h
//  iOS
//
//  Created by Desmond McNamee on 12-04-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ServerApi.h"
#import "PostVideoForumViewController.h"

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property int cameraOrientation;

- (IBAction)recordButton:(id)sender;

@end
