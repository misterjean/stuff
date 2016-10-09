//
//  CCCoreManager.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCoreManager.h"

@implementation CCCoreManager

@synthesize server;
@synthesize logger;
@synthesize locationManager;
@synthesize notificationDelegates;

- (id) init
{    
    self = [super init];
    
    if (self != nil)
    {
        // For now, the only server we know about is a Parse server.  In the future we could use different servers
        server = [[CCParseServer alloc] init];
        logger = [[CCLogger alloc] init];
        locationManager = [[CCLocationManager alloc] init];
        [locationManager startStandardUpdates];
        notificationDelegates = [[NSMutableArray alloc] init];
#if LOG_KISSMETRICS    
        [KISSMetricsAPI sharedAPIWithKey:@"649273ad7ce80589f4bb0175f47e95289b745ded"];
#endif
    }
    
    return self;
}

+ (CCCoreManager *)sharedInstance
{
    static dispatch_once_t pred;
    static CCCoreManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[CCCoreManager alloc] init];
    });
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken
{    
    [server configureNotificationsWithDeviceToken:newDeviceToken];
}

- (void)registerNotificationHandler:(id<CCNotificationDelegate>)delegate
{
    if (delegate != nil && ![[self notificationDelegates] containsObject:delegate])
    {
        [[self notificationDelegates] addObject:delegate];
    }
}

- (void)removeNotificationHandler:(id<CCNotificationDelegate>)delegate
{
    if (delegate != nil && [[self notificationDelegates] containsObject:delegate])
    {
        [[self notificationDelegates] removeObject:delegate];
    }
}

- (void)handleNotificationWithApplication:(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
    if ( [userInfo objectForKey:@"src_User"] != nil)
    {
        if (![[[server currentUser] objectID] isEqualToString:[userInfo objectForKey:@"src_User"]])
        {
            [self interpretNotificationWithApllication:application userInfo:userInfo];
        }
    }
    else 
    {
        [self interpretNotificationWithApllication:application userInfo:userInfo];
    }
}

- (void) interpretNotificationWithApllication:(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"badge"] != nil)
    {
        application.applicationIconBadgeNumber += [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
    }
    for(id<CCNotificationDelegate> delegate in [self notificationDelegates])
    {
        [delegate notificationReceivedWithData:userInfo];
    }
    
    [self handlePush:userInfo];
}

- (void) handlePush:(NSDictionary *)userInfo
{
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"] != nil)
    {
        UIAlertView *alert; 
        
        if ([[userInfo objectForKey:@"type"] isEqualToString:@"type_video"])
        {
            alert = [[UIAlertView alloc] initWithTitle:nil message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] 
                                              delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View Video",nil];
        }
        else
        {
            alert = [[UIAlertView alloc] initWithTitle:nil message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] 
                                              delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        }
        [alert show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{     

}


- (void)recordMetricEvent:(NSString *)event withProperties:(NSDictionary *)properties
{
#if LOG_KISSMETRICS 
    [[KISSMetricsAPI sharedAPI] recordEvent:event withProperties:properties];
#endif
}

- (void)registerUserForMetrics:(id<CCUser>)user
{    
#if LOG_KISSMETRICS
    [[KISSMetricsAPI sharedAPI] identify:[[NSString alloc] initWithFormat:@"%@ (%@)", [user name], [user objectID]]];                 
#endif
}

@end
