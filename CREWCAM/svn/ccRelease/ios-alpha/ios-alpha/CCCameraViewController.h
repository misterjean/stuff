//
//  CCCameraViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-27.
//
//

#import <UIKit/UIKit.h>
#import "UIView+Utilities.h"
#import <AVFoundation/AVFoundation.h>
#import "CCConstants.h"
#import "CCCameraController.h"
#import "CCPostVideoForumViewController.h"
#import "CCMediaBrowserViewController.h"

@interface CCCameraViewController : UIViewController <CCCameraControllerDelegate>
{
    CCCameraController                  *cameraController;

    CCPostVideoForumViewController      *forumVC;
    CCMediaBrowserViewController        *mediaBrowserVC;
}

@property (weak, nonatomic) IBOutlet UIView *cameraView;

- (IBAction)didPressLibraryButton:(id)sender;
- (IBAction)didPressFlashButton:(id)sender;
- (IBAction)didPressCameraButton:(id)sender;

@end
