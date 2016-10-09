//
//  CCConnectorAuthenticationCompleteDelegate.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCConnectorAuthenticationCompleteDelegate <NSObject>

@required
- (void)authenticationCompleteWithId: (NSString *)userId isNewUser:(Boolean)isNewUser connectorType:(int) connectorType; 
- (void)authenticationFailedWithReason: (NSString *)reason; 
- (void)silentAuthenticationCompleteWithId: (NSString *)userId isNewUser:(Boolean)isNewUser connectorType:(int) connectorType;
- (void)silentAuthenticationFailedWithReason: (NSString *)reason;

@end
