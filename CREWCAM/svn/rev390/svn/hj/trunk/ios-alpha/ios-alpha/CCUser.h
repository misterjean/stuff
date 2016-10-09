//
//  CCUser.h
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCServerStoredObject.h"
#import "CoreLocation/CoreLocation.h"

// Forward decleration to solve circular protocols
@protocol CCCrew;       
@protocol CCInvite;

// User update delegate for objects that wish to "subscribe" to changes on the user object
@protocol CCUserUpdatesDelegate <NSObject>

// Optional methods implementors can implement to be notified about various changes
@optional
- (void) startingToReloadAllCrews;
- (void) finishedLoadingAllCrewsWithSuccess:(BOOL) successful andError:(NSError *) error;
- (void) addedNewCrewsAtIndexes:(NSArray *) newCrewsIndexes andRemovedCrewsAtIndexes:(NSArray *) deletedCrewsIndexes;
- (void) startingToLeaveCrew:(id<CCCrew>) crew;
- (void) finishedLeavingCrew:(id<CCCrew>) crew;

- (void) startingToReloadAllInvites;
- (void) finishedReloadingAllInvitesWithSucces:(BOOL) successful andError:(NSError *) error;
- (void) addedNewInvitesAtIndexes:(NSArray *) addedInviteIndexes andRemovedInvitesAtIndexes:(NSArray *)removedInviteIndexes;

- (void) startingToReloadAllNotifications;
- (void) startingToClearAllNotifications;
- (void) finishedReloadingAllNotificationsWithSucces:(BOOL) successful andError:(NSError *) error;
- (void) addedNewNotificationsAtIndexes:(NSArray *) addedNotificationIndexes andRemovedNotificationsAtIndexes:(NSArray *)removedNotificationIndexes;

@end

@protocol CCUser <CCServerStoredObject>

@required

- (void) logOutUserInBackground;
- (void) deleteUser;
- (void) deleteUserInBackgroundWithBlock:(CCBooleanResultBlock)block;

// Notification management
- (void)sendNotificationWithMessage:(NSString*) message;
- (void)sendNotificationWithData:(NSDictionary *)data;
- (BOOL)notificationReceivedWithData:(NSDictionary *)data;
- (void)subscribeToUserAndGlobalChannelInBackground;
- (void)unsubscribeToUserAndGlobalChannelInBackground;

// Getter/Setter methods
- (NSString *) getUserID;
- (BOOL)    getIsUserNew;

- (void)    setHasUserLoggedIn:(BOOL) hasLoggedOn;
- (BOOL)    getHasUserLoggedIn;

- (NSString *) getUserChannel;

- (void) setLastName:(NSString *) lastName;
- (NSString *) getLastName;

- (void) setFirstName:(NSString *) firstName;
- (NSString *) getFirstName;
@property (strong, nonatomic) NSData            *userImageData;

- (void) setEmailAddress:(NSString *) emailAddress;
- (NSString *) getEmailAddress;

- (void) setGender:(NSString *) gender;
- (NSString *) getGender;

- (void) setProfilePicture:(UIImage *) profilePicture;
- (UIImage *) getProfilePicture;

- (void) setLocation:(CLLocation *) location;
- (CLLocation *) getLocation;

- (void) setFacebookID:(NSString *) facebookID;
- (NSString *) getFacebookID;

- (void) setPhoneNumber:(NSString *) phoneNumber;
- (NSString *) getPhoneNumber;

- (void) setUserLock:(BOOL) isLocked;
- (BOOL) isUserLocked;

- (void) setUserActive:(BOOL) isActive;
- (BOOL) isUserActive;

- (void) setUserIsDeveloper:(BOOL) isDeveloper;
- (BOOL) isUserDeveloper;

- (void) setNumberOfInvites:(NSNumber *) numberOfInvites;
- (NSNumber *) getNumberOfInvitesLeft;

- (void) setFacebookUserWallPostPermission:(BOOL)permission;
- (BOOL) getFacebookUserWallPostPermission;

- (void) loadCrewsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;
- (void) addUserToCrewLocally:(id<CCCrew>)crew;
- (void) removeUserFromCrewLocally:(id<CCCrew>)crew;
- (void) removeUserFromCrew:(id<CCCrew>)crew WithBlockOrNil:(CCBooleanResultBlock)block;
@property (strong, atomic)  NSMutableArray *ccCrews;

- (void) loadInvitesInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;
- (void) removeInviteLocally:(id<CCInvite>) invite;
@property (strong, atomic)  NSMutableArray *ccInvites;

- (void) loadNotificationsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;
@property (strong, atomic)  NSMutableArray *ccNotifications;

//Dummy placeholder

@property (strong, nonatomic) UIImage * localUIImage;

// Helper methods

- (id<CCCrew>) getCrewFromObjectID: (NSString*)crewObjectID;
- (NSArray *) getArrayOfCrewIDs;

- (void) getVideo:(out id<CCVideo> *)video InCrew:(out id<CCCrew> *)crew FromObjectID:(NSString *)objectID; 
- (void) getVideoAndCrewFromServerFromVideoID:(NSString *)videoID withBlock:(CCCrewVideoResultBlock)block;

// Notifier methods
@property (strong, atomic) NSMutableArray *userUpdateDelegates;
@property (strong, atomic) NSMutableArray *userUpdateDelegatesToAdd;
@property (strong, atomic) NSMutableArray *userUpdateDelegatesToRemove;
- (void) addUserUpdateListener:(id<CCUserUpdatesDelegate>) delegate;
- (void) removeUserUpdateListener:(id<CCUserUpdatesDelegate>) delegate;

@optional

@end