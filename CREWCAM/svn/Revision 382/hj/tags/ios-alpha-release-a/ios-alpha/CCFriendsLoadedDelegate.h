//
//  CCFriendsLoadedDelegate.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCUser.h"

@protocol CCFriendsLoadedDelegate <NSObject>
- (void)successfullyLoadedFriends:(NSArray *) friends;

@end
