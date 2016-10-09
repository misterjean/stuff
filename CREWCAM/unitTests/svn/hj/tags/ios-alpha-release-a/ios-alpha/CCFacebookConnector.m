//
//  CCFacebookConnector.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCFacebookConnector.h"

@implementation CCFacebookConnector

-(id)init
{
    self = [super init];
    
    if (self != nil)
    {
        [PFFacebookUtils initializeWithApplicationId:@"410003242359572"];
        [PFFacebookUtils facebookWithDelegate:self];
    }
    
    return self;
}

- (void)startAuthenticatingWithDelegate:(id<CCConnectorAuthenticationCompleteDelegate>) delegate
{
    authenticationCompleteDelegate = delegate;

    if (![[PFFacebookUtils facebook] isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_about_me",
                                @"user_likes", 
                                @"read_stream",
                                @"email",
                                nil];
        
        [[PFFacebookUtils facebook] authorize:permissions];
    }        
    else 
    {
        // We're already logged in.  Simply request the user's information
        [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];  
    }
}

- (void)startAuthenticatingWithDelegate:(id<CCConnectorAuthenticationCompleteDelegate>)delegate email:(NSString *)username password:(NSString *)password
{
    [delegate authenticationFailedWithReason:@"E-mail based authentication unsupported for Facebook"];
}

- (void)tryToSilentlyAuthenticateWithDelegate:(id<CCConnectorAuthenticationCompleteDelegate>) delegate
{
    authenticationCompleteDelegate = delegate;
    
    if (![[PFFacebookUtils facebook] isSessionValid]) 
    {
        [authenticationCompleteDelegate silentAuthenticationFailedWithReason:@"Facebook session not vaild."];
    }      
    else 
    {    
        isSilentAttempt = YES;
        [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];
    }
}

- (void)setWithFacebookDataUser:(id<CCUser>) user
{
    [user setEmailAddress:[currentUserData valueForKey:@"email"]];
    [user setGender:[currentUserData valueForKey:@"gender"]];
    [user setFirstName:[currentUserData valueForKey:@"first_name"]];
    [user setLastName:[currentUserData valueForKey:@"last_name"]];
    [user setFacebookId:[currentUserData valueForKey:@"id"]];
    [user pushObjectWithNewThread:NO delegateOrNil:nil];
}

// Optional PF_FBRequestDelegate methods
- (void)request:(PF_FBRequest *)request didLoad:(id)result 
{
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    
    if ([requestType isEqualToString:@"me"])
    {
        currentUserData = result;
        
        if (isSilentAttempt)
        {
            [authenticationCompleteDelegate silentAuthenticationCompleteWithId:(NSString *)[currentUserData valueForKey:@"id"] isNewUser:NO connectorType:ccFacebookConnector];
        }
        else 
        {
            [authenticationCompleteDelegate authenticationCompleteWithId:(NSString *)[currentUserData valueForKey:@"id"] isNewUser:NO connectorType:ccFacebookConnector];        
        }
    }
    else if ([requestType isEqualToString:@"me/friends"]) 
    {        
        [friendsLoadCompleteDelegate successfullyLoadedFriends:[(NSDictionary *)result objectForKey:@"data"] connectorType:ccFacebookConnector];
    }
};

// Required PF_FBSessionDelegate methods
- (void)fbDidLogin
{
    // Use the Graph API to get the user's ID, and then authenticate with Parse's backend.  This will eventually call "didLoad"
    [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];  
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    
}


- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    
}

- (void)fbDidLogout
{
    
}

- (void)fbSessionInvalidated
{
    
}

// Required CCFriendConnector methods
- (void)startLoadingFriendsWithDelegate:(id<CCConnectorFriendsLoadCompleteDelegate>)delegate
{
    friendsLoadCompleteDelegate = delegate;
    
    [[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends" andDelegate:self];  
}

@end
