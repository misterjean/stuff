//
//  CCCrew.h
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCServerStoredObject.h"
#import "CCVideo.h"

@protocol CCUser;       // Forward decleration to solve circular protocols

typedef enum {
    CCPrivate = 0,
    CCPublic,
} CCSecuritySetting;

@protocol CCCrew <CCServerStoredObject>

@required
// Required methods
- (void)sendNotificationWithMessage:(NSString *)message;
- (void)subscribeToNotifications;
- (Boolean)containsMember:(id<CCUser>)user;
- (void)addMember:(id<CCUser>)user useNewThread:(Boolean)useNewThread;
- (void)removeMember:(id<CCUser>)user useNewThread:(Boolean)useNewThread;
- (void)loadVideosWithNewThread:(Boolean)useNewThread;
- (id<CCCrew>)initLocalCrewWithName:(NSString *)crewName;
- (void)addVideo:(id<CCVideo>)videoToPost;
- (NSArray *)getFriendsNotInCrewFromList:(NSArray *)friendsList;

// Required properties
@property (strong, nonatomic)   NSMutableArray      *members;
@property (strong, nonatomic)   NSDate              *creadedDate;
@property                       CCSecuritySetting   *securitySetting;
@property (strong, nonatomic)   NSMutableArray      *videos;

@optional

@end



