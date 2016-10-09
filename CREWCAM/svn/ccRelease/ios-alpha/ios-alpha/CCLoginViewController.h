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
#import "CCEmailLoginViewController.h"
#import "CCCrewcamAlertView.h"
#import "CCTutorialPopover.h"
#import "CCSteelfishButton.h"
#import "UIFont+CrewcamFonts.h"

#import <Parse/Parse.h>

typedef enum{
    ccEmailAccountAlreadyExistsForAccountAlert = 1,
    ccMoreThenOneAccountWithSameEmailAlert,
    ccGeneralFacebookLoginErrorAlert,
} ccLoginViewControllerAlertDialogTags;


@interface CCLoginViewController : UIViewController <UITextFieldDelegate , CCCrewcamAlertViewDelegate>
{
    BOOL didStartFacebookAuthentication;
    id<CCUser> failedLoginUser;
}
@property (weak, nonatomic) IBOutlet CCSteelfishButton *emailLoginButton;
@property (weak, nonatomic) IBOutlet CCSteelfishButton *facebookLoginButton;

@property (weak, nonatomic) IBOutlet UITextField        *promoCode;

@property (weak, nonatomic) IBOutlet UIScrollView       *mainScrollView;

@property (weak, nonatomic) IBOutlet UIView             *loadingView;

- (IBAction)hideKeyboardWithSender:(id)sender;
- (IBAction)onFacebookButtonPressWithSender:(id)sender;
- (IBAction)onFacebookQuestionPress:(id)sender;

@end
