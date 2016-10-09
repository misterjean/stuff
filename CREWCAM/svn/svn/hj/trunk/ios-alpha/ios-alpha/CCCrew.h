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
    CCPublic,
    CCPrivate,
} CCSecuritySetting;

@protocol CCCrewUpdateDelegate <NSObject>

- (void)addingVideoToCrew:(id<CCCrew>)crew videoBeingAdded:(id<CCVideo>)video;

@end

@protocol CCCrew <CCServerStoredObject>

@required
// Required methods
- (void)sendNotificationWithMessage:(NSString *)message;
- (void)sendNotificationWithData:(NSDictionary *)data;
- (void)subscribeToNotifications;
- (void)unsubscribeToNotifications;
- (Boolean)containsMember:(id<CCUser>)user;
- (Boolean)memberInvited:(id<CCUser>)user;
- (void)addMember:(id<CCUser>)user;
- (void)removeMember:(id<CCUser>)user;
- (void)loadVideosWithNewThread:(Boolean)useNewThread;
- (id<CCCrew>)initLocalCrewWithName:(NSString *)crewName privacy:(NSInteger)privacy;
- (void)addVideo:(id<CCVideo>)videoToPost;
- (NSArray *)getFriendsNotInCrewFromList:(NSArray *)friendsList;
- (void)addCrewUpdateDelegate:(id<CCCrewUpdateDelegate>) delegate;   
- (void)removeCrewUpdateDelegate:(id<CCCrewUpdateDelegate>) delegate;

// Required properties
@property (strong, nonatomic)   NSMutableArray      *members;
@property (strong, nonatomic)   NSDate              *creadedDate;
@property                       CCSecuritySetting   securitySetting;
@property (strong, nonatomic)   NSMutableArray      *videos;
@property (strong, nonatomic)   NSMutableArray      *pfInvites;
@property (strong, nonatomic)   NSMutableArray      *crewUpdateDelegates;

@optional

@end



