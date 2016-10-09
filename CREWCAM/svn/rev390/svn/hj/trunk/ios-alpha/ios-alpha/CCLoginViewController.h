//
//  CCEmailLoginViewControllerViewController.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCUsersDetailsFormViewController.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"

@interface CCLoginViewController : UIViewController <UITextFieldDelegate>
{
    BOOL didStartFacebookAuthentication;
}
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *emailPasswordConfirmationField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) IBOutlet UIButton *userSwitch;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UIView *loadingView;

- (IBAction)onUserSwitchPressWithSender:(id)sender;
- (IBAction)hideKeyboardWithSender:(id)sender;
- (IBAction)onLoginPressWithSender:(id)sender;
- (IBAction)onFacebookButtonPressWithSender:(id)sender;

@end
