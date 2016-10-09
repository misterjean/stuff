//
//  CCAuthenticator.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCConstants.h"

@protocol CCAuthenticator <NSObject>

@optional
- (id) initWithUsername:(NSString *) loginUsername andPassword:(NSString *) loginPassword;

@required 
- (void) authenticateInBackgroundWithBlock:(CCUserResultBlock) block forceFacebookAuthentication:(BOOL) forceFacebook;
- (void) signUpNewUserInBackgroundWithBlock:(CCUserResultBlock) block;

// This method takes care of analyzing the user's phone number, email address and Facebook ID to join crews, find friends, etc.
- (void) tryToActivateNewUser:(id<CCUser>) user withBlock:(CCBooleanResultBlock) block;

@end
