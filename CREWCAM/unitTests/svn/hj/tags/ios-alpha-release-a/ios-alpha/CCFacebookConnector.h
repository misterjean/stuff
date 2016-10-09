//
//  CCFacebookConnector.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCFriendConnector.h"
#import "Parse/Parse.h"
#import "CCServerLoginDelegate.h"
#import "CCConnectorAuthenticationCompleteDelegate.h"
#import "CCAuthenticationProvider.h"
#import "CCUser.h"
#import "CCConnectorFriendsLoadCompleteDelegate.h"

@interface CCFacebookConnector : NSObject <CCAuthenticationProvider, CCFriendConnector, PF_FBRequestDelegate, PF_FBSessionDelegate>
{
    id<CCConnectorAuthenticationCompleteDelegate>   authenticationCompleteDelegate;
    id<CCConnectorFriendsLoadCompleteDelegate>      friendsLoadCompleteDelegate;
    NSDictionary* currentUserData;
    Boolean isSilentAttempt;
}

- (void)setWithFacebookDataUser:(id<CCUser>) user;

@end
