//
//  CCCoreObjectsDelegate.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCCoreObjectsDelegate <NSObject>
- (void)successfullyRefreshedCurrentUser;
- (void)startingToRefreshCurrentUser;
- (void)failedRefreshingCurrentUserWithReason:(NSString *)reason;
- (void)successfullyRefreshedUsersCrews;
- (void)startingToRefreshUsersCrews;
- (void)failedRefreshingUsersCrewsWithReason:(NSString *)reason;
@end
