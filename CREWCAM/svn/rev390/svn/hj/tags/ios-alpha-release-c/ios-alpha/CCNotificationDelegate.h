//
//  CCNotificationDelegate.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCNotificationDelegate <NSObject>

- (void)notificationReceivedWithData:(NSDictionary *)data;

@end
