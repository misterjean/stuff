//
//  CCCrewcamAlertView.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-14.
//
//

#import <UIKit/UIKit.h>
#import "UIFont+CrewcamFonts.h"
#import "UIColor+CrewcamColors.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+CrewcamFonts.h"

#define FLIP_TIME 0.4
#define FADE_TIME 0.1

@protocol CCCrewcamAlertViewDelegate <NSObject>

@required
- (void) alertView:(id) alertView clickedButtonAtIndex:(NSInteger) buttonIndex;

@end

@interface CCCrewcamAlertView : UIView <UITextFieldDelegate>
{
    id<CCCrewcamAlertViewDelegate>                  alertDelegate;
}

@property (weak, nonatomic) IBOutlet UIView         *alertView;
@property (weak, nonatomic) IBOutlet UITextView     *alertTextView;
@property (weak, nonatomic) IBOutlet UIButton       *alertCloseButton;
@property (weak, nonatomic) IBOutlet UIButton       *mainButton;
@property (weak, nonatomic) IBOutlet UIButton       *secondaryButton;
@property (weak, nonatomic) IBOutlet UIView         *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel        *alertViewTitleLabel;
@property (weak, nonatomic) IBOutlet UIView         *buttonsView;
@property (weak, nonatomic) IBOutlet UITextField    *alertTextField;

- (IBAction)didPressCloseButton:(id)sender;

- (id)initWithTitle:(NSString *)title message:(NSString *)message withTextField:(BOOL) withTextField delegate:(id<CCCrewcamAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (void) show;
- (IBAction)didPressMainButton:(id)sender;
- (IBAction)didPressSecondaryButton:(id)sender;
- (UITextField *) getTextField;

@end

