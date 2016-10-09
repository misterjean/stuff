//
//  CCFriendConnector.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCConstants.h"

@protocol CCFriendConnector <NSObject>
@required 
- (NSArray *) loadFriends;
@end
