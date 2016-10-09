//
//  CCSelectablePersonView.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-26.
//
//

#import <UIKit/UIKit.h>
#import "CCUser.h"
#import "UIFont+CrewcamFonts.h"
#import <QuartzCore/QuartzCore.h>
#import "CCBasePerson.h"
#import "CCCoreManager.h"
#import "CCVersionConstants.h"

@protocol CCPersonSelectedDelegate <NSObject>

@optional
- (void) didSelectPerson:(CCBasePerson *) person forView:(UIView *) personView;
- (void) didUnselectPerson:(CCBasePerson *) person forView:(UIView *) personView;

@end

@interface CCPersonIconView : UIView <CCCrewcamAlertViewDelegate>
{
    CCBasePerson                    *personForView;
    BOOL                            isPersonSelectable;
    BOOL                            isPersonInvitable;
    id<CCPersonSelectedDelegate>    personSelectedDelegate;
    BOOL                            isPersonInvited;
    BOOL                            isPersonAFriend;
}
@property BOOL isPersonSelected;

@property (weak, nonatomic) IBOutlet UIImageView *personsImageView;
@property (weak, nonatomic) IBOutlet UITextView *personsNameView;
@property (weak, nonatomic) IBOutlet UIView *selectedOverlay;
@property (weak, nonatomic) IBOutlet UIImageView *pendingRequestOverlay;
@property (weak, nonatomic) IBOutlet UIImageView *crewcamFriendOverlay;

- (void) setupForPerson:(CCBasePerson *) person andIsSelectable:(BOOL) isSelectable andIsSelected:(NSNumber *) isSelected andIsInvitable:(BOOL) isInvitable;
- (IBAction)didSelectPerson:(id)sender;
- (void) setDelegate:(id<CCPersonSelectedDelegate>) delegate;

- (void) setSelected:(BOOL) isSelected;

@end
