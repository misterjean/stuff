//
//  CCServer.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "CCCrew.h"
#import "CCCoreObjectsDelegate.h"
#import "CCBasePerson.h"
#import "CCVideo.h"
#import "CCAuthenticationProvider.h"
#import "CCCustomerDatabaseKey.h"
#import "CCGlobalConfigurations.h"

@protocol CCServer <NSObject>

@property (strong, nonatomic)   id<CCUser>                          currentUser;
@property (strong, nonatomic)   id<CCAuthenticator>                 authenticator;
@property (strong, nonatomic)   CCGlobalConfigurations              *globalSettings;
@property BOOL                                                      lastVideoUploadFailed;
@property BOOL                                                      isLinkingUserToFBAccount;

@required
- (void) loadGlobalSettingsInBackgroundWithBlock:(CCBooleanResultBlock) block;

- (void) loadDatabaseKeysInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;
- (BOOL) setDatabaseForCode:(NSString *) code;
- (CCCustomerDatabaseKey *) getCustomerDatabaseKeyForCode:(NSString *) code;

- (void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken;
- (void) sendNotificationWithData:(NSDictionary *)data ToChannels:(NSArray *)channels;

// Authentication methods
- (void) startEmailAuthenticationInBackgroundWithBlock:(CCUserResultBlock) block andEmail:(NSString *)email andPassword:(NSString *)password isNewUser:(BOOL) isNewUser;
- (void) startFacebookAuthenticationInBackgroundWithForce:(BOOL) forceFacebook andBlock:(CCUserResultBlock) block;
- (void) linkCurrentUserToFacebookInBackgroundWithBlock:(CCBooleanResultBlock) block;
- (void) unlinkCurrentUserToFacebookInBackgroundWithBlock:(CCBooleanResultBlock)block;
- (void) logOutCurrentUserInBackground;
- (void) performPreloginTasksWithBlockOrNil:(CCBooleanResultBlock) block promoText:(NSString *)promoText;
- (void) changeUsernameAndPasswordWithEmail:(NSString *)email password:(NSString *)password block:(CCBooleanResultBlock)block;
- (void) sendPasswordRecoveryEmailWithEmail:(NSString *)email;
- (void) doesUserExistWithEmail:(NSString *)email block:(CCBooleanResultBlock)block;
- (void) deleteCurrentUserWithBlock:(CCBooleanResultBlock)block;

// Object creation methods
- (void) addNewVideoWithName:(NSString *)name currentVideoLocation:(NSString *)currentVideoLocation addToCrews:(NSArray *)addToCrews addToFacebook:(BOOL)addToFacebook mediaSource:(ccMediaSources)mediaSource;
- (void) retryVideoUploadWithUploader:(id<CCVideoUploader>) uploader;
- (BOOL) isUploading;

- (void) loadSingleVideoInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCVideoResultBlock)block;
- (void) loadSingleCrewInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCCrewResultBlock)block;
- (void) addNewInviteToCrewInBackground:(id<CCCrew>) crew forUser:(id<CCUser>) user fromUser:(id<CCUser>) invitor withNotification:(BOOL)sendNotification;
- (void) addNewCrewWithName:(NSString *)name privacy:(CCSecuritySetting)privacy withBlock:(CCCrewResultBlock)block;
- (void) addNewCommentToVideo:(id<CCVideo>)video inCrew:(id<CCCrew>)crew withText:(NSString *)text withBlockOrNil:(CCBooleanResultBlock) block;
- (void) addNewUserFromPerson:(CCBasePerson *) person toCrews:(NSArray *) ccCrews withBlockOrNil:(CCBooleanResultBlock) block;

// Invitation methods
- (void) inviteCCFacebookPersons:(NSArray *) ccPeople toCrew:(id<CCCrew>) crew;
- (void) inviteCCAddressBookPeople:(NSArray *) ccPeople toCrew:(id<CCCrew>) crew displayMessageOnView:(UIViewController *) viewController withBlock:(CCBooleanResultBlock) block;
;

// Reloading methods
- (void) startReloadingTheCurrentUserWithDelegateOrNil:(id<CCCoreObjectsDelegate>)delegate;

//Helper Methods
- (NSArray *) getUsersPotentialAutoCrewIds;
- (BOOL) validateEmail: (NSString *) candidate;

@end
