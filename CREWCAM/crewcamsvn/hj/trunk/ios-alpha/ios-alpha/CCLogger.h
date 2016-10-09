//
//  CCLogger.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CCLogLevel {
    ccLogLevelAlways = 0,
    ccLogLevelDebug,
    ccLogLevelWarning,
    ccLogLevelError,
} CCLogLevel;

@interface CCLogger : NSObject
{
    CCLogLevel      logLevel;
}

- (void)logAtLogLevel:(CCLogLevel)logAtLevel message:(NSString *)message, ...;

@end
