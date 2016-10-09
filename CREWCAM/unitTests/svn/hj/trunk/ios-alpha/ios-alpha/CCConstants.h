//
//  CCConstants.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCKissMetricStrings.h"

// Database defines for versioning
#define CC_PARSE_APPLICATION_ID_RELEASE @"UA2bjSA0tJQ3eajFVMs6rO1CEKldAaADYdUC8h6F"
#define CC_PARSE_CLIENT_KEY_RELEASE     @"tqFvnlKUw9gYNi4qGEWec7dUPDZ0CW0jE7wiYSBk"

#define CC_PARSE_APPLICATION_ID_DEBUG @"khihSVh1T6c2ltrPqsawO9SwuCTifnYGuxXAbCpm"
#define CC_PARSE_CLIENT_KEY_DEBUG     @"g4beEtDzTbGzDqhPeYcSAh0gmmGQ8fQfphIEA8k3"

#define USE_DEBUG_DATABASE DEBUG

#if USE_DEBUG_DATABASE && !DEBUG
#warning YOU ARE USING THE DEBUG DATABASE IN A REALEASE BUILD
#endif

#if USE_DEBUG_DATABASE
#define CC_PARSE_APPLICATION_ID CC_PARSE_APPLICATION_ID_DEBUG
#define CC_PARSE_CLIENT_KEY     CC_PARSE_CLIENT_KEY_DEBUG
#else
#define CC_PARSE_APPLICATION_ID CC_PARSE_APPLICATION_ID_RELEASE
#define CC_PARSE_CLIENT_KEY     CC_PARSE_CLIENT_KEY_RELEASE
#endif

#define CC_NEW_USER_INVITE_LIMIT        5

#define CREWCAM_FACEBOOK_ID_STRING      @"410003242359572"

// KISSmetrics
#define LOG_KISSMETRICS 1
#define CC_KISSMETRICS_RELEASE_KEY      @"649273ad7ce80589f4bb0175f47e95289b745ded"
#define CC_KISSMETRICS_PRE_RELEASE_KEY  @"112d869be08252467308e1dc867e623a0547cd7a"

#if DEBUG
#define CC_KISSMETRICS_KEY CC_KISSMETRICS_PRE_RELEASE_KEY
#else
#define CC_KISSMETRICS_KEY CC_KISSMETRICS_RELEASE_KEY
#endif

// Tab bar indexes
#define MY_CREWS_TAB_BAR_INDEX              0
#define JOIN_TAB_TAB_BAR_INDEX              1
#define INVITES_TAB_BAR_INDEX               2
#define NOTIFICATIONS_TAB_BAR_INDEX         3

@protocol CCUser;       // Forward decleration to avoid circular references
@protocol CCCrew;       // Forward decleration to avoid circular references
@protocol CCComment;    // Forward decleration to avoid circular references
@protocol CCVideo;      // Forward decleration to avoid circular references

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
} ccPushNotificationTypes;

typedef enum{
    CCCommentPushAlert,
    CCLogoutAlert,
} ccAlertDialogTags;


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
#define CC_VIDEO_UPLOADER_BUSY                      @"ccVideoUploaderBusy"
#define CC_VIDEO_UPLOADER_FREE                      @"ccVideoUploaderFree"
#define CC_NOTIFICATIONS_VIEWED                 	@"ccNotificationsViewed"