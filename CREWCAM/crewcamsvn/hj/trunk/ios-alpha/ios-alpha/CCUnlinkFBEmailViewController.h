//
//  CCUnlinkFBEmailViewController.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-07-31.
//
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"

@interface CCUnlinkFBEmailViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UILabel *textBlockOutlet;
@property (strong, nonatomic) NSString *textForTextBlock;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

- (IBAction)onSubmitButtonPress:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end
