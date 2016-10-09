//
//  CCFacebookFriendConnector.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCFacebookFriendConnector.h"

@implementation CCFacebookFriendConnector

- (id) init
{
    self = [super init];
    
    if (self)
    {
        facebookLoadingCondition = [[NSCondition alloc] init];
    }
    
    return self;
}

static u_int16_t hasMadeRequest = NO;

- (NSArray *) loadFriends
{
    if(![[PFFacebookUtils facebook] isSessionValid])
        return nil;

    if (!OSAtomicTestAndSet(YES, &hasMadeRequest))
    {
        dispatch_async( dispatch_get_main_queue(), ^{
            // We have to make the request on the main thread
            [[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends" andDelegate:self];          
        });
     
    }  
    
    loadedFriendsInformation = nil;
    [facebookLoadingCondition lock];
    [facebookLoadingCondition wait];        
    [facebookLoadingCondition unlock];
    
    if (loadedFriendsInformation == nil)
    {
        return nil;
    }
    
    NSMutableArray *facebookIds = [[NSMutableArray alloc] init];    

    for (NSDictionary *friendNameAndId in [loadedFriendsInformation objectForKey:@"data"])
    {
        NSArray *namesArray = [[friendNameAndId objectForKey:@"name"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];    
                
        CCFacebookPerson *facebookPerson = [[CCFacebookPerson alloc] initWithFirstName:[namesArray objectAtIndex:0] andLastName:[namesArray objectAtIndex:([namesArray count] - 1)] andUniqueID:[friendNameAndId objectForKey:@"id"]];
        
        [facebookIds addObject:facebookPerson];
    }
    
    return facebookIds;
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load friends from Facebook: %@", [error localizedDescription]];
    
    [facebookLoadingCondition broadcast];
    
    OSAtomicTestAndClear(YES, &hasMadeRequest);
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result 
{
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    
    if ([requestType isEqualToString:@"me/friends"]) 
    {
        loadedFriendsInformation = result;
        
        [facebookLoadingCondition broadcast];
    }
    
    OSAtomicTestAndClear(YES, &hasMadeRequest);
};


@end
