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
#import "CCCoreManager.h"
#import "CCUser.h"
#import "NSDate+Utility.h"

@interface CCNotificationTableViewCell : UITableViewCell
{
    id<CCNotification>          notificationForCell;
    UINavigationController      *parentViewController;
}

@property (weak, nonatomic) IBOutlet UILabel        *notificationMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel        *timeSinceLabel;
@property (weak, nonatomic) IBOutlet UIButton       *viewDetailsButton;

+ (CCNotificationTableViewCell *) createNotificationCellForNotification:(id<CCNotification>) notification forTable:(UITableView *) table andViewController:(UINavigationController *) viewController;
- (IBAction)openNotificationButtonPressedWithSender:(id)sender;
@end
