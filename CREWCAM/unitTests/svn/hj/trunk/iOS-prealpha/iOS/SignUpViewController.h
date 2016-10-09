//
//  SignUpViewController.h
//  iOS
//
//  Created by Desmond McNamee on 12-04-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerApi.h"

@interface SignUpViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *userNameField;
@property (strong, nonatomic) IBOutlet UITextField *password1Field;
@property (strong, nonatomic) IBOutlet UITextField *password2Field;
- (IBAction)submitButton:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end
