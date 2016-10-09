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

@protocol CCServer <NSObject>

@property (strong, nonatomic)   id<CCUser>          currentUser;

@required
- (void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken;
- (void) sendNotificationWithData:(NSDictionary *)data ToChannels:(NSArray *)channels;

// Authentication methods
- (void)startEmailAuthenticationInBackgroundWithBlock:(CCUserResultBlock) block andEmail:(NSString *)email andPassword:(NSString *)password isNewUser:(BOOL) isNewUser;
- (void)startFacebookAuthenticationInBackgroundWithForce:(BOOL) forceFacebook andBlock:(CCUserResultBlock) block;

// Object creation methods
- (void)addNewVideoWithName:(NSString *)name currentVideoLocation:(NSString *)currentVideoLocation addToCrews:(NSArray *)addToCrews delegate:(id<CCVideoUpdatesDelegate>)delegate;
- (void) retryVideoUpload:(id<CCVideo>)video forCrews:(NSArray *)crews;
- (void)addNewInviteToCrewInBackground:(id<CCCrew>) crew forUser:(id<CCUser>) user;
- (void) addNewCrewWithName:(NSString *)name privacy:(CCSecuritySetting)privacy withBlock:(CCCrewResultBlock)block;
- (void) addNewCommentToVideo:(id<CCVideo>)video withText:(NSString *)text withBlockOrNil:(CCBooleanResultBlock) block;
- (void) addNewUserFromPerson:(CCBasePerson *) person toCrews:(NSArray *) ccCrews withBlockOrNil:(CCBooleanResultBlock) block;

// Invitation methods
- (void) inviteCCFacebookPersons:(NSArray *) ccPeople toCrew:(id<CCCrew>) crew;
- (void) inviteCCAddressBookPeople:(NSArray *) ccPeople toCrew:(id<CCCrew>) crew displayMessageOnView:(UIViewController *) viewController;
;

// Reloading methods
- (void)startReloadingTheCurrentUserWithDelegateOrNil:(id<CCCoreObjectsDelegate>)delegate;

@end
