//
//  CCFacebookFriendConnector.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCFriendConnector.h"
#import "Parse/Parse.h"
#import "CCFacebookPerson.h"
#import "CCCoreManager.h"

@interface CCFacebookFriendConnector : NSObject <CCFriendConnector, PF_FBRequestDelegate>
{
    NSCondition     *facebookLoadingCondition;
    NSDictionary    *loadedFriendsInformation;
}

@end
