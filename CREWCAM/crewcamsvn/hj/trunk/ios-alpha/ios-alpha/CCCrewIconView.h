//
//  CCCrewIconView.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-24.
//
//

#import <UIKit/UIKit.h>
#import "CCCrew.h"
#import "CCCoreManager.h"
#import "CCCrewViewController.h"
#import "UIFont+CrewcamFonts.h"
#import "CCCrewIconNameTextView.h"
#import "CCCrewcamAlertView.h"
#import "CCTutorialPopover.h"

@interface CCCrewIconView : UIView <CCCrewUpdatesDelegate, CCUserUpdatesDelegate,  CCServerStoredObjectDelegate, CCCrewcamAlertViewDelegate>
{
    UINavigationController *parentNavigationController;
    CCInviteAndAddCrewViewController *newCrewViewController;
    id<CCVideo>             videoForThumbnail;
    CCTutorialPopover      *addCrewPopover;
}

@property (weak, nonatomic) IBOutlet UITextView    *crewNameLabel;
@property (weak, nonatomic) IBOutlet UILabel    *numberOfVideosLabel;
@property (weak, nonatomic) IBOutlet UILabel    *numberOfMembersLabel;
@property (weak, nonatomic) IBOutlet UILabel    *numberOfUnwatchedVideosLabel;
@property (weak, nonatomic) IBOutlet UIView    *unwatchedVideosBadge;
@property (weak, nonatomic)          id<CCCrew> crew;
@property (weak, nonatomic) IBOutlet UIView *crewDetailsView;
@property (weak, nonatomic) IBOutlet UIView *crewTitleView;
- (IBAction)onCrewIconPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *addCrewView;
@property (weak, nonatomic) IBOutlet UITextView *addCrewTextView;
@property (weak, nonatomic) IBOutlet UIImageView *crewThumbnailView;
@property (weak, nonatomic) IBOutlet UIView *titleOrangeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *detialsBlueBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *crewDeleteView;
@property BOOL isShaking;

- (IBAction)deleteButtonPressed:(id)sender;
- (void) shake;
- (void) stopShaking;
- (void) setCrew:(id<CCCrew>) crewForCell andNavigationController:(UINavigationController *) navigationController andIsShaking:(BOOL) isShakingCurrently;
- (void) setUpForAddCrewWithNavigationController:(UINavigationController *) navigationController;
- (void) flipToFrontWithForce:(BOOL) forceFlip;
@end
