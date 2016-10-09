//
//  CCCoreManager.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCoreManager.h"

@implementation CCCoreManager

@synthesize currentUser;
@synthesize server;
@synthesize logger;
@synthesize locationManager;

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

@end
