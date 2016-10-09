//
//  CCConnectorFriendsLoadCompleteDelegate.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAuthenticationProvider.h"

@protocol CCConnectorFriendsLoadCompleteDelegate <NSObject>
- (void)successfullyLoadedFriends:(NSArray *)friendNamesAndIds connectorType:(CCConnectorType)connectorType;
- (void)failedLoadingFriendsWithReason:(NSString *)reason;
@end
