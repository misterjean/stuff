//
//  CCServer.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCServerLoginDelegate.h"
#import "CCConnectorAuthenticationCompleteDelegate.h"
#import "CCServerLoadFriendsCrewsDelegate.h"
#import "CCConnectorFriendsLoadCompleteDelegate.h"
#import "CCServerLoadFacebookFriendsDelegate.h"
#import "CCServerPostObjectDelegate.h"
#import "CCConnectorPostObjectCompleteDelegate.h"
#import "CCCrew.h"
#import "CCCrewAddedDelegate.h"

@protocol CCServer <NSObject, CCConnectorAuthenticationCompleteDelegate, CCConnectorFriendsLoadCompleteDelegate, CCConnectorPostObjectCompleteDelegate>
@required
- (void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken;

// Authentication methods

- (void)startSilentAuthenticationWithDelegate: (id<CCServerLoginDelegate>)delegate;              // Attempts to get a CCUser object based on already known user information
- (void)startFacebookAuthenticationWithDelegate: (id<CCServerLoginDelegate>)delegate;
- (void)startEmailAuthenticationWithDelegate: (id<CCServerLoginDelegate>)delegate email:(NSString *)email password:(NSString *)password isNewUser:(Boolean)isNewUser;

- (void)startLoadingFriendsCrewsWithDelegate: (id<CCServerLoadFriendsCrewsDelegate>)delegate;
- (void)startLoadingFacebookFriendsWithDelegate: (id<CCServerLoadFacebookFriendsDelegate>)delegate;
- (void)removeCurrentUserFromCrew:(id<CCCrew>)crew useNewThread:(Boolean)useNewThread;
- (void)addNewVideoWithName:(NSString *)name currentVideoLocation:(NSString *)currentVideoLocation useNewThread:(Boolean)useNewThread addToCrews:(NSArray *)addToCrews delegate:(id<CCServerPostObjectDelegate>)delegate;

- (void)addNewCrewWithName:(NSString *)name useNewThread:(Boolean)useNewThread delegateOrNil:(id<CCCrewAddedDelegate>)delegateOrNil;

@end
