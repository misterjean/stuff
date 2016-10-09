//
//  CCParseServer.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseServer.h"

@implementation CCParseServer
@synthesize currentUser;

-(CCParseServer *)init
{
    self = [super init];
    
    if (self != nil)
    {
        [Parse setApplicationId:@"A2UxTVO7C3gkI9SrLYX4ve68vLyOLeT23EkxKui6" 
                      clientKey:@"Phkqnmxs2MxAs2kQx0ugSwB9m0zbgsHMt9ykaPhH"];
        
        facebookConnector = [[CCFacebookConnector alloc] init];
        
        coreObjectsDelegates = [[NSMutableArray alloc] init];
    }
    
    return self;
}

// Required CCServer methods

- (void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken
{
    // Tell Parse about the device token.
    [PFPush storeDeviceToken:newDeviceToken];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#warning This call should be made on logout, that way we can avoid most of the potential race conditions. 
        [self clearNotificationSubscriptions];
        
        @synchronized([[[CCCoreManager sharedInstance] server] currentUser])
        {
            NSError *error;
            [PFPush subscribeToChannel:@"" error:&error];
            {
                if (error)
                {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Unable to subscribe to Parse global channel: %@", [error localizedDescription]];
                }
                else 
                {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Succesfully subscribed to the Parse global channel."];
                }
            }
        }
    });
}

- (void) clearNotificationSubscriptions 
{
    @synchronized([[[CCCoreManager sharedInstance] server] currentUser])
    {
        NSError *error;
        NSSet *channelSet =[PFPush getSubscribedChannels:&error];
        if (!error)
        {
            NSArray *channelArray = [channelSet allObjects];    
    
            for (int channelIndex = 0; channelIndex < [channelArray count]; channelIndex ++)
            {
                [PFPush unsubscribeFromChannel:[channelArray objectAtIndex:channelIndex] error:&error];
                
                if (error)
                {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to subscribe to crew channel: %@", [error localizedDescription]];
                }
            }
        }
    }
}

- (void)startSilentAuthenticationWithDelegate: (id<CCServerLoginDelegate>)delegate
{
    serverLoginDelegate = delegate;
    
    [facebookConnector tryToSilentlyAuthenticateWithDelegate:self];
}

- (void)startFacebookAuthenticationWithDelegate: (id<CCServerLoginDelegate>) delegate
{
    serverLoginDelegate = delegate;
    
    [facebookConnector startAuthenticatingWithDelegate:self];
}

- (void)startEmailAuthenticationWithDelegate: (id<CCServerLoginDelegate>)delegate email:(NSString *)email password:(NSString *)password isNewUser:(Boolean)isNewUser
{
    PFUser *user;
    serverLoginDelegate = delegate;
    
    if(isNewUser)
    {
        //New user sign them up!
        user = [PFUser user];
        user.username = email;
        user.password = password;
        user.email = email;
        
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) 
            {
                [self authenticationCompleteWithId:user.username isNewUser:YES connectorType:ccEmailConnector];
            } 
            else 
            {
            }
        }];
    }
    else
    {
        parseAuthenticator = [[CCParseAuthenticator alloc] init];
        [parseAuthenticator startAuthenticatingWithDelegate:self email:email password:password];
    }
    
}

- (void)authenticationCompleteWithId: (NSString *)userId isNewUser:(Boolean)isNewUser connectorType:(int) connectorType
{
    switch (connectorType)
    {
        case (ccFacebookConnector):
        {
            
            [PFFacebookUtils logInWithFacebookId:userId accessToken:[[PFFacebookUtils facebook] accessToken] expirationDate:[[PFFacebookUtils facebook] expirationDate] block:^(PFUser *user, NSError *error)
             {
                 if (user == nil) 
                 {
                     // This shouldn't ever happen.  We're either going to create the user, or log in an existing one
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error logging in user with Facebook.  Parse returned nil user.", nil];
                     
                     return;
                 }     

                 CCParseUser *parseUser =[[CCParseUser alloc] initWithData:user];

                 [[CCCoreManager sharedInstance] registerUserForMetrics:parseUser];
                 
                 [parseUser subscribeToUserChannel];                 
                 
                 if (user.isNew)
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Created and logged in new Parse user %@ via Facebook connector.", [parseUser objectID]];
                     
                     // Grab the user's details from Facebook so we can update him on the Parse server
                     [facebookConnector setWithFacebookDataUser:parseUser];        
                     
                     [serverLoginDelegate loginCompleteWithUser:parseUser isNewUser:YES];
                     
                     [[CCCoreManager sharedInstance] recordMetricEvent:@"Created Account" withProperties:nil];
                 }
                 else 
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Logged in Parse user %@ via Facebook connector.", [parseUser objectID]];           
                     
                     [serverLoginDelegate loginCompleteWithUser:parseUser isNewUser:NO];
                     
                     [[CCCoreManager sharedInstance] recordMetricEvent:@"Successful Login" withProperties:nil];
                 }                                             
             }];
            
            break; 
        }    
        case (ccTwitterConnector):
        {
            break;
        }
            
        case (ccEmailConnector):
        {
            PFUser *user;
            PFQuery *query = [PFQuery queryForUser];
            
            [query whereKey:@"email" equalTo:userId];
            user = (PFUser *)[query getFirstObject];
            CCParseUser *parseUser =[[CCParseUser alloc] initWithData:user];            

            [[CCCoreManager sharedInstance] registerUserForMetrics:parseUser];
            
            if (isNewUser)
            {
                [[CCCoreManager sharedInstance] recordMetricEvent:@"Created Account" withProperties:nil];
            }
            else
            {
                [[CCCoreManager sharedInstance] recordMetricEvent:@"Successful Login" withProperties:nil];                
            }
       
            [parseUser subscribeToUserChannel];

            [serverLoginDelegate loginCompleteWithUser:parseUser isNewUser:isNewUser];
            
            
            break;
        }
    }   
}

- (void)authenticationFailedWithReason: (NSString *)reason
{
    
}

- (void)silentAuthenticationCompleteWithId: (NSString *)userId isNewUser:(Boolean)isNewUser connectorType:(int) connectorType
{
    switch (connectorType)
    {
        case (ccFacebookConnector):
            [PFFacebookUtils logInWithFacebookId:userId accessToken:[[PFFacebookUtils facebook] accessToken] expirationDate:[[PFFacebookUtils facebook] expirationDate] block:^(PFUser *user, NSError *error)
             {
                 if (user == nil) 
                 {
                     // This shouldn't ever happen.  We're either going to create the user, or log in an existing one
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error logging in user with Facebook.  Parse returned nil user.", nil];
                     
                     return;
                 }     
                 
                 CCParseUser *parseUser =[[CCParseUser alloc] initWithData:user];
                 
                 [[CCCoreManager sharedInstance] registerUserForMetrics:parseUser];
                   
                 [parseUser subscribeToUserChannel];
                 
                 if ([user isNew])
                 {
                     [facebookConnector setWithFacebookDataUser:parseUser];  
                     [[CCCoreManager sharedInstance] recordMetricEvent:@"Created Account" withProperties:nil];   
                 }
                 else   
                 {
                     [[CCCoreManager sharedInstance] recordMetricEvent:@"Successful Login" withProperties:nil];              
                 }                                  

                 [serverLoginDelegate silentLoginCompleteWithUser:parseUser isNewUser:[user isNew]];
             }];

            break;
        case (ccTwitterConnector):
            break;
        case (ccEmailConnector):
            break;
    }
    
}

- (void)silentAuthenticationFailedWithReason: (NSString *)reason
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:reason, nil];
    [serverLoginDelegate silentLoginFailedWithReason:reason];
}

- (void)startLoadingFriendsCrewsWithBlock:(CCArrayResultBlock)block
{
    serverLoadFriendsCrewsBlock = block;
    [facebookConnector startLoadingFriendsWithDelegate:self]; 
}

- (void )startLoadingFriendsWithBlock:(CCArrayResultBlock)block
{
    serverLoadFriendsBlock = block;
    [facebookConnector startLoadingFriendsWithDelegate:self];
}

// Required CCConnectorFriendsLoadCompleteDelegate methods

- (void)successfullyLoadedFriends:(NSArray *)friendNamesAndIds connectorType:(CCConnectorType)connectorType;
{
    NSMutableArray *ccFriends = [[NSMutableArray alloc] init];

    // Use the array of friend's ID's to load their crews    
    switch (connectorType) 
    {
        case ccFacebookConnector:
            if (serverLoadFriendsCrewsBlock != nil)
            {
                [self loadCrewsFromFacebookFriends:[self getFacebookIdsFromFriends:friendNamesAndIds]];
                
                serverLoadFriendsCrewsBlock = nil;
            }
           
            if (serverLoadFriendsBlock != nil)
            {
                //[ccFriends arrayWithArray:[self findCCUsersFromFacebookFriends:[self getFacebookIdsFromFriends:friendNamesAndIds]]];
                //[ccFriends arrayByAddingObjectsFromArray:[self findCCUsersFromFacebookFriends:[self getFacebookIdsFromFriends:friendNamesAndIds]]];
                [ccFriends addObjectsFromArray:[self findCCUsersFromFacebookFriends:[self getFacebookIdsFromFriends:friendNamesAndIds]]];
                [ccFriends addObjectsFromArray:[self findCCUsersFromPhoneContacts]]; 
                ccFriends = (NSMutableArray *)[[NSSet setWithArray:ccFriends] allObjects];
                // Pass an NSArray of users to the block
                
                //The Following removes redundent CCUsers from ccFriends
                NSArray *copy = [ccFriends copy];
                NSInteger index = [copy count] - 1;
                for (id object in [copy reverseObjectEnumerator]) {
                    if ([ccFriends indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
                        [ccFriends removeObjectAtIndex:index];
                    }
                    index--;
                }
                
                serverLoadFriendsBlock(ccFriends, nil);
                
                serverLoadFriendsBlock = nil;
            }
            break;
            
        case ccTwitterConnector:
            break;
            
        case ccEmailConnector:
            break;            
    }
}

- (void)addNewVideoWithName:(NSString *)name currentVideoLocation:(NSString *)currentVideoLocation useNewThread:(Boolean)useNewThread addToCrews:(NSArray *)addToCrews delegate:(id<CCServerUploadVideoDelegate>)delegate
{
    id<CCUser> user = [[[CCCoreManager sharedInstance] server] currentUser];
    CCParseVideo *video =  [[CCParseVideo alloc] initLocalVideoWithName:name createdBy:user videoFile:currentVideoLocation crews:addToCrews];

    [video uploadVideoWithProgressIndicatorOrNil:delegate block:^(BOOL succeeded, NSError *error) 
    {
       if (error)
       {
           [[CCCoreManager sharedInstance] recordMetricEvent:@"Failed Adding Video" withProperties:nil];
           [delegate videoUploadFailedWithReasonToGUI:[error localizedDescription]];
       }
       else 
       {
           [video pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
           {
               if (error)
               {
                   [[CCCoreManager sharedInstance] recordMetricEvent:@"Failed Adding Video" withProperties:nil];
                   [delegate videoUploadFailedWithReasonToGUI:[error localizedDescription]];
               }
               else 
               {
                   NSDictionary *newVideoProperties = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:[addToCrews count]] , @"numberOfCrews", nil];
                   [[CCCoreManager sharedInstance] recordMetricEvent:@"Succesfully Added Video" withProperties:newVideoProperties];
                   [delegate videoUploadSuccessToGUI];
               }
           }];
       }
    }];    
}

- (NSArray *)getFacebookIdsFromFriends:(NSArray *)friends
{
    NSMutableArray *facebookIds = [[NSMutableArray alloc] init];
    
    for (NSDictionary *friendNameAndId in friends)
    {
        [facebookIds addObject:[friendNameAndId objectForKey:@"id"]];
    }
    
    return [[NSArray alloc] initWithArray:facebookIds];
}

- (NSArray *)getParseCrews:(NSArray *)friendIds
{
    // Find all the users that are my Facebook friends
    NSArray *result;
    PFQuery *userQuery = [PFQuery queryForUser];
    [userQuery whereKey:@"facebookId" containedIn:friendIds];
    
    // Find all the crews that have members matching the previous query
    PFQuery *crewQuery = [PFQuery queryWithClassName:@"Crew"];
    [crewQuery includeKey:@"crewMembers"];
    [crewQuery includeKey:@"videos"];
    [crewQuery includeKey:@"theOwner"];
    [crewQuery whereKey:@"crewMembers" matchesQuery:userQuery];
    
    NSError *error;
    result = [crewQuery findObjects:&error];
    if (error)
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crews from Facebook friends: %@", [error localizedDescription]]; 
        return nil;
    }
    return result;
}

- (void)loadCrewsFromFacebookFriends:(NSArray *)friendIds
{
    NSMutableArray *friendsCrews = [[NSMutableArray alloc] init];
    NSArray *result;
    
    result = [self getParseCrews:friendIds];
    
    if (result != nil)
    {
        // Iterate through the resulting crews, and save them in an array
        for(int crewIndex = 0; crewIndex < [result count]; crewIndex++)
        {
            PFObject *crew = [result objectAtIndex:crewIndex];
            // Create the crew object, and add it to the array
            
#warning check for private crew
            if ([[crew objectForKey:@"securitySetting"] intValue] == CCPublic)
            {
                [friendsCrews addObject:[[CCParseCrew alloc] initWithData:crew]];
            }
        }     
    }

    serverLoadFriendsCrewsBlock([[NSArray alloc] initWithArray:friendsCrews], nil);
}

- (NSArray *)findCCUsersFromFacebookFriends:(NSArray *)friendIds
{
    // Find all the users that are my Facebook friends
    NSArray *result;
    PFQuery *userQuery = [PFQuery queryForUser];
    [userQuery whereKey:@"facebookId" containedIn:friendIds];
    
    NSError *error;
    result = [userQuery findObjects:&error];
   
    NSMutableArray *ccFriends = [[NSMutableArray alloc] init];
    if (result != nil)
    {
        for(int userIndex = 0; userIndex < [result count]; userIndex++)
        {
            [ccFriends addObject:[[CCParseUser alloc] initWithData:[result objectAtIndex:userIndex]]];                             
        }
    }
    
    return ccFriends;

}

- (NSArray *) findCCUsersFromPhoneContacts
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people  = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
    for(int i = 0;i<ABAddressBookGetPersonCount(addressBook);i++)
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
        ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {       
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);   
            NSString *phoneNumber = (__bridge_transfer NSString *)phoneNumberRef;
           
            
            NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"/:.+ -)("];
            phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
            [phoneNumbers addObject:phoneNumber];
        }
    }
    
    // Find all the users that are my Facebook friends
    NSArray *result;
    PFQuery *userQuery = [PFQuery queryForUser];
    [userQuery whereKey:@"phoneNumber" containedIn:phoneNumbers];
    
    NSError *error;
    result = [userQuery findObjects:&error];
    
    NSMutableArray *ccFriends = [[NSMutableArray alloc] init];
    if (result != nil)
    {
        for(int userIndex = 0; userIndex < [result count]; userIndex++)
        {
            [ccFriends addObject:[[CCParseUser alloc] initWithData:[result objectAtIndex:userIndex]]];                             
        }
    }
    return ccFriends;
    
}

- (void)failedLoadingFriendsWithReason:(NSString *)reason
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:reason];
}

- (void) addNewCrewWithName:(NSString *)name privacy:(NSInteger)privacy withBlock:(CCCrewResultBlock)block
{
    CCParseCrew *newCrew = [[CCParseCrew alloc] initLocalCrewWithName:name privacy:privacy];
    
    [[[[[CCCoreManager sharedInstance] server] currentUser] crews] addObject:newCrew];
    
    // Add the current user to the crew
    [newCrew addMember:[[[CCCoreManager sharedInstance] server] currentUser]];
    
    [newCrew pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
        if (error)
        {
            if (block)
                block(nil, NO, error);
        }
        else 
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:@"Succesfully Added Crew" withProperties:nil];
            if (block)
                block(newCrew, YES, nil);
        }
            
    }];
}

- (void)startReloadingTheCurrentUserWithDelegateOrNil:(id<CCCoreObjectsDelegate>)delegate
{
    static Boolean isCurrentlyRefreshing = NO;
    
    if (delegate != nil && ![coreObjectsDelegates containsObject:delegate])
    {
        [coreObjectsDelegates addObject:delegate];
    }
    
    if (isCurrentlyRefreshing)
        return;
    
    // Notify delegates on the main thread
    for(id<CCCoreObjectsDelegate> delegate in coreObjectsDelegates)
    {
        [delegate startingToRefreshCurrentUser];
    }
    
    isCurrentlyRefreshing = YES;
            
    // Refresh the user on this background thread
    [[[[CCCoreManager sharedInstance] server] currentUser] pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
        if (error)
        {
#warning Handle this
        }
        else 
        {
            // Notify delegates on the main thread
            for(id<CCCoreObjectsDelegate> delegate in coreObjectsDelegates)
            {
                [delegate successfullyRefreshedCurrentUser];
            }   
        }
        
        isCurrentlyRefreshing = NO;
    }];   
}

- (void)startReloadingTheCurrentUsersCrewsWithDelegateOrNil:(id<CCCoreObjectsDelegate>)delegate
{
    static Boolean isCurrentlyRefreshing = NO;
    
    if (delegate != nil && ![coreObjectsDelegates containsObject:delegate])
    {
        [coreObjectsDelegates addObject:delegate];
    }
    
    // Delete all the objects
    [[[[[CCCoreManager sharedInstance] server] currentUser] crews] removeAllObjects];
    
    if (isCurrentlyRefreshing)
        return;
    
    // Notify delegates on the main thread
    for(id<CCCoreObjectsDelegate> delegate in coreObjectsDelegates)
    {
        [delegate startingToRefreshUsersCrews];
    }
    
    isCurrentlyRefreshing = YES;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{    
        
        // Refresh the user on this background thread
        [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewsWithNewThread:NO];
                
        dispatch_async( dispatch_get_main_queue(), ^{                        
            
            // Notify delegates on the main thread
            for(id<CCCoreObjectsDelegate> delegate in coreObjectsDelegates)
            {
                [delegate successfullyRefreshedUsersCrews];
            }
            
            isCurrentlyRefreshing = NO;
        });
    });
}

- (void)removeCurrentUserFromCrew:(id<CCCrew>)crew useNewThread:(Boolean)useNewThread
{
    [crew removeMember:[[[CCCoreManager sharedInstance] server] currentUser]];
        
    if ([[crew members] count] == 0)
    {
        // If there are no members left, delete the crew, also delete old invites               
        for (int inviteIndex = 0; inviteIndex < [[crew pfInvites] count]; inviteIndex++)
        {
            [[[crew pfInvites] objectAtIndex:inviteIndex] deleteInBackground];
        }
        
        [crew deleteObjectWithBlockOrNil:nil];
    }
    else
    {
        [crew pushObjectWithBlockOrNil:nil];
    }
}

- (id<CCCrew>) getCrewFromObjectID: (NSString*)crewObjectID
{
    for (int crewIndex = 0;crewIndex < [[[[[CCCoreManager sharedInstance] server] currentUser] crews] count]; crewIndex++)
    {
        if ( [[[[[[[CCCoreManager sharedInstance] server] currentUser] crews] objectAtIndex:crewIndex] objectID] isEqualToString:crewObjectID])
        {
            return [[[[[CCCoreManager sharedInstance] server] currentUser] crews] objectAtIndex:crewIndex];
        }
    }
    
    return nil;
}


@end
