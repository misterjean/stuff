//
//  CCCrewsViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCUser.h"
#import "CCCrewTableViewCell.h"
#import "CCCrewViewController.h"
#import "CCVideosCommentsViewController.h"
#import "CCJoinViewController.h"
#import "UIView+Utilities.h"
#import "CCUnlinkFBEmailViewController.h"
#import "CCLoginViewController.h"
#import "CCCrewcamAlertView.h"
#import "CCUserPictureViewController.h"
#import "CCTutorialPopover.h"
#import "CCFriendFinderViewController.h"

typedef enum{
    CCCommentPushAlert = 1,
    CCLogoutAlert,
    CCUnlinkFBAlert,
    CCSuccessfulFBUnlink,
} ccCrewsViewControllerAlertDialogTags;

@interface CCCrewsViewController : UIViewController <CCUserUpdatesDelegate, UITableViewDataSource, UITableViewDelegate, CCCrewcamAlertViewDelegate>
{
    id<CCVideo> videoForComment;
    id<CCCrew> crewForComment;
    BOOL        isShowingSettings;
    UITextField *newPasswordField;
    UITextField *confirmNewPasswordField;
    BOOL        shakingIcons;

    // New user popovers
    CCTutorialPopover *joinCrewsPopover;
    CCTutorialPopover *addCrewPopover;
    
    CCFriendFinderViewController *friendFinderViewController;
}
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UITableView                    *crewsTableView;
@property (weak, nonatomic) IBOutlet UIControl                      *crewsPageControl;
@property (weak, nonatomic) IBOutlet UIView                         *combinedCrewsAndSettingsView;
@property (strong, nonatomic) IBOutlet UIButton                     *linkFacebookButton;
@property (strong, nonatomic) IBOutlet UIButton                     *setPasswordButton;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *settingsPanGestureRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *usersNameTextLabel;

- (IBAction)onPan:(id)sender;
- (IBAction)onSettingsButtonPressed:(id)sender;
- (IBAction)onCrewsPageTouched:(id)sender;
- (IBAction)onLinkFacebookButtonPress:(id)sender;
- (IBAction)onSetPasswordPress:(id)sender;
- (IBAction)onLogoutButtonPressed:(id)sender;
- (IBAction)onAddFriendsButtonPressed:(id)sender;
-(IBAction)shakeGallery:(id)sender;
- (IBAction)stopShaking:(id)sender;
- (IBAction)setProfilePictureButtonPressed:(id)sender;

@end
