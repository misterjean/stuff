//
//  CCParseServer.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseServer.h"

@implementation CCParseServer

-(CCParseServer *)init
{
    self = [super init];
    
    [Parse setApplicationId:@"A2UxTVO7C3gkI9SrLYX4ve68vLyOLeT23EkxKui6" 
                  clientKey:@"Phkqnmxs2MxAs2kQx0ugSwB9m0zbgsHMt9ykaPhH"];
    
    facebookConnector = [[CCFacebookConnector alloc] init];
    
    return self;
}

// Required CCServer methods

- (void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken
{
    // Tell Parse about the device token.
    [PFPush storeDeviceToken:newDeviceToken];
    
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) 
    {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Unable to subscribe to Parse global channel: %@", [error localizedDescription]];
        }
        else 
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Succesfully subscribed to the Parse global channel."];
        }
    }];
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
                 [parseUser subscribeToUserChannel];                 
                 
                 if (user.isNew)
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Created and logged in new Parse user %@ via Facebook connector.", [parseUser objectID]];
                     
                     // Grab the user's details from Facebook so we can update him on the Parse server
                     [facebookConnector setWithFacebookDataUser:parseUser];        
                     
                     [serverLoginDelegate loginCompleteWithUser:parseUser isNewUser:YES];
                 }
                 else 
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Logged in Parse user %@ via Facebook connector.", [parseUser objectID]];           
                     
                     [serverLoginDelegate loginCompleteWithUser:parseUser isNewUser:NO];
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
            [parseUser subscribeToUserChannel];
            if(isNewUser)
            {
                [serverLoginDelegate loginCompleteWithUser:parseUser isNewUser:YES];
            }
            else
            {                
                [serverLoginDelegate loginCompleteWithUser:parseUser isNewUser:NO];
            }
            
            
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
                 [parseUser subscribeToUserChannel];
                 
                 if ([user isNew])
                 {
                     [facebookConnector setWithFacebookDataUser:parseUser];  
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

- (void)startLoadingFriendsCrewsWithDelegate: (id<CCServerLoadFriendsCrewsDelegate>)delegate
{
    serverLoadFriendsCrewsDelegate = delegate;
    
    // Load friends from Facebook
    [facebookConnector startLoadingFriendsWithDelegate:self];    
    
    // Load friends from Email/Contacts    
}

- (void)startLoadingFacebookFriendsWithDelegate: (id<CCServerLoadFacebookFriendsDelegate>)delegate
{
    serverLoadFacebookFriendsDelegate = delegate;

    [facebookConnector startLoadingFriendsWithDelegate:self];        
}

// Required CCConnectorFriendsLoadCompleteDelegate methods

- (void)successfullyLoadedFriends:(NSArray *)friendNamesAndIds connectorType:(CCConnectorType)connectorType;
{
    // Use the array of friend's ID's to load their crews    
    switch (connectorType) 
    {
        case ccFacebookConnector:
            if (serverLoadFriendsCrewsDelegate != nil)
            {
                [self loadCrewsFromFacebookFriends:[self getFacebookIdsFromFriends:friendNamesAndIds]];
                
                serverLoadFriendsCrewsDelegate = nil;
            }
           
            if (serverLoadFacebookFriendsDelegate != nil)
            {
                [self findCCUsersFromFacebookFriends:[self getFacebookIdsFromFriends:friendNamesAndIds]];
                
                serverLoadFacebookFriendsDelegate = nil;
            }
            break;
            
        case ccTwitterConnector:
            break;
            
        case ccEmailConnector:
            break;            
    }
}

- (void)addNewVideoWithName:(NSString *)name currentVideoLocation:(NSString *)currentVideoLocation useNewThread:(Boolean)useNewThread addToCrews:(NSArray *)addToCrews delegate:(id<CCServerPostObjectDelegate>)delegate
{
    serverPostObjectDelegate = delegate;
    id<CCUser> user = [[CCCoreManager sharedInstance] currentUser];
    CCParseVideo *video =  [[CCParseVideo alloc] initLocalVideoWithName:name createdBy:user videoFile:currentVideoLocation crews:addToCrews];
    [video pushObjectWithNewThread:YES delegateOrNil:self];
}

//Called when the video object has successfully posted the video
- (void)objectPostSuccessWithType:(CCObjectType)objectType
{
    switch(objectType)
    {
    case ccCrew:
        [crewAddedDelegate successfullyAddedCrew:crewBeingAdded];
        break;
    case ccVideo:
        [serverPostObjectDelegate videoUploadSuccessToGUI];
        break;
    case ccUser:
        break; 
    }
}

//Called when the video object failed to upload
- (void)objectPostFailedWithType:(int)objectType reason:(NSString *)reason;
{
    [serverPostObjectDelegate videoUploadFailedWithReasonToGUI:reason];
}


- (void)saveVideo:(NSString *)name
{

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

- (NSArray *)getParseCrewsTest:(NSArray *)friendIds
{
    // Find all the users that are my Facebook friends
    NSArray *result;
    PFQuery *userQuery = [PFQuery queryForUser];
    [userQuery whereKey:@"facebookId" containedIn:friendIds];
    
    result = [userQuery findObjects];
    
    NSMutableArray *friendsToMatch = [[NSMutableArray alloc] init];
    
    for(int userIndex = 0; userIndex < [result count]; userIndex++)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Crew"];
        [query whereKey:@"crewMembers" equalTo:[result objectAtIndex:userIndex]];
        [friendsToMatch addObject:query];
    }
    
    // Find all the crews that have members matching the previous query
    PFQuery *crewQuery = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithArray:friendsToMatch]];
    
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
#warning We need to hear back from Parse about why this isn't working.  Right now the query never returns any crews.
    NSMutableArray *friendsCrews = [[NSMutableArray alloc] init];
    NSArray *result;
    
    result = [self getParseCrewsTest:friendIds];
    
    if (result == nil)
    {
        [serverLoadFriendsCrewsDelegate failedLoadingFriendsCrewsWithReason:@"Unknown"];
    }
    
    // Iterate through the resulting crews, and save them in an array
    for(int crewIndex = 0; crewIndex < [result count]; crewIndex++)
    {
        PFObject *crew = [result objectAtIndex:crewIndex];
        // Create the crew object, and add it to the array
        [friendsCrews addObject:[[CCParseCrew alloc] initWithData:crew]];
    }
    
    // Pass an NSArray of crews to the delegate
    [serverLoadFriendsCrewsDelegate successfullyLoadedFriendsCrews:[[NSArray alloc] initWithArray:friendsCrews]];
}

- (void)findCCUsersFromFacebookFriends:(NSArray *)friendIds
{
    // Find all the users that are my Facebook friends
    NSArray *result;
    PFQuery *userQuery = [PFQuery queryForUser];
    [userQuery whereKey:@"facebookId" containedIn:friendIds];
    
    NSError *error;
    result = [userQuery findObjects:&error];
    if (error)
    {
        [serverLoadFacebookFriendsDelegate failedLoadingFacebookFriendsWithReason:[[NSString alloc] initWithFormat:@"Unable to load crews from Facebook friends: %@", [error localizedDescription]]];
        return;
    }
    
    NSMutableArray *ccFriends = [[NSMutableArray alloc] init];
    
    for(int userIndex = 0; userIndex < [result count]; userIndex++)
    {
        [ccFriends addObject:[[CCParseUser alloc] initWithData:[result objectAtIndex:userIndex]]];                             
    }
    
    // Pass an NSArray of users to the delegate
    [serverLoadFacebookFriendsDelegate successfullyLoadedFacebookFriends:[[NSArray alloc] initWithArray:ccFriends]];
}

- (void)failedLoadingFriendsWithReason:(NSString *)reason
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:reason];
}

- (void)addNewCrewWithName:(NSString *)name useNewThread:(Boolean)useNewThread delegateOrNil:(id<CCCrewAddedDelegate>)delegateOrNil
{
    CCParseCrew *newCrew = [[CCParseCrew alloc] initLocalCrewWithName:name];
    
    [[[[CCCoreManager sharedInstance] currentUser] crews] addObject:newCrew];
    
    crewBeingAdded = newCrew;
    
    crewAddedDelegate = delegateOrNil;
    
    // Add the current user to the crew
    [newCrew addMember:[[CCCoreManager sharedInstance] currentUser] useNewThread:useNewThread];
    
    [newCrew pushObjectWithNewThread:useNewThread delegateOrNil:self];
}

- (void)removeCurrentUserFromCrew:(id<CCCrew>)crew useNewThread:(Boolean)useNewThread
{
    [crew removeMember:[[CCCoreManager sharedInstance] currentUser] useNewThread:NO];
    
    
    if ([[crew members] count] == 0)
    {
        // If there are no members left, delete the crew
        [crew deleteObjectWithNewThread:NO];
    }
    else
    {
        [crew pushObjectWithNewThread:NO delegateOrNil:nil];
    }
}


@end
