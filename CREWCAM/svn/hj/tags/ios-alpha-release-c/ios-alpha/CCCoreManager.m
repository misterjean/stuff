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
        logger = [[CCLogger alloc] init];
        locationManager = [[CCLocationManager alloc] init];
        [locationManager startStandardUpdates];
        friendManager = [[CCParseFriendManager alloc] init];
        notificationDelegates = [[NSMutableArray alloc] init];
        isIgnoringNotifications = NO;
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
    if ([userInfo objectForKey:@"src_User"] != nil)
    {
        if (![[[server currentUser] getObjectID] isEqualToString:[userInfo objectForKey:@"src_User"]])
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
    
    UIAlertView *alert; 
    
    if ([userInfo objectForKey:@"type"])
    {
        switch ([[userInfo objectForKey:@"type"] intValue])
        {
            case CCVideoPush:
                alert = [[UIAlertView alloc] initWithTitle:nil message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] 
                                                  delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View Video",nil];
                [alert setTag:CCVideoPush];
                
                [self setVideoPushInfo:userInfo];
                break;
                
            case CCInvitePush:
                // Start reloading invites
                [[[self server] currentUser] loadInvitesInBackgroundWithBlockOrNil:nil];
                
                alert = [[UIAlertView alloc] initWithTitle:nil message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] 
                                                  delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View Invite",nil];
                [alert setTag:CCInvitePush];
                break;
                
                
            case CCCommentPushAlert:
                /* NOTE: This alert view is no longer shown due to the architecture currently not supporting the desired effetcs.
                 Instead we call the gui directly and have it take care of the alert logic
                alert = [[UIAlertView alloc] initWithTitle:nil message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] 
                                                  delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View Comment",nil];
                [alert setTag:CCCommentPushAlert];
                
                [self setVideoPushInfo:userInfo];
                 */
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CCCommentPushNotification" object:nil userInfo:userInfo];
                break;
             
                
            default:
                alert = [[UIAlertView alloc] initWithTitle:nil message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] 
                                                  delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                break;
        } 
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:nil message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] 
                                          delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    }
    
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{     
    if (buttonIndex == 1)
    {
        switch ([alertView tag]) {
            case CCVideoPush:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CCVideoPushNotification" object:nil userInfo:videoPushInfo];
                break;
            case CCInvitePush:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CCInvitePushNotification" object:nil userInfo:nil];
                break;
            case CCCommentPushAlert:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CCCommentPushNotification" object:nil userInfo:videoPushInfo];
                break;
                
            default:
                break;
        }
    }
    
}

-(void) checkNetowrkConnectivity:(CCBooleanResultBlock)block
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
