//
//  CCParseAuthenticator.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseAuthenticator.h"
#import "CCConnectorAuthenticationCompleteDelegate.h"

@implementation CCParseAuthenticator

- (void)startAuthenticatingWithDelegate:(id<CCConnectorAuthenticationCompleteDelegate>) delegate
{
    [delegate authenticationFailedWithReason:@"Parse authenticator must be called with email and password"];
}

- (void)startAuthenticatingWithDelegate:(id<CCConnectorAuthenticationCompleteDelegate>)delegate email:(NSString *)email password:(NSString *)password
{
    PFUser *user;
    NSError *error;
    
    user = [PFUser logInWithUsername:email password:password error:&error];
    if(user)
    {
        [delegate authenticationCompleteWithId:email isNewUser:NO connectorType:ccEmailConnector];
    }
    else 
    {
        [delegate authenticationFailedWithReason:[error localizedDescription]];
    }

    
}

- (void)tryToSilentlyAuthenticateWithDelegate:(id<CCConnectorAuthenticationCompleteDelegate>) delegate
{
    [delegate silentAuthenticationFailedWithReason:@"Silent authentication not implemented for the Parse authenticator"];
}

@end
