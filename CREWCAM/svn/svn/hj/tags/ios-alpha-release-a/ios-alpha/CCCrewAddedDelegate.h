//
//  CCCrewAddedDelegate.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCCrew.h"

@protocol CCCrewAddedDelegate <NSObject>
- (void)successfullyAddedCrew:(id<CCCrew>)crew;
- (void)failedAddingCrewWithReason:(NSString *)reason;
@end
