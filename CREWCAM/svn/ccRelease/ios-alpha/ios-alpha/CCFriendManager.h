//
//  CCFriendManager.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCFriendManager <NSObject>
@property (strong, atomic) NSMutableArray *ccFriendConnectors;

- (void) loadContactListPeopleInBackgroundWithBlock:(CCArrayResultBlock) block;
- (void) loadFacebookFriendPeopleInBackgroundWithBlock:(CCArrayResultBlock) block;
- (void) addFacebookFriendsAndContactsWhoAreUsingCrewcamWithBlockOrNil:(CCBooleanResultBlock) block;

- (void) loadFriendsPublicCrewsInBackgroundWithBlock:(CCArrayResultBlock) block;

@end
