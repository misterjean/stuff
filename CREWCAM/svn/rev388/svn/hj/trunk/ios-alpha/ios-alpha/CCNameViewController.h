//
//  CCNameViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBarButtonItem+CCCustomBarButtonItem.h"
#import "CCCoreManager.h"

@interface CCNameViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *activityOverlay;
- (IBAction)onDoneButtonPressed:(id)sender;


@end
