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
    
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];

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
    // Clear any existing crews
    for (id<CCCrew> crew in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews])
    {
        for (id<CCVideo> video in [crew ccVideos])
        {
            [video clearThumbnail];
        }
    }
    
    if ([[[CCCoreManager sharedInstance]server]currentUser])
    {
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_BACKGROUNDED_APPLICATION withProperties:nil];
    }
    
    // Are we in the middle of uploading?
    if (![[[CCCoreManager sharedInstance] server] isUploading])
        return;
    
    // Run in the background
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Completing upload in background..."];
    
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{

        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Background time expired.  Killing threads!"];
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Wait until the upload is finished, then clean up
        while([[[CCCoreManager sharedInstance] server] isUploading])
        {
            sleep(5);
        }
        
        // Give everybody a few seconds to save any last-minute stuff post-upload
        sleep(10);
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];

        // Schedule a local notification for now + 5 seconds
        localNotif.fireDate = [[NSDate dateWithTimeIntervalSinceNow:0] addTimeInterval:5];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];        
        
        if ([[[CCCoreManager sharedInstance] server] lastVideoUploadFailed])
        {
            localNotif.alertBody = @"Oops, there was an error uploading your video!"; 
        }
        else
        {
            localNotif.alertBody = @"Your video was successfully uploaded!"; 
        }
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Completed background upload.  Cleaning up."];
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[[CCCoreManager sharedInstance] locationManager] startStandardUpdates];
    
    if ([[[CCCoreManager sharedInstance] server] currentUser] != nil)
    {
        id<CCUser> currentUser = [[[CCCoreManager sharedInstance] server] currentUser];
        
        [currentUser loadNotificationsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            [currentUser loadCrewsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                [currentUser loadInvitesInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                    [[[CCCoreManager sharedInstance] friendManager] addFacebookFriendsAndContactsWhoAreUsingCrewcamWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                         [currentUser loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                             [currentUser loadFriendRequestsInBackgroundWithBlockOrNil:nil];
                         }];
                     }];                    
                }];
            }];
        }];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    if ([[[CCCoreManager sharedInstance] server] currentUser])
    {
        NSDictionary *openedApplicationProperties = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], CC_CREWCAM_VERSION_KEY,
                                                     nil];
        
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_OPEN_APPLICATION withProperties:openedApplicationProperties];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
