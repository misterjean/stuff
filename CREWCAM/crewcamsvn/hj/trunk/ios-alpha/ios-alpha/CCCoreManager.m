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
@synthesize stringManager;
@synthesize logger;
@synthesize locationManager;
@synthesize friendManager;
@synthesize notificationDelegates;
@synthesize videoPushInfo;

- (id) init
{    
    self = [super init];
    
    if (self != nil)
    {
        // For now, the only server we know about is a Parse server.  In the future we could use different servers
        server = [[CCParseServer alloc] init];

        stringManager = [[CCParseStringManager alloc] init];
        [stringManager loadStringsInBackgroundWithBlock:nil];
        
        logger = [[CCLogger alloc] init];
        
        locationManager = [[CCLocationManager alloc] init];
        [locationManager startStandardUpdates];
        
        friendManager = [[CCParseFriendManager alloc] init];
        
        notificationDelegates = [[NSMutableArray alloc] init];
        isIgnoringNotifications = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didReceiveMemoryWarningHandler)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification  
                                                   object:nil];
 
        

#if LOG_KISSMETRICS
        [KISSMetricsAPI sharedAPIWithKey:CC_KISSMETRICS_KEY];
#endif
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReturnFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

-  (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (CCCoreManager *)sharedInstance
{
    static dispatch_once_t pred;
    static CCCoreManager *sharedInstance = nil;    
    dispatch_once(&pred, ^
    {
        sharedInstance = [[CCCoreManager alloc] init];
    });
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void) didReceiveMemoryWarningHandler
{
}

- (void) handleReturnFromBackground
{
    [stringManager loadStringsInBackgroundWithBlock:nil];
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
    // Check if this is a notification from "myself"
    if ([userInfo objectForKey:@"src_User"] != nil)
    {
        if (![[[server currentUser] getObjectID] isEqualToString:[userInfo objectForKey:@"src_User"]])
        {
            [self interpretNotificationWithApplication:application userInfo:userInfo];
        }
    }
    else 
    {
        [self interpretNotificationWithApplication:application userInfo:userInfo];
    }
}

- (void) interpretNotificationWithApplication:(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"badge"] != nil)
    {
        application.applicationIconBadgeNumber += [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
    }
    
    [[[self server] currentUser] notificationReceivedWithData:userInfo];
    
    for(id<CCNotificationDelegate> delegate in [self notificationDelegates])
    {
        [delegate notificationReceivedWithData:userInfo];
    }
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"] != nil)
        [self handlePush:userInfo];
}

- (void) clearTimerAndNotificationIgnoreFlag
{
    OSAtomicTestAndClear(YES, &isIgnoringNotifications);
}

- (void) handlePush:(NSDictionary *)userInfo
{
    // Check if we've recently received a notification
    if (OSAtomicTestAndSet(YES, &isIgnoringNotifications))
        return; 
    
    // Ignore notifications for 5 seconds
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(clearTimerAndNotificationIgnoreFlag)
                                   userInfo:nil
                                    repeats:NO];
    
    // Show a message with the alert, and the "view" button if needed:
    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Notification" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] withTextField:NO
                              delegate:self cancelButtonTitle:nil otherButtonTitles:@"View",nil];
    
    if ([[userInfo objectForKey:@"type"] intValue] == ccInvitePushNotification)
    {
        [alert setTag:ccInvitePushNotification];
    }

    [alert show];
}


- (void) alertView:(CCCrewcamAlertView *) alertView clickedButtonAtIndex:(NSInteger) buttonIndex
{     
    if (buttonIndex == 1)
    {
        // The user wants to view their notification(s)
        if ([alertView tag] != ccInvitePushNotification)    
            [[NSNotificationCenter defaultCenter] postNotificationName:CC_SHOW_NOTIFICATIONS_TAB object:nil userInfo:nil];
        else 
            [[NSNotificationCenter defaultCenter] postNotificationName:CC_SHOW_CREW_INVITES object:nil userInfo:nil];
    }
    
}

-(void) checkNetworkConnectivity:(CCBooleanResultBlock)block
{    
    @synchronized(self)
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {         
            BOOL nflag = NO;
            Reachability *r = [Reachability reachabilityWithHostName:@"google.com"];
            NetworkStatus internetStatus = [r currentReachabilityStatus];
            if(internetStatus == NotReachable) 
            {
                nflag = NO;
            }
            else
            {
                nflag = YES;
            }
                
            dispatch_async( dispatch_get_main_queue(), ^
            {
                [connectivityTimer invalidate];
                connectivityTimer = nil;
                if (!nflag) 
                {
                    block(NO,nil);
                }
                else 
                {
                    block(YES,nil);
                }
           });
        });        
    }
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
    [[KISSMetricsAPI sharedAPI] identify:[[NSString alloc] initWithFormat:@"%@ (%@)", [user getName], [user getObjectID]]];
#endif
}

@end
