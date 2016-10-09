//
//  CCEmailLoginViewControllerViewController.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"

@interface CCEmailLoginViewController : UIViewController <CCServerLoginDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) IBOutlet UISwitch *userSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loggingInIndicator;
@property (strong, nonatomic) IBOutlet UITextField *emailPasswordConfirmationField;


- (IBAction)onUserSwitchPressWithSender:(id)sender;
- (IBAction)onHideKeyboadWithSender:(id)sender;
- (IBAction)onLoginPressWithSender:(id)sender;

@end
