//
//  CCNotificationTableViewCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNotificationTableViewCell.h"

@implementation CCNotificationTableViewCell
@synthesize notificationMessageLabel;
@synthesize timeSinceLabel;
@synthesize viewDetailsButton;

+ (CCNotificationTableViewCell *) createNotificationCellForNotification:(id<CCNotification>) notification forTable:(UITableView *) table andViewController:(UINavigationController *) viewController
{
    NSString *cellIdentifier = @"notificationCell";
    
    CCNotificationTableViewCell *cell = [table dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[CCNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Do type-specific things
    switch ([notification getNotificationType]) {
        case ccNewCommentNotification:

            break;
        case ccFriendJoinedNotification:
            [[cell viewDetailsButton] setHidden:YES];
            break;
        case ccInviteAcceptedNotification:
            
            break;
        case ccNewVideoNotification:

            break;
        default:
#warning Do we need to handle this?
            break;
    }    
    
    [cell setUpForNotification:notification andViewController:viewController];
    
    return cell;
}


- (void) setUpForNotification:(id<CCNotification>) notification andViewController:(UINavigationController *) viewController
{
    parentViewController = viewController;
    notificationForCell = notification;
    [notificationMessageLabel setText:[notificationForCell getNotificationMessage]];
    [timeSinceLabel setText:[NSDate getTimeSinceStringFromDate:[notificationForCell getObjectCreatedDate]]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)openNotificationButtonPressedWithSender:(id)sender
{
    if (!notificationForCell)
        return;        
    
    NSDictionary *notificationInfo = [[NSDictionary alloc] initWithObjectsAndKeys:notificationForCell, @"ccNotificationData", nil];    
    
    // Notify various parts of the app what we need to do:
    switch ([notificationForCell getNotificationType]) {
        case ccFriendJoinedNotification:
        {         
            break;
        }
        case ccInviteAcceptedNotification:
        {
            CCCrewMembersViewController *crewsMembersView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewMembersView"];
            
            [crewsMembersView setCrewForView:[[[[CCCoreManager sharedInstance] server] currentUser] getCrewFromObjectID:[notificationForCell getTargetCrewObjectID]]];
            
            [parentViewController pushViewController:crewsMembersView animated:YES];
            break;
        }
        case ccNewVideoNotification:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CC_SHOW_VIDEO_NOTIFICATION object:nil userInfo:notificationInfo];
            break;
        }
        case ccNewCommentNotification:
        {
            [[[CCCoreManager sharedInstance] server] loadSingleVideoInBackgroundWithObjectID:[notificationForCell getTargetObjectId] andBlock:^(id<CCVideo> video, BOOL succeeded, NSError *error) {
                CCVideosCommentsViewController *videosCommentsView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"videosCommentsView"];
                
                [videosCommentsView setVideoForView:video];
                                
                [parentViewController pushViewController:videosCommentsView animated:YES];
            }];
            break;
        }
    }
}

@end
