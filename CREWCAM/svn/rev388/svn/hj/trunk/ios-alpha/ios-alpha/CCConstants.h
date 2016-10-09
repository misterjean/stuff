//
//  CCConstants.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CREWCAM_FACEBOOK_ID_STRING @"410003242359572"
#define LOG_KISSMETRICS DEBUG

// Tab bar indexes
#define MY_CREWS_TAB_BAR_INDEX          0
#define JOIN_TAB_TAB_BAR_INDEX          1
#define INVITES_TAB_BAR_INDEX           2
#define NOTIFICATIONS_TAB_BAR_INDEX     3


@protocol CCUser;   // Forward decleration to avoid circular references
@protocol CCCrew;   // Forward decleration to avoid circular references
@protocol CCComment;// Forward decleration to avoid circular references
@protocol CCVideo;   // Forward decleration to avoid circular references

typedef void (^CCBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^CCIntResultBlock)(int numberOfUnwatchedVideos, BOOL succeded, NSError *error);
typedef void (^CCArrayResultBlock)(NSArray *array, NSError *error);
typedef void (^CCUserResultBlock)(id<CCUser> user, BOOL succeeded, NSError *error);
typedef void (^CCCrewResultBlock)(id<CCCrew> objectId, BOOL succeeded, NSError *error);
typedef void (^CCCommentResultBlock)(id<CCComment> objectId, BOOL succeeded, NSError *error);
typedef void (^CCVideoResultBlock)(id<CCVideo> objectId, BOOL succeeded, NSError *error);
typedef void (^CCCrewVideoResultBlock)(id<CCCrew> crewObjectId, id<CCVideo> videoObjectId, BOOL succeeded, NSError *error);

typedef enum {
    ccVideoPushNotification,
    ccCrewPushNotification,
    CCInvitePush,
    CCCommentPush,
    CCViewPush,
    CCCommentPushAlert,
} ccPushNotificationTypes;

typedef enum {
    ccCamera,
    ccVideoLibrary,
} ccMediaSources;

// Crewcam notification types
typedef enum {
    ccNewCommentNotification,
    ccNewVideoNotification,
    ccInviteAcceptedNotification,
    ccFriendJoinedNotification, 
} ccNotificationTypes;

// And related notification identifier strings
#define CC_SHOW_NOTIFICATIONS_TAB                   @"ccShowNotificationsTab"
#define CC_SHOW_VIDEOS_COMMENTS_NOTIFICATION        @"ccShowCommentsView"
#define CC_SHOW_VIDEO_NOTIFICATION                  @"ccShowVideoView"
#define CC_SHOW_CREW_NOTIFICATION                   @"ccShowCrewView"
#define CC_SHOW_CREWS_MEMBERS_NOTIFICATION          @"ccShowCrewsMembersView"
#define CC_SHOW_CREW_INVITES                        @"ccShowCrewInvites"
#define CC_RELOAD_NOTIFICATIONS_TAB                 @"ccReloadNotificationTab"