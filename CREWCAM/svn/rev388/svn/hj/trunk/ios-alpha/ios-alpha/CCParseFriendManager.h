//
//  CCFriendManager.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCConstants.h"
#import "CCFriendManager.h"
#import "CCFriendConnector.h"
#import "CCFacebookFriendConnector.h"
#import "CCParseUser.h"
#import "CCContactListFriendConnector.h"
#import "CCBasePerson.h"


@interface CCParseFriendManager : NSObject <CCFriendManager>
{
    id<CCFriendConnector>   facebookFriendConnector;
    id<CCFriendConnector>   contactListFriendConnector;
    uint32_t                isLoadingFriends;
    uint32_t                isLoadingCrews;
}

@end
