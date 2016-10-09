
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

- (BOOL) isIDForInsitution:(NSDictionary *)instituation InArray:(NSArray *)array
{
     for (NSDictionary *cateloguedInstitution in array)
     {
          if ([instituation isEqualToDictionary:cateloguedInstitution])
               return YES;
     }
     
     return NO;
}

- (void) setFBListsForUser:(id<CCUser>)ccUser
{
     NSMutableArray *fbSchoolObjects= [[NSMutableArray alloc] init];
     NSDictionary *schoolDictioanry;
     
     for (NSDictionary *school in [facebookUserData valueForKey:@"education"])
     {
          schoolDictioanry = [school objectForKey:@"school"];
          
          if (![self isIDForInsitution:schoolDictioanry InArray:fbSchoolObjects])
               [fbSchoolObjects addObject:schoolDictioanry];
     }
     [ccUser setFBEducationIds:fbSchoolObjects];
     
     
     NSMutableArray *fbWorkObjects= [[NSMutableArray alloc] init];
     NSDictionary *workDictionary;
     
     for (NSDictionary *work in [facebookUserData valueForKey:@"work"])
     {
          workDictionary = [work objectForKey:@"employer"];
          
          if (![self isIDForInsitution:workDictionary InArray:fbWorkObjects])
               [fbWorkObjects addObject:workDictionary];
     }
     
     [ccUser setFBWorkIds:fbWorkObjects];
     
     [ccUser setFBLocationId:[facebookUserData valueForKey:@"location"]];
     
     [ccUser setFBHometownId:[facebookUserData valueForKey:@"hometown"]];
}

- (void) authenticateInBackgroundWithBlock:(CCUserResultBlock) block forceFacebookAuthentication:(BOOL) forceFacebook
{
     [[CCCoreManager sharedInstance] checkNetworkConnectivity:^(BOOL succeeded, NSError *error) {
          if (!succeeded)
          {
               NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccNoNetworkConnection userInfo:nil];
               block(nil, NO, crewcamError);
               return;
          }
          else
          {
               [self startAuthenticateAndForceFacebook:forceFacebook andBlock:^(id<CCUser> user, BOOL succeeded, NSError *error)
                {
                     if (!succeeded)
                     {
                          NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccGeneralFailure userInfo:nil];
                          [PFUser logOut];
                          block(nil, NO, crewcamError);
                          return;
                     }
                     
                     if (facebookUserPermissions && facebookUserData)
                     {
                          [user setFacebookUserWallPostPermission:[[facebookUserPermissions objectForKey:@"publish_stream"] boolValue]];
                          [user setFacebookID:[facebookUserData valueForKey:@"id"]];
                     }
                     
                     [user subscribeToUserAndGlobalChannelInBackground];
                     [[CCCoreManager sharedInstance] registerUserForMetrics:user];
                     block(user, succeeded, error);
                }];
          }
     }];
}

- (void)sendNotificationsToFriendsOfUser:(id<CCUser>)user
{
     [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
          if (!error)
          {
               NSString *message = [[NSString alloc] initWithFormat:@"Your friend \"%@\" has joined Crewcam",[user getName]];
               
               
               NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                            message, @"alert",
                                            [NSNumber numberWithInt:1], @"badge",
                                            [[[[CCCoreManager sharedInstance] server] currentUser] getObjectID], @"src_User",
                                            [NSNumber numberWithInt:ccFriendJoinedPushNotification], @"type",
                                            nil];
               
               for (id<CCUser> friend in [[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends])
               {
                    [CCParseNotification createNewNotificationInBackgroundWithType:ccFriendJoinedNotification andTargetUser:friend andSourceUser:user andTargetObject:nil andTargetCrewOrNil:nil andMessage:message];
                    
                    [friend sendNotificationWithData:messageData];
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
          
          // Pull to make sure we have all the relatinship data
          [user pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {               
               if(!succeeded)
               {
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
               if ([user getPhoneNumber] && ![[user getPhoneNumber] isEqualToString:@""])
               {
                    PFQuery *phoneNumberQuery = [PFQuery queryWithClassName:@"InvitedPerson"];
                    [phoneNumberQuery whereKey:@"phoneNumber" hasSuffix:[user getPhoneNumber]];
                    [queriesToMatch addObject:phoneNumberQuery];
               }
               
               if ([user getEmailAddress] && ![[user getEmailAddress] isEqualToString:@""])
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
                              [user setIsUserNewlyActivated:YES];
                              
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
                    id<CCUser> userThatInvited;
                    
                    if ([invitedPerson objectForKey:@"invitedBy"] != nil)
                    {
                         userThatInvited = [[CCParseUser alloc] initWithServerData:[invitedPerson objectForKey:@"invitedBy"]];
                         if ([userThatInvited isUserDeveloper])
                              [user setNumberOfInvites:[NSNumber numberWithInt:CC_NEW_USER_INVITE_LIMIT]];
                    }
                    
                    // Set the user active, and push before doing anything else
                    [user setUserActive:YES];
                    [user setIsUserNewlyActivated:YES];
                    
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
                                        [CCParseInvite createNewInviteToCrewInBackground:ccCrew forUser:user fromUserOrNil:userThatInvited withNotification:NO];
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
     }];
}

- (void) startAuthenticateAndForceFacebook:(BOOL) forceFacebook andBlock:(CCUserResultBlock) block
{
     if ([PFUser currentUser])
     {
          CCParseUser *ccUser = [[CCParseUser alloc] initWithServerData:[PFUser currentUser]];
               
          [ccUser pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
               if (!succeeded)
               {
                    [PFUser logOut];
                    block(nil, NO, [[NSError alloc] initWithDomain:@"Test" code:2 userInfo:nil]);
                    return;
               }
               
               if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
               {
                    [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];
                    
                    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         [facebookLoadingDataCondition lock];
                         [facebookLoadingDataCondition wait];
                         [facebookLoadingDataCondition unlock];
                         
                         dispatch_async( dispatch_get_main_queue(), ^{
                              [ccUser pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                                   [self setFBListsForUser:ccUser];
                                   block(ccUser, YES, nil);
                              }];
                         });
                    });
               }
               
               else 
               {
                    block(ccUser, YES, nil);
               }
               
               return;
          }];
     }     
     else if (username != nil && password != nil)
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
     //First query to see if a fb account already uses the provided email.
     PFQuery *query = [PFUser query];
     [query whereKey:@"emailAddress" equalTo:username];
     [query whereKey:@"facebookId" matchesRegex:@""];
     
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          if ([objects count] > 0)
          {
               NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccEmailInUseFacebookAccount userInfo:nil];
               block(nil, NO, crewcamError);
          }
          else
          {
               PFUser *user = [PFUser user];
               user.username = username;
               user.password = password;
               user.email = username;
               
               [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                {
                     if (!succeeded)
                     {
                          [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to sign up new user: %@", [error localizedDescription]];
                          
                          NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccGeneralFailure userInfo:nil];
                          
                          //translate parse error code 202 which means account already exists.
                          if ([error code] == 202)
                          {
                               crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccEmailInUseEmailAccount userInfo:nil];
                          }
                          
                          block(nil, NO, crewcamError);
                     }
                     else
                     {
                          CCParseUser *ccUser = [[CCParseUser alloc] initWithServerData:user];
                          
                          [ccUser setEmailAddress:username];
                          
                          [ccUser subscribeToUserAndGlobalChannelInBackground];
                          [[CCCoreManager sharedInstance] registerUserForMetrics:ccUser];
                          block(ccUser, succeeded, error);
                     }
                }];
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
                             @"user_education_history",
                             @"user_work_history",
                             @"user_hometown",
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
                                   dispatch_async( dispatch_get_main_queue(), ^{
                                        NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"User canceled"];
                                        NSDictionary *errorDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedDescriptionKey,  descriptiveErrorString, nil];
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
     dispatch_async( dispatch_get_main_queue(), ^{
          [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];
     });
     
     // Wait on a new thread for the response
     dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          [facebookLoadingDataCondition lock];
          [facebookLoadingDataCondition wait];
          [facebookLoadingDataCondition unlock];
          
          // Get back to the main thread
          dispatch_async( dispatch_get_main_queue(), ^{
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
                          
                          [self setFBListsForUser:ccUser];
                     }
                     
                     OSAtomicTestAndClear(YES, &isTryingToAuthenticateWithFacebook);
                     block(ccUser, !error, error);
                }];
          });
     });
}

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
