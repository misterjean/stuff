//
//  CCAuthenticator.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCConnectorAuthenticationCompleteDelegate.h"

typedef enum CCConnectorType {
    ccFacebookConnector = 0,
    ccTwitterConnector,
    ccEmailConnector
} CCConnectorType;

@protocol CCAuthenticationProvider <NSObject>

@required 
- (void)startAuthenticatingWithDelegate:(id<CCConnectorAuthenticationCompleteDelegate>) delegate;
- (void)startAuthenticatingWithDelegate:(id<CCConnectorAuthenticationCompleteDelegate>)delegate email:(NSString *)username password:(NSString *)password;
- (void)tryToSilentlyAuthenticateWithDelegate:(id<CCConnectorAuthenticationCompleteDelegate>) delegate;

@end
