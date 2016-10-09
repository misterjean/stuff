//
//  CCParseAuthenticator.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAuthenticationProvider.h"
#import "Parse/Parse.h"
#import "CCConstants.h"
#import "CCParseUser.h"

@interface CCParseAuthenticator : NSObject <CCAuthenticator, PF_FBRequestDelegate, PF_FBSessionDelegate>
{
    NSString            *username;
    NSString            *password;
    uint32_t            isTryingToAuthenticateWithUsernameAndPassword;
    uint32_t            isTryingToAuthenticateWithFacebook;    
    NSDictionary*       facebookUserData;
    NSCondition         *facebookLoadingDataCondition;
    NSDictionary*       facebookUserPermissions;
}

@end
