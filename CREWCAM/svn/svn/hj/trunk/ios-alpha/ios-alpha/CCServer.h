//
//  CCServer.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "CCServerLoginDelegate.h"
#import "CCConnectorAuthenticationCompleteDelegate.h"
#import "CCConnectorFriendsLoadCompleteDelegate.h"
#import "CCServerPostObjectDelegate.h"
#import "CCCrew.h"
#import "CCCoreObjectsDelegate.h"

@protocol CCServer <NSObject, CCConnectorAuthenticationCompleteDelegate, CCConnectorFriendsLoadCompleteDelegate>

@property (strong, nonatomic)   id<CCUser>          currentUser;

@required
- (void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken;

// Authentication methods

- (void)startSilentAuthenticationWithDelegate: (id<CCServerLoginDelegate>)delegate;              // Attempts to get a CCUser object based on already known user information
- (void)startFacebookAuthenticationWithDelegate: (id<CCServerLoginDelegate>)delegate;
- (void)startEmailAuthenticationWithDelegate: (id<CCServerLoginDelegate>)delegate email:(NSString *)email password:(NSString *)password isNewUser:(Boolean)isNewUser;
- (void)removeCurrentUserFromCrew:(id<CCCrew>)crew useNewThread:(Boolean)useNewThread;
- (void)addNewVideoWithName:(NSString *)name currentVideoLocation:(NSString *)currentVideoLocation useNewThread:(Boolean)useNewThread addToCrews:(NSArray *)addToCrews delegate:(id<CCServerUploadVideoDelegate>)delegate;

- (void)startReloadingTheCurrentUserWithDelegateOrNil:(id<CCCoreObjectsDelegate>)delegate;
- (void)startReloadingTheCurrentUsersCrewsWithDelegateOrNil:(id<CCCoreObjectsDelegate>)delegate;

- (id<CCCrew>) getCrewFromObjectID: (NSString*)crewObjectID;

- (void )startLoadingFriendsWithBlock:(CCArrayResultBlock)block;
- (void)startLoadingFriendsCrewsWithBlock:(CCArrayResultBlock)block;
- (void) addNewCrewWithName:(NSString *)name privacy:(NSInteger)privacy withBlock:(CCCrewResultBlock)block;

@end
