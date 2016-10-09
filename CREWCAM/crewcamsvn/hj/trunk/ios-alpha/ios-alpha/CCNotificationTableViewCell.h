//
//  CCNotificationTableViewCell.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNotification.h"
#import "CCVideosCommentsViewController.h"
#import "CCCrewMembersViewController.h"
#import "CCCrewViewController.h"
#import "CCNotificationsViewController.h"
#import "CCCoreManager.h"
#import "CCUser.h"
#import "NSDate+Utility.h"
#import "CCLongTextCustomTextView.h"

typedef enum {
    acceptFriendRequestAlertTag = 1,
    textTag,
} alertViewTag;

@interface CCNotificationTableViewCell : UITableViewCell <CCCrewcamAlertViewDelegate>
{
    id<CCNotification>                                  notificationForCell;
    CCNotificationsViewController                       *parentViewController;
}

@property (weak, nonatomic) IBOutlet UITextView         *notificationMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel            *timeSinceLabel;
@property (weak, nonatomic) IBOutlet UIButton           *viewDetailsButton;
@property (weak, nonatomic) IBOutlet UIImageView        *userThumbnailView;

+ (CCNotificationTableViewCell *) createNotificationCellForNotification:(id<CCNotification>) notification forTable:(UITableView *) table andViewController:(CCNotificationsViewController *) viewController;
- (IBAction)openNotificationButtonPressedWithSender:(id)sender;
@end
