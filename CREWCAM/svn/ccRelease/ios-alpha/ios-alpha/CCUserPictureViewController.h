//
//  CCUserPictureViewController.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-07-31.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCUser.h"
#import "UIView+Utilities.h"
#import "CCSteelfishButton.h"
#import "CCSteelfishTextView.h"

@interface CCUserPictureViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (strong,nonatomic) UIImagePickerController        *cameraUI;
@property (weak, nonatomic) IBOutlet UIImageView            *photoDispay;
@property (weak, nonatomic) IBOutlet UIView                 *imageViewHolder;
@property (weak, nonatomic) IBOutlet UIButton               *takePhotoButton;
@property (weak, nonatomic) IBOutlet CCSteelfishButton      *doneButton;
@property (weak, nonatomic) IBOutlet UIButton               *facebookButton;
@property (weak, nonatomic) IBOutlet UIView                 *linerHolderView;
@property (weak, nonatomic) IBOutlet CCSteelfishTextView    *instructionText;
@property (weak, nonatomic) IBOutlet UIView                 *activityIndicator;
@property BOOL newUserProcess;

- (IBAction)selectCustomPhoto:(id)sender;
- (IBAction)selectFBPhoto:(id)sender;
- (IBAction)onDoneButtonPressed:(id)sender;
@end
