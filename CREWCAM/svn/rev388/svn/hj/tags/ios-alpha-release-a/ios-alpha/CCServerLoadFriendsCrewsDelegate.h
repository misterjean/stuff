//
//  CCServerLoadFriendsCrewsDelegate.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCServerLoadFriendsCrewsDelegate <NSObject>
- (void)successfullyLoadedFriendsCrews:(NSArray *)crews;
- (void)failedLoadingFriendsCrewsWithReason:(NSString *)reason;
@end
