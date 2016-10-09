//
//  CCUsersDetailsFormViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCUser.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"
#import "CCCoreManager.h"

@interface CCUsersDetailsFormViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet UIView *loadingOverlay;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)onDoneButtonPressed:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end
