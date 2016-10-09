//
//  LoginViewController.h
//  iOS
//
//  Created by Desmond McNamee on 12-04-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerApi.h"
#import "FeedTableViewController.h"

@interface LoginViewController : UIViewController <PF_FBRequestDelegate>
@property (strong, nonatomic) IBOutlet UITextField *userNameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)submitButton:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end
