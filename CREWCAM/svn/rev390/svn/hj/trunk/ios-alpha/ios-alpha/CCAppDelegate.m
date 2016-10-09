//
//  CCAppDelegate.m
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCAppDelegate.h"

@implementation CCAppDelegate

@synthesize window = _window;

void uncaughtExceptionHandler(NSException *exception) 
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}
    

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
#ifdef DEBUG
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif
    
    // Ask for APS
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    // Configure TestFlight    
#ifndef DEBUG
    [TestFlight takeOff:@"f0f1d7e9acaba583873d5a7973d3d0fc_ODU5MjkyMDEyLTA0LTMwIDIyOjAwOjU5Ljc0OTQxMA"];
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif

    return YES;
}

// Notification subscription failed
- (void)application:(UIApplication *)application 
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed registering for notifications: %@", [error localizedDescription]];
}

- (void)application:(UIApplication *)application 
didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    [[CCCoreManager sharedInstance] handleNotificationWithApplication:application userInfo:userInfo];    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    return [PFFacebookUtils handleOpenURL:url]; 
}

// Notification subscription suceeded
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [[CCCoreManager sharedInstance] configureNotificationsWithDeviceToken:newDeviceToken];
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Succesfully registered for notifications."];
}                        

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[[CCCoreManager sharedInstance] locationManager] stopStandardUpdates];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    for (id<CCCrew> crew in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews]) 
    {
        for (id<CCVideo> video in [crew ccVideos])
        {
            [video clearThumbnail];
        }
    }
    
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_BACKGROUNDED_APPLICATION withProperties:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[[CCCoreManager sharedInstance] locationManager] startStandardUpdates];
    
    if ([[[CCCoreManager sharedInstance] server] currentUser] != nil)
    {
        [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewsInBackgroundWithBlockOrNil:nil];
        
        [[[[CCCoreManager sharedInstance] server] currentUser] loadInvitesInBackgroundWithBlockOrNil:nil];

        [[[[CCCoreManager sharedInstance] server] currentUser] loadNotificationsInBackgroundWithBlockOrNil:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;

    NSDictionary *openedApplicationProperties = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], CC_CREWCAM_VERSION_KEY,
                                                 nil];
    
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_OPEN_APPLICATION withProperties:openedApplicationProperties];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
