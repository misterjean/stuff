//
//  CCCrew.h
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCServerStoredObject.h"

// Forward declerations to solve circular protocols
@protocol CCUser;       
@protocol CCVideo;
@protocol CCInvite;

typedef enum {
    CCPublic,
    CCPrivate,
} CCSecuritySetting;

typedef enum {
    CCNormal,
    CCDeveloper,
    CCFBSchool,
    CCFBWork,
    CCFBLocation,
} CCCrewType;

@protocol CCCrewUpdatesDelegate <NSObject>

// Optional methods implementors can implement to be notified about various changes
@optional
- (void) startingToLoadVideos;
- (void) finishedLoadingVideosWithSuccess:(BOOL) successful andError:(NSError *) error;
- (void) addedNewVideosAtIndexes:(NSArray *) newVideoIndexes andRemovedVideosAtIndexes:(NSArray *) deletedVideoIndexes;
- (void) addedOldVideosAtIndexes:(NSArray *)oldVideoIndexes;

- (void) finishedLoadingNumberOfNewVideos:(int) numberOfNewVideos;

- (void) startingToLoadMembers;
- (void) finishedLoadingMembersCountWithSuccess:(BOOL) successful andError:(NSError *) error;
- (void) addedNewMembersAtIndexes:(NSArray *) newMemberIndexes andRemovedMembersAtIndexes:(NSArray *) deletedMemberIndexes;

- (void) startingToReloadAllInvites;
- (void) finishedReloadingAllInvitesWithSucces:(BOOL) successful andError:(NSError *) error;
- (void) addedNewInvitesAtIndexes:(NSArray *) addedInviteIndexes andRemovedInvitesAtIndexes:(NSArray *)removedInviteIndexes;

@end

@protocol CCCrew <CCServerStoredObject>

@required

//Factory Methods
+ (void) createNewCrewInBackgroundWithName:(NSString *)name creator:(id<CCUser>)creator privacy:(CCSecuritySetting)privacySetting withBlock:(CCCrewResultBlock) block;
+ (void) createNewSpecialAutoCrewInBackgroundWithName:(NSString *)name crewtype:(CCCrewType)type autoCrewId:(NSString *)crewId withBlock:(CCCrewResultBlock)block;
+ (void) loadSingleCrewInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCCrewResultBlock)block;

// NotificationManagement
- (void) sendNotificationWithMessage:(NSString *)message;
- (void) sendNotificationWithData:(NSDictionary *)data;
- (BOOL) notificationReceivedWithData:(NSDictionary *)data;

- (void)subscribeToNotifications;
- (void)unsubscribeToNotifications;

// Getter/Setter methods
- (void) setName:(NSString *) name;
- (NSString *) getName;

- (NSString *) getChannelName;

- (BOOL) hasLoadedThumbnail;
- (UIImage *) getCrewIcon;
- (void) getCrewThumbnailInBackgroundWithBlock:(CCImageResultBlock) block;

- (void) getNumberOfVideosWithBlock:(CCIntResultBlock) block andForced:(BOOL)forced;
- (void) getNumberOfMembersWithBlock:(CCIntResultBlock) block andForced:(BOOL)forced;

- (void) setSecuritySetting:(CCSecuritySetting) securitySetting;
- (CCSecuritySetting) getSecuritySetting;

- (CCCrewType) getCrewtype; 
- (NSString *) getAutoCrewId;

- (BOOL) isUploadInProgress;

- (void) reloadVideosInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;
- (void) loadVideosInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block startingAtIndex:(NSInteger)index forVideoCount:(NSInteger)count;
- (void) addVideoLocally:(id<CCVideo>) newVideo;
- (void) addVideoInBackground:(id<CCVideo>) video withBlockOrNil:(CCBooleanResultBlock) block;
- (void) removeVideoInBackground:(id<CCVideo>) video withBlockOrNil:(CCBooleanResultBlock) block;
@property (strong, atomic) NSMutableArray *ccVideos;
@property BOOL oldVideosLoaded;
@property int  numberOfOldVideos;

- (void) loadUnwatchedVideoCountInBackgroundWithBlockOrNil:(CCIntResultBlock) block;
@property int numberOfNewVideos;

- (void) loadMembersInBackgroundWithBlock:(CCBooleanResultBlock) block;
- (BOOL) loadMembers;
- (void) addMemberInBackground:(id<CCUser>) user withBlockOrNil:(CCBooleanResultBlock) block;
- (void) removeMemberInBackground:(id<CCUser>) user withBlockOrNil:(CCBooleanResultBlock) block;
@property (strong, atomic) NSMutableArray *ccUsersThatAreMembers;

- (void) loadInvitesInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;
@property (strong, atomic) NSMutableArray *ccInvites;

// Utility methods
- (Boolean) containsMember:(id<CCUser>)user;
- (Boolean) memberInvited:(id<CCUser>)user;
- (NSArray *) getFriendsNotInCrewFromList:(NSArray *) ccFriendsList;

// Notifier methods and properties
@property (strong, atomic) NSMutableArray *crewUpdateDelegates;
- (void) addCrewUpdateListener:(id<CCCrewUpdatesDelegate>) delegate;
- (void) removeCrewUpdateListener:(id<CCCrewUpdatesDelegate>) delegate;

@optional

@end



