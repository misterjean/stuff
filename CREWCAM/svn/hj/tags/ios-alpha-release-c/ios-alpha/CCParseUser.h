//
//  CCParseUser.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "CCUser.h"
#import "CCParseObject.h"
#import "CCParseCrew.h"
#import "CCParseInvite.h"
#import "CCCoreManager.h"

@interface CCParseUser : CCParseObject <CCUser>
{
    uint32_t    isLoadingCrews;
    uint32_t    isLoadingInvites;
    NSLock      *userUpdateDelegatesLock;
}

@end
