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
           if (!succeeded)
           {
                block(nil, NO, error);
                return;
           }
           
           if (facebookUserPermissions)
           {
                [user setFacebookUserWallPostPermission:[[facebookUserPermissions objectForKey:@"publish_stream"] boolValue]]; 
           }
           
           [user subscribeToUserAndGlobalChannelInBackground];
           [[CCCoreManager sharedInstance] registerUserForMetrics:user];
           block(user, succeeded, error);         
      }];
}

- (void)sendNotificationsToFriendsOfUser:(id<CCUser>)user
{
    [[[CCCoreManager sharedInstance] friendManager] loadCrewcamFriendsInBackgroundWithBlock:^(NSArray *ccFriends, NSError *error) {
        if (!error)
        {
            NSString *message = [[NSString alloc] initWithFormat:@"Your friend \"%@\" has joined Crewcam",[user getName]]; 
            
            for (CCBasePerson *friend in ccFriends)
            {
                [CCParseNotification createNewNotificationInBackgroundWithType:ccFriendJoinedNotification andTargetUser:[friend ccUser] andSourceUser:user andTargetObject:nil andTargetCrewOrNil:nil andMessage:message];
                
                [[friend ccUser] sendNotificationWithMessage:message]; 
            }
        }
    }];
}

- (void) tryToActivateNewUser:(id<CCUser>) user withBlock:(CCBooleanResultBlock) block
{
     // This user may have been invited by somebody
     // Now the user has logged in once, save it
     [user setHasUserLoggedIn:YES];
     [user pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
          if (!succeeded)
          {
               [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:@"Error pushing user before activation: %@", [error localizedDescription]];

               [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ACTIVATING_NEW_USER withProperties:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                                               @"Error pushing user object", CC_REASON_FOR_ACTIVATION_FAILURE,
                                                                                                               nil]];
               block(NO, error);
               return;
          }
          
          NSMutableArray *queriesToMatch = [[NSMutableArray alloc] init];
          [user subscribeToUserAndGlobalChannelInBackground];
          [[CCCoreManager sharedInstance] registerUserForMetrics:user];
         
          if ([user getFacebookID])
          {
               PFQuery *facebookIDQuery = [PFQuery queryWithClassName:@"InvitedPerson"];
               [facebookIDQuery whereKey:@"facebookId" matchesRegex:[user getFacebookID]];
               [queriesToMatch addObject:facebookIDQuery];
          }
         
         // Find all the users that are in my contacts
          if ([user getPhoneNumber])
          {
               PFQuery *phoneNumberQuery = [PFQuery queryWithClassName:@"InvitedPerson"];
               [phoneNumberQuery whereKey:@"phoneNumber" hasSuffix:[user getPhoneNumber]];
               [queriesToMatch addObject:phoneNumberQuery];
          }
         
          if ([user getEmailAddress])
          {
               PFQuery *emailAddressQuery = [PFQuery queryWithClassName:@"InvitedPerson"];
               [emailAddressQuery whereKey:@"emailAddress" matchesRegex:[user getEmailAddress]];
               [queriesToMatch addObject:emailAddressQuery];
          }
         
         PFQuery *invitedPersonQuery = [PFQuery orQueryWithSubqueries:queriesToMatch];
          [invitedPersonQuery includeKey:@"invitedBy"];
         
         [invitedPersonQuery findObjectsInBackgroundWithBlock:^(NSArray *invitedPeople, NSError *error){
              if (error)
              {
                   // Just return the user we got after logging:
                   [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:@"Error querying for \"InvitedPerson\": %@", [error localizedDescription]];
                   
                   [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ACTIVATING_NEW_USER withProperties:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                                                   @"Error querying for invites", CC_REASON_FOR_ACTIVATION_FAILURE,
                                                                                                                   nil]];
                   block(NO, error);
                   return;
              }
              
              if ([invitedPeople count] < 1)
              {
                   if ([[[CCCoreManager sharedInstance] server] globalSettings].isOpenAccess)
                   {
                        // Activate the user anyway
                        [user setUserActive:YES];
                        
                        // Notify friends
                        [self sendNotificationsToFriendsOfUser:user];
                        
                        [[CCCoreManager sharedInstance] recordMetricEvent:CC_SUCCESSFULLY_ACTIVATED_NEW_USER withProperties:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                                                        @"Application is globally open", CC_REASON_FOR_ACTIVATION_SUCCESS,
                                                                                                                        nil]];
                        block(YES, nil);
                   }
                   else
                   {
                        // Make sure we remember that this user isn't activated!
                        [user setUserActive:NO];
                        [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ACTIVATING_NEW_USER withProperties:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                                                        @"No invites for the user", CC_REASON_FOR_ACTIVATION_FAILURE,
                                                                                                                        nil]];
                        block(NO, nil);
                   }
                   
                   return;
              }                                  
                   
              PFObject *invitedPerson = [invitedPeople objectAtIndex:0];  // In theory, there could be more than one matching "InvitedPerson", we'll assume for now they are the same person 
              // invited via multiple methods
              
              // Set the name stuff
              [user setFirstName:[invitedPerson objectForKey:@"firstName"]];
              [user setLastName:[invitedPerson objectForKey:@"lastName"]];
              
              // Fetch the person that invited us
              id<CCUser> userThatInvited = [[CCParseUser alloc] initWithServerData:[invitedPerson objectForKey:@"invitedBy"]];              
              if ([userThatInvited isUserDeveloper])
                   [user setNumberOfInvites:[NSNumber numberWithInt:CC_NEW_USER_INVITE_LIMIT]];
              
              // Set the user active, and push before doing anything else
              [user setUserActive:YES];
                            
              [self sendNotificationsToFriendsOfUser:user];
                            
              [user pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                   
                   if (!succeeded)
                   {
                        [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ACTIVATING_NEW_USER withProperties:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                                                        @"Error pushing user object after activation", CC_REASON_FOR_ACTIVATION_FAILURE,
                                                                                                                        nil]];
                        block(NO, error);
                        return;
                   }
                   
                   [[CCCoreManager sharedInstance] recordMetricEvent:CC_SUCCESSFULLY_ACTIVATED_NEW_USER withProperties:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                                                        @"Invite found for user", CC_REASON_FOR_ACTIVATION_SUCCESS,
                                                                                                                        nil]];
                   
                   PFRelation *relatedCrews = [invitedPerson relationforKey:@"crewsInvitedTo"];
                   [[relatedCrews query] findObjectsInBackgroundWithBlock:^(NSArray *crewsInvitedTo, NSError *error) {                             
                        if (!error)
                        {
                             // Invite the user to any crews he should be in
                             for (PFObject *crew in crewsInvitedTo)
                             {
                                  CCParseCrew *ccCrew = [[CCParseCrew alloc] initWithServerData:crew];
                                  [CCParseInvite createNewInviteToCrewInBackground:ccCrew forUser:user fromUser:userThatInvited withNotification:NO];                     
                             }                                                          
                             
                             for(PFObject *person in invitedPeople)
                             {                                  
                                  // Delete the temporary "invited" person
                                  [person deleteInBackground];
                             }    
                         }
                        
                        block(!error, error);
                   }];
              }];               
         }]; 
    }];     
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
        if (!succeeded)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to sign up new user: %@", [error localizedDescription]];
            block(nil, NO, error);
        }
        else 
        {             
             CCParseUser *ccUser = [[CCParseUser alloc] initWithServerData:user];                    
             [ccUser subscribeToUserAndGlobalChannelInBackground];
             [[CCCoreManager sharedInstance] registerUserForMetrics:ccUser];
             block(ccUser, succeeded, error);     
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
                      
                      if ([ccUser getIsUserNew] || ![ccUser isUserActive])
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

//This function can be possibly used to reauthorize the facebook user's account, curretnly it is not called as there are some potential issues in the current setup
#if 0
- (void) reauthorizeWithFacebookWithBlock:(CCBooleanResultBlock)block
{
     NSArray *permissions = [[NSArray alloc] initWithObjects:
                             @"user_about_me",
                             @"user_likes", 
                             @"read_stream",
                             @"publish_stream",
                             @"email",
                             nil];
     
     [[PFFacebookUtils facebook] authorize:permissions];
     dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
     {
          [facebookLoadingDataCondition lock];
          [facebookLoadingDataCondition wait];
          [facebookLoadingDataCondition unlock];
          dispatch_async( dispatch_get_main_queue(), ^
          {
               [self getUserPermissions];   
          });
          [facebookLoadingDataCondition lock];
          [facebookLoadingDataCondition wait];
          [facebookLoadingDataCondition unlock];
          [[[[CCCoreManager sharedInstance] server] currentUser] setFacebookUserWallPostPermission:[[facebookUserPermissions objectForKey:@"publish_stream"] boolValue]];
          
          [[[[CCCoreManager sharedInstance] server] currentUser] pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
               if (succeeded)
                    block(YES,nil);
          }];
          
          

     });
}
#endif
- (void) getUserPermissions
{
     [[PFFacebookUtils facebook] requestWithGraphPath:@"me/permissions" andDelegate:self];

}

- (void)request:(PF_FBRequest *)request didLoad:(id)result 
{
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    
    if ([requestType isEqualToString:@"me"])
    {
        // Save the result
        facebookUserData = result;
         
         [self getUserPermissions];
    }
     else if ([requestType isEqualToString:@"me/permissions"])
     {
          //save permissions 
          facebookUserPermissions = [(NSArray*)[result objectForKey:@"data"] objectAtIndex:0];
          
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
