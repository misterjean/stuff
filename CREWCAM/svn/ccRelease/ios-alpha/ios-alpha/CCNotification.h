//
//  CCNotification.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCServerStoredObject.h"

// Crewcam notification types
typedef enum {
    ccNewCommentNotification,
    ccNewVideoNotification,
    ccInviteAcceptedNotification,
    ccFriendJoinedNotification,
    ccFriendRequestNotification,
    ccFriendRequestAcceptedNotification,
    ccNewViewNotification,
} ccNotificationTypes;

@protocol CCNotification <CCServerStoredObject>

+ (id<CCNotification>) createNewNotificationInBackgroundWithType:(ccNotificationTypes) notificationType andTargetUser:(id<CCUser>) targetUser andSourceUser:(id<CCUser>) sourceUser andTargetObject:(id<CCServerStoredObject>) targetObject andTargetCrewOrNil:(id<CCCrew>) targetCrew andMessage:(NSString *) message;

- (ccNotificationTypes) getNotificationType;
- (id<CCUser>) getTargetUser;
- (id<CCUser>) getSourceUser;
- (NSString *) getTargetObjectId;
- (NSString *) getNotificationMessage;
- (void) setNotificationMessage:(NSString *)message; 
- (NSString *) getTargetCrewObjectID;
- (BOOL) getIsViewed;
- (BOOL) getIsClicked;

- (void) setIsViewedWithBlock:(CCBooleanResultBlock)block;
- (void) setIsClickedWithBlock:(CCBooleanResultBlock)block;

@end
