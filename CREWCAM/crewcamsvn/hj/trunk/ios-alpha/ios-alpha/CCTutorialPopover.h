//
//  CCTutorialPopover.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-16.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CCConstants.h"

typedef enum {
    ccTutorialPopoverDirectionLeft,
    ccTutorialPopoverDirectionRight,
    ccTutorialPopoverDirectionDown,
    ccTutorialPopoverDirectionUp,
    ccTutorialPopoverDirectionNone,
} ccTutorialPopoverDirections;

@interface CCTutorialPopover : UIView
{
    BOOL    didCancelFade;
    BOOL    didDismiss;
    UIView *parentView;
}

@property (weak, nonatomic) IBOutlet UIView             *textBackground;
@property (weak, nonatomic) IBOutlet UITextView         *tutorialTextView;
@property (weak, nonatomic) IBOutlet UIImageView        *glowImageView;
@property (weak, nonatomic) IBOutlet UIView             *glowingPointerView;
@property (weak, nonatomic) IBOutlet UIImageView        *pointerView;
@property (weak, nonatomic) IBOutlet UIControl          *buttonOverlay;

- (id)initWithMessage:(NSString *) message pointsDirection:(ccTutorialPopoverDirections) direction withTargetPoint:(CGPoint) targetPoint andParentView:(UIView *) targetView;
- (void) showInView:(UIView *) view;
- (void) show;
- (IBAction)didPressOverlay:(id)sender;
- (void) dismiss;

@end
