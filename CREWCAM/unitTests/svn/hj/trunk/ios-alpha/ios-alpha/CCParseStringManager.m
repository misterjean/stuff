//
//  CCParseStringManager.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-25.
//
//

#import "CCParseStringManager.h"
#import "Parse/Parse.h"

@implementation CCParseStringManager

- (id) init
{
    self = [super init];
    
    if (self)
    {
        serverStringsDictionary = [[NSMutableDictionary alloc] init];
        isLoadingStrings = NO;
    }
    
    return self;
}

- (void) loadStringsInBackgroundWithBlock:(CCBooleanResultBlock) block
{
    if (OSAtomicTestAndSet(YES, &isLoadingStrings))
        return;
    
    NSMutableDictionary *newStringsDictionary = [[NSMutableDictionary alloc] init];
    
    PFQuery *serverStringsQuery = [PFQuery queryWithClassName:@"String"];
    
    [serverStringsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load server strings: %@", [error localizedDescription]];
        }
        
        for(PFObject *serverString in objects)
        {
            [newStringsDictionary setObject:[serverString objectForKey:@"string"] forKey:[serverString objectForKey:@"key"]];
        }
        
        serverStringsDictionary = newStringsDictionary;
        
        OSAtomicTestAndClear(YES, &isLoadingStrings);
        
        if (block)
            block(!error, error);
    }];
}

-(NSString *)getStringForKey:(NSString *)key withDefault:(NSString *) defaultString
{
    NSString *serverString = [serverStringsDictionary objectForKey:key];
    
    if (serverString && !(key == nil))
    {
        return serverString;
    }
    
    return defaultString;
}

@end
