//
//  CCLogger.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLogger.h"

@implementation CCLogger

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        logLevel = ccLogLevelAlways;
    }
    
    return self;
}

- (void)logAtLogLevel:(CCLogLevel)logAtLevel message:(NSString *)message, ...
{
    va_list argList;
    va_start(argList, message);    
    NSString *formattedMessage = [[NSString alloc] initWithFormat: message arguments: argList];    
    va_end(argList);
    
    if (logAtLevel >= logLevel)
    {
        NSString *messageToLog = [NSString alloc];
        switch (logAtLevel) {
            case ccLogLevelAlways:
                messageToLog = [messageToLog initWithFormat:@"Logging \"Always\" message: %@", formattedMessage];
                break;
            case ccLogLevelDebug:
                messageToLog = [messageToLog initWithFormat:@"Logging \"Debug\" message: %@", formattedMessage];
                break;
            case ccLogLevelError:
                messageToLog = [messageToLog initWithFormat:@"Logging \"Error\" message: %@", formattedMessage];
                break;
            case ccLogLevelWarning:
                messageToLog = [messageToLog initWithFormat:@"Logging \"Warning\" message: %@", formattedMessage];
                break;                
            default:
                break;
        }
        NSLog(@"%@", messageToLog);      
    }
    
}

@end
