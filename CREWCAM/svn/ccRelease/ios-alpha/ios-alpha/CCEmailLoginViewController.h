//
//  CCEmailLoginViewController.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCUsersDetailsFormViewController.h"
#import "CCConstants.h"
#import "UIView+Utilities.h"

@interface CCEmailLoginViewController : UIViewController <UIScrollViewDelegate, CCCrewcamAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField          *emailField;
@property (strong, nonatomic) IBOutlet UITextField          *passwordField;
@property (strong, nonatomic) IBOutlet UITextField          *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIImageView            *passwordConfirmBuble;
@property (strong, nonatomic) IBOutlet UIScrollView         *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton             *confirmButton;
@property (strong, nonatomic) IBOutlet UIView               *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIButton             *customUserSwitchOutlet;
@property (strong, nonatomic) IBOutlet UILabel              *textNewUserLabel;
@property (strong, nonatomic) NSString                      *autoEmailText;
@property (strong, nonatomic) IBOutlet UIButton             *forgotPasswordButton;
@property BOOL customUserSwitchState;
@property BOOL autoLinkAfterLogin;

- (IBAction)onSubmitButtonPress:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)onCustomNewUserSwitchPress:(id)sender;
- (IBAction)onForgotPasswordPress:(id)sender;

@end
