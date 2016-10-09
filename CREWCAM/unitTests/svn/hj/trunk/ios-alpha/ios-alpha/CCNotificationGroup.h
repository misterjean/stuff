//
//  CCNotificationGroup.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-06-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCConstants.h"
#import "CCNotification.h"

@interface CCNotificationGroup : NSObject

@property ccPushNotificationTypes notificationType;
@property NSString *parentParseObjectId;
@property NSDate *ageOfYoungestNotification;
@property NSMutableArray *groupedNotifications;

@end
