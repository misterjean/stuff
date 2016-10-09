//
//  CCServerLoginDelegate.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCUser.h"

@protocol CCServerLoginDelegate <NSObject>

@required
- (void)loginCompleteWithUser: (id<CCUser>) user isNewUser:(Boolean)isNewUser; 
- (void)loginFailedWithReason: (NSString *)reason;
- (void)silentLoginCompleteWithUser: (id<CCUser>) user isNewUser:(Boolean)isNewUser; 
- (void)silentLoginFailedWithReason: (NSString *)reason; 
@end
