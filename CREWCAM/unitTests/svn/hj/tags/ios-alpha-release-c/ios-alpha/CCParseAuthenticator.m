//
//  CCParseAuthenticator.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseAuthenticator.h"

@implementation CCParseAuthenticator

- (id) initWithUsername:(NSString *) loginUsername andPassword:(NSString *) loginPassword
{
    self = [super init];
    
    if (self != nil)
    {
        username = loginUsername;
        password = loginPassword;
        [self setupLocalVariables];
    }
    
    return self;
}

-(id)init
{
    self = [super init];
    
    if (self != nil)
    {
        [PFFacebookUtils initializeWithApplicationId:CREWCAM_FACEBOOK_ID_STRING];
        [PFFacebookUtils facebookWithDelegate:self];
        [self setupLocalVariables];
    }
    
    return self;
}

- (void) setupLocalVariables
{
    isTryingToAuthenticateWithUsernameAndPassword = NO;
    isTryingToAuthenticateWithFacebook = NO;    
    facebookLoadingDataCondition = [[NSCondition alloc] init];
}

- (void) authenticateInBackgroundWithBlock:(CCUserResultBlock) block forceFacebookAuthentication:(BOOL) forceFacebook
{
     [self startAuthenticateAndForceFacebook:forceFacebook andBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) 
    {
        [self handleNewUser:user success:succeeded andError:error andBlock:block];
    }];
}

- (void) handleNewUser:(id<CCUser>) user success:(BOOL)succeeded andError:(NSError *) error andBlock:(CCUserResultBlock) block
{
    if (!succeeded)
    {
        block(nil, NO, error);
        return;
    }
    
    if ([user getHasUserLoggedIn])
    {
        [user subscribeToUserAndGlobalChannelInBackground];
        block(user, succeeded, error);
        return;
    }
    else 
    {
        // This user may have been invited by somebody
        // Now the user has logged in once, save it
        [user setHasUserLoggedIn:YES];
        [user pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
         {
             [user subscribeToUserAndGlobalChannelInBackground];
         }];
        
        // Check to see if this user was "invited" via Facebook or phone number
        NSArray *facebookID = [[NSArray alloc] initWithObjects:[user getFacebookID], nil];
        NSArray *phoneNumber = [[NSArray alloc] initWithObjects:[user getPhoneNumber], nil];
        
        PFQuery *facebookIDQuery = [PFQuery queryWithClassName:@"InvitedPerson"];                
        [facebookIDQuery whereKey:@"facebookId" containedIn:facebookID];
        
        // Find all the users that are in my contacts
        PFQuery *phoneNumberQuery = [PFQuery queryWithClassName:@"InvitedPerson"];                
        [phoneNumberQuery whereKey:@"phoneNumber" containedIn:phoneNumber];
        
        PFQuery *invitedPersonQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:facebookIDQuery, phoneNumberQuery, nil]];
        
        [invitedPersonQuery findObjectsInBackgroundWithBlock:^(NSArray *invitedPeople, NSError *error){
             if (error)
             {
                 // Just return the user we got after logging:
                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:@"Error querying for \"InvitedPerson\": %@", [error localizedDescription]];
                 block(user, YES, nil);
                 return;
             }
             
             if ([invitedPeople count] < 1)
             {
                 block(user, YES, nil);
                 return;
             }
             
             
             // Join any crews they were invited to, and purge old data
              PFObject *invitedPerson = [invitedPeople objectAtIndex:0];  // In theory, there could be more than one matching "InvitedPerson", we'll assume for now they are the same person 
             // invited via multiple methods
              
             // Set the name stuff
             [user setFirstName:[invitedPerson objectForKey:@"firstName"]];
             [user setLastName:[invitedPerson objectForKey:@"lastName"]];
             
             PFRelation *relatedCrews = [invitedPerson relationforKey:@"crewsInvitedTo"];                  
             
             [[relatedCrews query] findObjectsInBackgroundWithBlock:^(NSArray *crewsInvitedTo, NSError *error) {
                  if (!error)
                  {
                      // Add the user to any crews he should be in
                      for (PFObject *crew in crewsInvitedTo)
                      {
                          CCParseCrew *ccCrew = [[CCParseCrew alloc] initWithServerData:crew];
                          
                          [ccCrew addMemberInBackground:user withBlockOrNil:nil];
                      }
                  }                      
                  
                  for(PFObject *person in invitedPeople)
                  {
                      // It's possible that this person was invited via multiple methods, handle that here
                      
                      // Delete the temporary "invited" person
                      [person deleteInBackground];
                  }    
                  
                  block(user, !error, error);                       
              }];                
         }];
    }   
}

- (void) startAuthenticateAndForceFacebook:(BOOL) forceFacebook andBlock:(CCUserResultBlock) block
{
     if ([PFUser currentUser])
     {
          CCParseUser *ccUser = [[CCParseUser alloc] initWithServerData:[PFUser currentUser]];
          [ccUser pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
               block(ccUser, YES, nil);  
          }];
          
          return;
     }
    if (username != nil && password != nil)
    {
        [self tryToLoginWithUsernameAndPasswordWithBlock:block];
    }
    else 
    {
         [self tryToLoginWithFacebookWithForce:forceFacebook andBlock:block];
    }
}

- (void) signUpNewUserInBackgroundWithBlock:(CCUserResultBlock) block
{
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;   
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
    {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to sign up new user: %@", [error localizedDescription]];
            block(nil, NO, error);
        }
        else 
        {
            CCParseUser *ccUser = [[CCParseUser alloc] initWithServerData:user];       
            [self handleNewUser:ccUser success:succeeded andError:error andBlock:block];
        }
    }];
}

- (void) tryToLoginWithUsernameAndPasswordWithBlock:(CCUserResultBlock) block
{
    if (OSAtomicTestAndSet(YES, &isTryingToAuthenticateWithUsernameAndPassword))
        return;
            
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) 
     {
         CCParseUser *parseUser;
         
         if (error)
         {
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error authenticating with Parse: %@", [error localizedDescription]];
         }
         
         if (user)
         {
             parseUser = [[CCParseUser alloc] initWithServerData:user];             
         }
         
         OSAtomicTestAndClear(YES, &isTryingToAuthenticateWithUsernameAndPassword);         
         block(parseUser, !error, error);
     }];  
}

- (void) tryToLoginWithFacebookWithForce:(BOOL) forceFacebook andBlock:(CCUserResultBlock) block
{
    if (OSAtomicTestAndSet(YES, &isTryingToAuthenticateWithFacebook))
        return;
    
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"user_about_me",
                            @"user_likes", 
                            @"read_stream",
                            @"publish_stream",
                            @"email",
                            nil];
    
     if (![[PFFacebookUtils facebook] isSessionValid] && !forceFacebook)
     {
          OSAtomicTestAndClear(YES, &isTryingToAuthenticateWithFacebook);
          block(nil, NO, nil);
          return;
     }
     
    if (![[PFFacebookUtils facebook] isSessionValid]) 
    {
        [[PFFacebookUtils facebook] authorize:permissions];

        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {    
            [facebookLoadingDataCondition lock];             
            [facebookLoadingDataCondition wait]; 
            [facebookLoadingDataCondition unlock]; 
            
            if (![[PFFacebookUtils facebook] isSessionValid])
            {
                OSAtomicTestAndClear(YES, &isTryingToAuthenticateWithFacebook);
                dispatch_async( dispatch_get_main_queue(), ^
                {
                     NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"User canceled"];
                     NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedDescriptionKey,  descriptiveErrorString, nil];
                     NSError *error = [[NSError alloc] initWithDomain:NSUnderlyingErrorKey code:0 userInfo:errorDictionary];
                     
                     OSAtomicTestAndClear(YES, &isTryingToAuthenticateWithFacebook);
                     block(nil, NO, error);
                });
            }
            else 
            {
                [self loginWithExistingFacebookSessionInBackgroundWithBlock:block];
            }
        });       
    }   
    else
    {        
        [self loginWithExistingFacebookSessionInBackgroundWithBlock:block];
    }        
}

- (void) loginWithExistingFacebookSessionInBackgroundWithBlock:(CCUserResultBlock) block
{   
    // Make sure the request is done on the main queue
    dispatch_async( dispatch_get_main_queue(), ^
    {
        [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];
    });        
    
    // Wait on a new thread for the response 
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {  
        [facebookLoadingDataCondition lock];
        [facebookLoadingDataCondition wait];
        [facebookLoadingDataCondition unlock];  
        
        // Get back to the main thread
        dispatch_async( dispatch_get_main_queue(), ^
        {
            if (facebookUserData == nil)
            {
                 NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"Unable to load Facebook data"];
                 NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedDescriptionKey,  descriptiveErrorString, nil];
                 NSError *error = [[NSError alloc] initWithDomain:NSUnderlyingErrorKey code:0 userInfo:errorDictionary];
                 
                OSAtomicTestAndClear(YES, &isTryingToAuthenticateWithFacebook);
                block(nil, NO, error);
                return;
            }
            
            [PFFacebookUtils logInWithFacebookId:[facebookUserData objectForKey:@"id"] accessToken:[[PFFacebookUtils facebook] accessToken]  expirationDate:[[PFFacebookUtils facebook] expirationDate] block:^(PFUser *user, NSError *error) 
             {
                
                 CCParseUser *ccUser;
                 
                 if (!error)                     
                 {                      
                      ccUser = [[CCParseUser alloc] initWithServerData:[PFUser currentUser]];
                      
                      if ([ccUser getIsUserNew])
                      {
                           [self setUserWithFacebookData:facebookUserData forUser:ccUser];                       
                      }

                 }

                 OSAtomicTestAndClear(YES, &isTryingToAuthenticateWithFacebook);
                 block(ccUser, !error, error);    
            }];
        });  
    });
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result 
{
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    
    if ([requestType isEqualToString:@"me"])
    {
        // Save the result
        facebookUserData = result;
        
        // Signal waiting threads
        [facebookLoadingDataCondition signal];
    }
};

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load from Facebook: %@", [error localizedDescription]];
    
    [facebookLoadingDataCondition signal];
}


- (void)fbDidLogin
{
    [facebookLoadingDataCondition signal];
}
     
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    
}

- (void)setUserWithFacebookData:(NSDictionary *) data forUser:(id<CCUser>) user
{
    [user setEmailAddress:[data valueForKey:@"email"]];
    [user setGender:[data valueForKey:@"gender"]];
    [user setFirstName:[data valueForKey:@"first_name"]];
    [user setLastName:[data valueForKey:@"last_name"]];
    [user setFacebookID:[data valueForKey:@"id"]];     
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    [facebookLoadingDataCondition signal];    
}

- (void)fbDidLogout
{
    
}

- (void)fbSessionInvalidated
{
    
}

@end
