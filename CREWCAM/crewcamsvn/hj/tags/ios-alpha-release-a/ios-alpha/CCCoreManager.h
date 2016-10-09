//
//  CCCoreManager.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCServer.h"
#import "CCParseServer.h"
#import "CCLogger.h"
#import "CCUser.h"
#import "CCLocationManager.h"


@interface CCCoreManager : NSObject
{
    
}

@property (strong, nonatomic)   id<CCUser>          currentUser;
@property (strong, nonatomic)   id<CCServer>        server;
@property (strong, nonatomic)   CCLogger            *logger;
@property (strong, nonatomic)   CCLocationManager   *locationManager;

+(CCCoreManager *)sharedInstance;
-(void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken;

@end
