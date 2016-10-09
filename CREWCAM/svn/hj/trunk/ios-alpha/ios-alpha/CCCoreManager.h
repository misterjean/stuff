//
//  CCCoreManager.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "CCServer.h"
#import "CCParseServer.h"
#import "CCLogger.h"
#import "CCUser.h"
#import "CCLocationManager.h"
#import "CCConstants.h"
#import "CCNotificationDelegate.h"
#import "Reachability.h"
#import "CCParseFriendManager.h"

@interface CCCoreManager : NSObject
{
    uint32_t isIgnoringNotifications;
    NSTimer *connectivityTimer;
}
@property (strong, nonatomic)   id<CCServer>            server;
@property (strong, nonatomic)   CCLogger                *logger;
@property (strong, nonatomic)   CCLocationManager       *locationManager;
@property (strong, nonatomic)   id<CCFriendManager>     friendManager;
@property (strong, nonatomic)   NSMutableArray          *notificationDelegates;
@property (strong, nonatomic)   NSDictionary            *videoPushInfo;

+ (CCCoreManager *)sharedInstance;
- (void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken;
- (void)registerNotificationHandler:(id<CCNotificationDelegate>)delegate;
- (void)removeNotificationHandler:(id<CCNotificationDelegate>)delegate;
- (void)handleNotificationWithApplication:(UIApplication *)application userInfo:(NSDictionary *)userInfo;
- (void)checkNetworkConnectivity:(CCBooleanResultBlock)block;
- (void)recordMetricEvent:(NSString *)event withProperties:(NSDictionary *)properties;
- (void)registerUserForMetrics:(id<CCUser>)user;


@end
