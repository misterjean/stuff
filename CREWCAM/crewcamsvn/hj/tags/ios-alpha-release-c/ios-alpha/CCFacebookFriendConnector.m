//
//  CCFacebookFriendConnector.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCFacebookFriendConnector.h"

@implementation CCFacebookFriendConnector

- (NSArray *) loadFriends
{
    if(![[PFFacebookUtils facebook] isSessionValid])
        return nil;
    
    facebookLoadingCondition = [[NSCondition alloc] init];

    dispatch_async( dispatch_get_main_queue(), ^
    {
        // We have to make the request on the main thread
        [[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends" andDelegate:self];          
    });
        
    // Lock up this thread until Facebook gets back to us.  This function shouldn't be called on the main thread
    [facebookLoadingCondition lock];
    
    [facebookLoadingCondition wait];
    
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
    
    loadedFriendsInformation = nil;
    
    [facebookLoadingCondition unlock];
    return facebookIds;
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load friends from Facebook: %@", [error localizedDescription]];
    
    [facebookLoadingCondition signal];
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result 
{
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    
    if ([requestType isEqualToString:@"me/friends"]) 
    {
        loadedFriendsInformation = result;
        
        [facebookLoadingCondition signal];
    }
};


@end
