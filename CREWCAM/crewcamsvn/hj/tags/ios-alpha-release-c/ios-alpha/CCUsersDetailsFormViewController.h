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

- (IBAction)onDoneButtonPressed:(id)sender;

@end
