//
//  CCServerLoadFacebookFriendsDelegate.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCServerLoadFacebookFriendsDelegate <NSObject>

- (void)successfullyLoadedFacebookFriends:(NSArray *)facebookFriends;
- (void)failedLoadingFacebookFriendsWithReason:(NSString *)reason;

@end
