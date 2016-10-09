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
@synthesize authenticator;
@synthesize globalSettings;
@synthesize lastVideoUploadFailed;

-(CCParseServer *)init
{
    self = [super init];
    
    if (self != nil)
    {
        [Parse setApplicationId:CC_PARSE_APPLICATION_ID     
                      clientKey:CC_PARSE_CLIENT_KEY];
    
        coreObjectsDelegates = [[NSMutableArray alloc] init];
        ccVideoUploadersInProgress = [[NSMutableArray alloc] init];
        facebookLoadingDataCondition = [[NSCondition alloc] init];
        globalSettings = [[CCGlobalConfigurations alloc] init];
    }
    
    return self;
}

- (void) dealloc
{
    [self setCurrentUser:nil];
    [self setAuthenticator:nil];
    facebookLoadingDataCondition = nil;
    [self setGlobalSettings:nil];
}

// Required CCServer methods
- (void) loadGlobalSettingsInBackgroundWithBlock:(CCBooleanResultBlock) block
{
    PFQuery *globalSettingsQuery = [PFQuery queryWithClassName:@"GlobalSettings"];
    
    [globalSettingsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error || !object)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load global configuration: %@", [error localizedDescription]];
        }
        
        globalSettings.isInLockdown  = [[object objectForKey:@"isInLockdown"] boolValue];
        globalSettings.isOpenAccess = [[object objectForKey:@"isOpenAccess"] boolValue];
        globalSettings.isPostableToFacebook = [[object objectForKey:@"isPostableToFacebook"] boolValue];
        globalSettings.currentAppStoreRevisionString = [object objectForKey:@"releasedVersion"];
        
        block(!error, error);
    }];
}

- (void) loadDatabaseKeysInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    customerDatabaseDictionary = [[NSMutableDictionary alloc] init];
    
    PFQuery *customerDatabases = [PFQuery queryWithClassName:@"CustomerDatabaseKey"];
    
    [customerDatabases findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
    {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load customer databases: %@", [error localizedDescription]];
        }
        
        for (PFObject *customerDatabaseObject in objects)
        {
            CCCustomerDatabaseKey *thisCustomerDatabase = [[CCCustomerDatabaseKey alloc] init];
            
            [thisCustomerDatabase setApplicationId:[customerDatabaseObject objectForKey:@"applicationId"]];
            [thisCustomerDatabase setClientKey:[customerDatabaseObject objectForKey:@"clientKey"]];            
            
            [customerDatabaseDictionary setObject:thisCustomerDatabase forKey:[customerDatabaseObject objectForKey:@"code"]];
        }     
        if (block)
            block(!error, error);        
        
    }];
}

- (BOOL) setDatabaseForCode:(NSString *) code
{
    if (code) 
    {
        
        CCCustomerDatabaseKey *customerKey = [self getCustomerDatabaseKeyForCode:code];
        
        if (customerKey)
        {
            [Parse setApplicationId:[customerKey applicationId] clientKey:[customerKey clientKey]];
             
             return YES;
        }
             
        return NO;    
    }
    else 
    {
        [Parse setApplicationId:CC_PARSE_APPLICATION_ID clientKey:CC_PARSE_CLIENT_KEY]; 
        
        return YES;
    }
}

- (CCCustomerDatabaseKey *) getCustomerDatabaseKeyForCode:(NSString *) code
{
    return [customerDatabaseDictionary objectForKey:code];
}

- (void)configureNotificationsWithDeviceToken: (NSData *)newDeviceToken
{
    // Tell Parse about the device token.
    [PFPush storeDeviceToken:newDeviceToken];
}

- (void) sendNotificationWithData:(NSDictionary *)data ToChannels:(NSArray *)channels
{
    PFPush *message = [[PFPush alloc] init];
    [message setChannels:channels];
    [message setData:data];
    [message sendPushInBackground];
}

- (void)startEmailAuthenticationInBackgroundWithBlock:(CCUserResultBlock) block andEmail:(NSString *)email andPassword:(NSString *)password isNewUser:(BOOL) isNewUser
{
    [[CCCoreManager sharedInstance] checkNetworkConnectivity:^(BOOL succeeded, NSError *error){
        if (succeeded)
        {
            authenticator = [[CCParseAuthenticator alloc] initWithUsername:email andPassword:password];
            
            if(isNewUser)
            {
                [authenticator signUpNewUserInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error){
                    [self handleAuthenticatorCompletionForUser:user success:succeeded andError:error andBlock:block];
                }]; 
            }
            else
            {
                [authenticator authenticateInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) {
                    [self handleAuthenticatorCompletionForUser:user success:succeeded andError:error andBlock:block];
                } forceFacebookAuthentication:NO];
            } 
        }
        else 
        {
            NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccNoNetworkConnection userInfo:nil];
            block(nil, NO, crewcamError);
        }
    }];
   
}

- (void)startFacebookAuthenticationInBackgroundWithForce:(BOOL) forceFacebook andBlock:(CCUserResultBlock) block
{
    authenticator = [[CCParseAuthenticator alloc] init];
    
    @try {
        [authenticator authenticateInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) {
            @try {
                if (succeeded)
                {
                    if (![user getIsUserNew])
                    {
                        [self handleAuthenticatorCompletionForUser:user success:succeeded andError:error andBlock:block];
                        return;
                    }
                    
                    if (forceFacebook)
                    {
                        //User is new, and this is not a background fb loggin attempt. Make sure an email account doesn't already exist for this user.
                        PFQuery *emailUserQuery = [PFUser query];
                        [emailUserQuery whereKey:@"emailAddress" equalTo:[user getEmailAddress]];
                        
                        [emailUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if ([objects count] == 1)
                            {
                                //This email has already been taken. Do something about it
                                CCParseUser *redundentUser = [[CCParseUser alloc] initWithServerData:[objects objectAtIndex:0]];

                                //This user has an existing email account. Prompt the user to login with existing account link it with fb
                                NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccEmailAccountAlreadyExistsForAccount userInfo:nil];
                                [self handleAuthenticatorCompletionForUser:user success:NO andError:crewcamError andBlock:block];
                            }
                            else if ([objects count] > 1)
                            {
                                //this is a effed up case tell the user that link cannot be made.
                                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Serious issue. Appears more then one account share the same email address"];
                                NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccMoreThenOneAccountWithSameEmail userInfo:nil];
                                [self handleAuthenticatorCompletionForUser:user success:NO andError:crewcamError andBlock:block];
                            }
                            else
                            {
                                [self handleAuthenticatorCompletionForUser:user success:succeeded andError:error andBlock:block];
                            }
                        }];
                    }
                }
                else
                {
                    NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccGeneralFacebookLoginError userInfo:nil];
                    [self handleAuthenticatorCompletionForUser:nil success:NO andError:crewcamError andBlock:block];
                }
            }
            @catch (NSException *exception) {
                NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccGeneralFacebookLoginError userInfo:nil];
                [self handleAuthenticatorCompletionForUser:nil success:NO andError:crewcamError andBlock:block];
            }            
        } forceFacebookAuthentication:forceFacebook];
    }
    @catch (NSException *exception) {
        NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccGeneralFacebookLoginError userInfo:nil];
        [self handleAuthenticatorCompletionForUser:nil success:NO andError:crewcamError andBlock:block];
    }
}

- (void)linkCurrentUserToFacebookInBackgroundWithBlock:(CCBooleanResultBlock) block
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"user_about_me",
                            @"user_likes",
                            @"read_stream",
                            @"publish_stream",
                            @"email",
                            nil];

    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {            
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:permissions block:^(BOOL succeeded, NSError *error) {
            
            if (!error)
            {
                
                [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];
                
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [facebookLoadingDataCondition lock];
                    [facebookLoadingDataCondition wait];
                    [facebookLoadingDataCondition unlock];
                    
                    if (!facebookUserData)
                    {
                        dispatch_async( dispatch_get_main_queue(), ^{
                            NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccGeneralFBLinkingError userInfo:nil];
                            block(NO, crewcamError);
                        });
                        return;
                    }
                    
                    [currentUser setFacebookID:[facebookUserData valueForKey:@"id"]];
                    
                    dispatch_async( dispatch_get_main_queue(), ^{
                        [currentUser pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                            block(succeeded, error);
                        }];
                    });
                });
            }
            else
            {
                if ([error code] == 208)
                {
                    NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccFacebookAccountAlreadyLinked userInfo:nil];
                    block(NO, crewcamError);
                }
                else
                {
                    block(succeeded, error);
                }
            }
        }];
    }
    else
    {
         block(YES, nil);
    }
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result
{
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    
    if ([requestType isEqualToString:@"me"])
    {
        // Save the result
        facebookUserData = result;
        
        [facebookLoadingDataCondition signal];
    }
};

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load from Facebook: %@", [error localizedDescription]];
    
    [facebookLoadingDataCondition signal];
}

- (void)unlinkCurrentUserToFacebookInBackgroundWithBlock:(CCBooleanResultBlock)block
{
    [currentUser setFacebookID:(NSString *)[NSNull null]];
    
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error)
    {
        block(succeeded, error);
    }];
}

- (void) handleAuthenticatorCompletionForUser:(id<CCUser>) user success:(BOOL) success andError:(NSError *) error andBlock:(CCUserResultBlock) block
{
    if (success)
    {
        [user setUserRevisionToCurrentRevision];
        
        [user pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            [[[CCCoreManager sharedInstance] server] setCurrentUser:user];
            
            NSDictionary *kissMetricDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [Parse getApplicationId],  CC_APPLICATION_ID_USED,
                                                  nil];
            
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_LOGGED_IN withProperties:kissMetricDictionary];
            
            [self createNewAutoCrewsIfNeeded];
            
            [self loadGlobalSettingsInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [user pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                    [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                        [[[CCCoreManager sharedInstance] friendManager] addFacebookFriendsAndContactsWhoAreUsingCrewcamWithBlockOrNil:nil];
                    }];
                    block(user, succeeded, error);
                }];
                
            }];
        }];
    }
    else
    {
        NSDictionary *loginFailedProperties = [[NSDictionary alloc] initWithObjectsAndKeys:
                                               [error localizedDescription], CC_LOGIN_FAILURE_KEY,
                                               nil];
        
        
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_LOGIN_FAILED withProperties:loginFailedProperties];
        block(user, success, error);
    }
}

- (void) logOutCurrentUserInBackground
{
    if (!currentUser)
        return;
    
    [currentUser logOutUserInBackground];
    currentUser = nil;
}

- (NSArray *) getFriendsCrewsThatImNotPartOfFromCrews:(NSArray*)friendsCrews;
{
    NSMutableArray *crewsThatImNotPartOf = [[NSMutableArray alloc] init];
    
    for (int friendsCrewIndex = 0; friendsCrewIndex < [friendsCrews count]; friendsCrewIndex++)
    {
        if (![CCParseObject isObjectInArray:[friendsCrews objectAtIndex:friendsCrewIndex] arrayOfCCServerStoredObjects:[[self currentUser] ccCrews]])  
        {
            [crewsThatImNotPartOf addObject:[friendsCrews objectAtIndex:friendsCrewIndex]];
        }
    }
    return crewsThatImNotPartOf;
}



- (void)addNewVideoWithName:(NSString *)name
       currentVideoLocation:(NSString *)currentVideoLocation
                 addToCrews:(NSArray *)addToCrews
              addToFacebook:(BOOL)addToFacebook
                mediaSource:(ccMediaSources)mediaSource
{
    CCParseVideoUploader *newVideoUploader = [[CCParseVideoUploader alloc] initWithVideoName:name andCurrentVideoPath:currentVideoLocation forCrews:addToCrews andMediaSource:mediaSource andAddToFacebook:addToFacebook];
    
    [newVideoUploader startUploadInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
// The below commented out code is part of Gamification... saving for a later release.
//            for (id<CCCrew> crew in addToCrews)
//            {
//                [[self currentUser] incrementUserRewardPointsByValueInBackground:10 forCrew:crew block:^(BOOL succeeded, NSError *error)
//                 {
//                     if (error)
//                     {
//                         [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"An error occured while increasing reward points. So points were not awarded to the user for this video."];
//                     }
//                 }];
//            }
        }
        
        lastVideoUploadFailed = !succeeded;
        
        [ccVideoUploadersInProgress removeObject:newVideoUploader];
    }];
    
    [ccVideoUploadersInProgress addObject:newVideoUploader];
}

- (void) retryVideoUploadWithUploader:(id<CCVideoUploader>) uploader
{
    if (![ccVideoUploadersInProgress containsObject:uploader])
    {
        [ccVideoUploadersInProgress addObject:uploader];
    }
}

- (BOOL) getLastVideoUploadSuccess
{
    return lastVideoUploadFailed;
}

- (BOOL)isUploading
{
    return ([ccVideoUploadersInProgress count] > 0);
}

- (void) loadSingleVideoInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCVideoResultBlock)block
{
    [CCParseVideo loadSingleVideoInBackgroundWithObjectID:objectId andBlock:block];
}

- (void) loadSingleCrewInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCCrewResultBlock)block
{
    [CCParseCrew loadSingleCrewInBackgroundWithObjectID:objectId andBlock:block];
}

- (void) loadSingleCrewInBackgroundIfNeededWithObjectID:(NSString *)objectId fromArray:(NSArray *)array andBlock:(CCCrewResultBlock)block
{
    id<CCCrew> crew = (id<CCCrew>)[CCParseObject getCCServerStoredObjectFromArray:array forObjectID:objectId];
    
    if (crew)
    {
        block(crew,YES,nil);
    }
    else 
    {
        [self loadSingleCrewInBackgroundWithObjectID:objectId andBlock:block];
    }
}

- (void)addNewInviteToCrewInBackground:(id<CCCrew>) crew forUser:(id<CCUser>) user fromUser:(id<CCUser>) invitor withNotification:(BOOL)sendNotification
{
    [CCParseInvite createNewInviteToCrewInBackground:crew forUser:user fromUserOrNil:invitor withNotification:sendNotification];    
}

- (NSArray *) getUsersPotentialAutoCrewIds
{
    NSMutableArray *usersPotentialAutoCrewsIds = [[NSMutableArray alloc] init];
    
    for (NSDictionary *school in [currentUser FBEducationIds])
    {
        if ([school objectForKey:@"id"]) 
            [usersPotentialAutoCrewsIds addObject:[school objectForKey:@"id"]];
    }
    
    for (NSDictionary *work in [currentUser FBWorkIds])
    {
        if ([work objectForKey:@"id"])
            [usersPotentialAutoCrewsIds addObject:[work objectForKey:@"id"]];
    }
    
    if ([[currentUser FBLocationId] objectForKey:@"id"])
        [usersPotentialAutoCrewsIds addObject:[[currentUser FBLocationId] objectForKey:@"id"]];
    
    if ([[currentUser FBHometownId] objectForKey:@"id"])
        [usersPotentialAutoCrewsIds addObject:[[currentUser FBHometownId] objectForKey:@"id"]];
    
    return usersPotentialAutoCrewsIds;
}

- (void) createNewAutoCrewsIfNeeded
{
    PFQuery *usersPotentialAutoCrewsQuery = [PFQuery queryWithClassName:@"Crew"];
    
    NSArray *usersPotentialAutoCrewsIds = [self getUsersPotentialAutoCrewIds];
    
    if ([usersPotentialAutoCrewsIds count] > 0)
    {    
        [usersPotentialAutoCrewsQuery whereKey:@"autoCrewId" containedIn:usersPotentialAutoCrewsIds];
        
        [usersPotentialAutoCrewsQuery findObjectsInBackgroundWithBlock:^(NSArray *parseCrewObjects, NSError *error)
        {
            if (error)
            {
               
            }
            else 
            {
                BOOL foundId;
               
                if ([currentUser FBEducationIds])
                {
                    for (NSDictionary *school in [currentUser FBEducationIds])
                    {
                        foundId = NO;
                        for (PFObject *parseCrewObject in parseCrewObjects)
                        {
                            if ([[school objectForKey:@"id"] isEqualToString:[parseCrewObject objectForKey:@"autoCrewId"]])
                            {
                                foundId = YES;
                                break;
                            }
                        }
                        
                        if (!foundId)
                        {
                            //create crew
                            [CCParseCrew createNewSpecialAutoCrewInBackgroundWithName:[school objectForKey:@"name"] crewtype:CCFBSchool autoCrewId:[school objectForKey:@"id"] withBlock:^(id<CCCrew> objectId, BOOL succeeded, NSError *error) {
                                //do stuff 
                            }];
                        }
                    }
                }
                
                if ([currentUser FBWorkIds])
                {
                    for (NSDictionary *work in [currentUser FBWorkIds])
                    {
                        foundId = NO;
                        for (PFObject *parseCrewObject in parseCrewObjects)
                        {
                            if ([[work objectForKey:@"id"] isEqualToString:[parseCrewObject objectForKey:@"autoCrewId"]])
                            {
                                foundId = YES;
                                break;
                            }
                        }
                        
                        if (!foundId)
                        {
                            //create crew
                            [CCParseCrew createNewSpecialAutoCrewInBackgroundWithName:[work objectForKey:@"name"] crewtype:CCFBWork autoCrewId:[work objectForKey:@"id"] withBlock:^(id<CCCrew> objectId, BOOL succeeded, NSError *error) {
                                //do stuff 
                            }];
                        }
                    }
                }
                
                if ([currentUser FBLocationId])
                {
                    foundId = NO;
                    for (PFObject *parseCrewObject in parseCrewObjects)
                    {
                        if ([[[currentUser FBLocationId] objectForKey:@"id"] isEqualToString:[parseCrewObject objectForKey:@"autoCrewId"]])
                        {
                            foundId = YES;
                            break;
                        }
                    }
                    
                    if (!foundId)
                    {
                        //create crew
                        [CCParseCrew createNewSpecialAutoCrewInBackgroundWithName:[[currentUser FBLocationId] objectForKey:@"name"] crewtype:CCFBLocation autoCrewId:[[currentUser FBLocationId] objectForKey:@"id"] withBlock:^(id<CCCrew> objectId, BOOL succeeded, NSError *error) {
                            //do stuff 
                        }];
                    }
                }
                
                if ([currentUser FBHometownId] && ![[currentUser FBHometownId] isEqualToDictionary:[currentUser FBLocationId]])
                {
                    foundId = NO;
                    for (PFObject *parseCrewObject in parseCrewObjects)
                    {
                        if ([[[currentUser FBHometownId] objectForKey:@"id"] isEqualToString:[parseCrewObject objectForKey:@"autoCrewId"]])
                        {
                            foundId = YES;
                            break;
                        }
                    }
                    
                    if (!foundId)
                    {
                        //create crew
                        [CCParseCrew createNewSpecialAutoCrewInBackgroundWithName:[[currentUser FBHometownId] objectForKey:@"name"] crewtype:CCFBLocation autoCrewId:[[currentUser FBHometownId] objectForKey:@"id"] withBlock:^(id<CCCrew> objectId, BOOL succeeded, NSError *error) {
                            //do stuff 
                        }];
                    }
                }
            }
        }];
    }
}

- (void) addNewCrewWithName:(NSString *)name privacy:(CCSecuritySetting)privacy withBlock:(CCCrewResultBlock)block
{         
    [CCParseCrew createNewCrewInBackgroundWithName:name creator:[[[CCCoreManager sharedInstance] server] currentUser] privacy:privacy withBlock:^(id<CCCrew> newCrew, BOOL succeeded, NSError *error) 
    {            
        if (succeeded)
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_SUCCESSFULLY_ADDED_CREW withProperties:nil];
        }
        else
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ADDING_CREW withProperties:nil];
        }
        
        block(newCrew, succeeded, error);   
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
         if (!error)
         {
             for(id<CCCoreObjectsDelegate> delegate in coreObjectsDelegates)
             {
                 [delegate successfullyRefreshedCurrentUser];
             }   
         }
         else 
         {
             for(id<CCCoreObjectsDelegate> delegate in coreObjectsDelegates)
             {
                 [delegate failedRefreshingCurrentUserWithReason:[error localizedDescription]];
             }   
         }
         
         isCurrentlyRefreshing = NO;
     }];   
}


- (void) addNewCommentToVideo:(id<CCVideo>)video inCrew:(id<CCCrew>)crew withText:(NSString *)text withBlockOrNil:(CCBooleanResultBlock) block 
{
    [CCParseComment createNewCommentInBackGroundWithText:text withBlockOrNil:^(id<CCComment> newComment, BOOL succeeded, NSError *error)
    {
        if (succeeded)
        {    
            id<CCVideo> videoPointer = video;
            [video addCommentInBackground:newComment withBlockOrNil:^(BOOL succeeded, NSError *error)
            {
                if (succeeded)
                {
                    [self sendNotificationsInBackgroundForComment:newComment onVideo:videoPointer];
                    [[CCCoreManager sharedInstance] recordMetricEvent:CC_SUCCESSFULLY_ADDED_COMMENT withProperties:nil];
// The below commented out code is part of Gamification... saving for a later release.
//                    [[self currentUser] incrementUserRewardPointsByValueInBackground:2 forCrew:crew block:^(BOOL succeeded, NSError *error)
//                    {
//                        if (error)
//                        {
//                            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"An error occured while increasing reward points. So points were not awarded to the user for this comment."];
//                        }
//                    }];
                }
                else 
                {
                    [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ADDING_COMMENT withProperties:nil];
                }
                if (block)
                    block(succeeded, error);
            }];
        }
        else 
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ADDING_COMMENT withProperties:nil];
            
            if (block)
                block(succeeded, error);
        }
        
    }];
}

- (void) sendNotificationsInBackgroundForComment:(id<CCComment>) comment onVideo:(id<CCVideo>) video
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray *ccUsersThatHaveBeenNotiied = [[NSMutableArray alloc] init];
        NSError *error;
        
        NSString * videoOwnerName = [[video getTheOwner] getName];
        
        if ([videoOwnerName hasSuffix:@"s"])
            videoOwnerName = [NSString stringWithFormat:@"%@'",videoOwnerName];
        else 
            videoOwnerName = [NSString stringWithFormat:@"%@'s",videoOwnerName];
        
        NSString *newVideoMessage = [[NSString alloc] initWithFormat:@"%@ added a new comment to %@ video!", 
                                     [[[[CCCoreManager sharedInstance] server] currentUser ]getName], videoOwnerName ];
        
        NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [[[[CCCoreManager sharedInstance] server] currentUser] getObjectID], @"src_User",
                                     [NSNumber numberWithInt:ccCommentPushNotification], @"type",
                                     [video getObjectID], @"ID",
                                     nil];
        
        // Notify everyone that knows about this video
        PFQuery *crewsThatHaveThisVideoQuery = [PFQuery queryWithClassName:@"Crew"];
        [crewsThatHaveThisVideoQuery whereKey:@"videos" equalTo:[video getServerData]];
        
        NSArray *crewsWithVideo = [crewsThatHaveThisVideoQuery findObjects:&error];
        NSMutableArray *ccCrewsWithVideo = [[NSMutableArray alloc] initWithCapacity:[crewsWithVideo count]];
        
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crews for notification: %@", [error localizedDescription]];
        }
        else
        {
            // Notify these people
            for (PFObject *pfCrew in crewsWithVideo)
            {
                id<CCCrew> ccCrew = [[CCParseCrew alloc] initWithServerData:pfCrew];
                
                // Load up the members
                if (![ccCrew loadMembers])
                    continue;
                
                [ccCrewsWithVideo addObject:ccCrew];
                
                // Send the notification to reload the video's comments
                [ccCrew sendNotificationWithData:messageData];
            }
        }        
        
        // Notify all commenters with an alert:
        messageData = [NSDictionary dictionaryWithObjectsAndKeys:newVideoMessage, @"alert",
                       [NSNumber numberWithInt:1], @"badge",
                       [[[[CCCoreManager sharedInstance] server] currentUser] getObjectID], @"src_User",
                       [NSNumber numberWithInt:ccCommentPushNotification], @"type",
                       [video getObjectID], @"ID",
                       nil];
        
        // Load comments
        [video loadCommentsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            if (!succeeded)
                return;
            
            // Notify all commenters
            for(id<CCComment> thisComment in [video ccComments])
            {
                // Have we already notified this user?
                if ([CCParseObject isObjectInArray:[thisComment getCommenter] arrayOfCCServerStoredObjects:ccUsersThatHaveBeenNotiied])
                    continue;
                
                // Is this user the author of this comment?
                if ([[[thisComment getCommenter] getObjectID] isEqualToString:[[comment getCommenter] getObjectID]])
                    continue;
                
                // Is this user the creator of the video?  We'll get him later
                if ([[[thisComment getCommenter] getObjectID] isEqualToString:[[video getTheOwner] getObjectID]])
                    continue;    
                
                for(id<CCCrew> ccCrew in ccCrewsWithVideo)
                {
                    // Is this comment's author in this crew still?
                    if (![CCParseObject isObjectInArray:[thisComment getCommenter] arrayOfCCServerStoredObjects:[ccCrew ccUsersThatAreMembers]])
                        continue;
                    
                    // Send our notification
                    [CCParseNotification createNewNotificationInBackgroundWithType:ccNewCommentNotification
                                                                     andTargetUser:[thisComment getCommenter]
                                                                     andSourceUser:[comment getCommenter]
                                                                   andTargetObject:video 
                                                                andTargetCrewOrNil:ccCrew
                                                                        andMessage:newVideoMessage];
                    
                    // Send th push notification
                    [[thisComment getCommenter] sendNotificationWithData:messageData];            
                    
                    // Remember that we notified this user
                    [ccUsersThatHaveBeenNotiied addObject:[thisComment getCommenter]];
                    
                    break;
                }
                
                
            }
        }];
        
        id<CCCrew> ccCrew = nil;
        
        if ([crewsWithVideo count] == 1)
            ccCrew = [ccCrewsWithVideo objectAtIndex:0];
        
        // Notify the video creator, if he isn't the commentor
        if (![[[comment getCommenter] getUserID] isEqualToString: [[video getTheOwner] getUserID]])
        {
            newVideoMessage = [[NSString alloc] initWithFormat:@"%@ added a new comment to your video!", 
                               [[[[CCCoreManager sharedInstance] server] currentUser] getName]];
            
            messageData = [NSDictionary dictionaryWithObjectsAndKeys:newVideoMessage, @"alert",
                           [NSNumber numberWithInt:1], @"badge",
                           [[[[CCCoreManager sharedInstance] server] currentUser] getObjectID], @"src_User",
                           [NSNumber numberWithInt:ccCommentPushNotification], @"type",
                           [video getObjectID], @"ID",
                           nil];
            
            [[video getTheOwner] sendNotificationWithData:messageData];
            
            [CCParseNotification createNewNotificationInBackgroundWithType:ccNewCommentNotification
                                                             andTargetUser:[video getTheOwner]
                                                             andSourceUser:[comment getCommenter]
                                                             andTargetObject:video
                                                             andTargetCrewOrNil:ccCrew
                                                             andMessage:newVideoMessage];
        }
    });
}

- (void) addNewUserFromPerson:(CCBasePerson *) person toCrews:(NSArray *) ccCrews withBlockOrNil:(CCBooleanResultBlock) block
{
    [CCParseInvitedPerson createNewInvitedPersonInBackgroundFromPerson:person invitor:[[[CCCoreManager sharedInstance] server] currentUser] toCrews:ccCrews withBlock:block];
}

- (void) inviteCCFacebookPersons:(NSArray *) ccPeople toCrew:(id<CCCrew>) crew
{       
    NSString *crewCamLink = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_POST_URL_KEY withDefault:NSLocalizedStringFromTable(@"INVITE_CREWCAM_URL", @"Localizable", nil)];
    
    NSString *crewCamImageLink = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_FACEBOOK_POST_IMAGE_URL_KEY withDefault:NSLocalizedStringFromTable(@"FACEBOOK_INVITE_IMAGE_URL", @"Localizable", nil)];
    
    NSString *crewCamMessage = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_FACEBOOK_POST_MESSAGE_KEY withDefault:[NSString stringWithFormat:@"You've been invited to \"%@\" on Crewcam!", [crew getName]]];
    
    NSMutableDictionary* params = [NSMutableDictionary
                                   dictionaryWithObjectsAndKeys:
                                   CREWCAM_FACEBOOK_ID_STRING, @"app_id",
                                   crewCamLink, @"link",
                                   crewCamImageLink, @"picture",
                                   @"Crewcam", @"name",
                                   NSLocalizedStringFromTable(@"FACEBOOK_INVITE_CAPTION_TEXT", @"Localizable", nil), @"caption",
                                   NSLocalizedStringFromTable(@"FACEBOOK_INVITE_DESCRIPTION_TEXT", @"Localizable", nil), @"description",
                                   crewCamMessage,  @"message",
                                   nil];
    
#warning Do we want to handle error cases here?
    for (CCBasePerson *person in ccPeople)
    {        
        // Post on their wall
        [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"/%@/feed",[person getUniqueID]] 
                              andParams:params 
                          andHttpMethod:@"POST"
                            andDelegate:nil];
        
        // Add our new "temporary" person
        [self addNewUserFromPerson:person toCrews:[[NSArray alloc] initWithObjects:crew, nil] withBlockOrNil:nil];
        
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_INVITED_FACEBOOK_FRIEND withProperties:nil];
    }
}

- (void) inviteCCAddressBookPeople:(NSArray *) ccPeople toCrew:(id<CCCrew>) crew displayMessageOnView:(UIViewController *) viewController withBlock:(CCBooleanResultBlock) block
{
    messageInviteCompletionBlock = block;
    addressBookContactsToInvite = ccPeople;
    crewsToInviteTo = [[NSArray alloc] initWithObjects:crew, nil];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithCapacity:[ccPeople count]];
    
    for (CCBasePerson *person in ccPeople)
    {
        [phoneNumbers addObject:[person getUniqueID]];       
        
        // Add our new "temporary" person
        [self addNewUserFromPerson:person toCrews:[[NSArray alloc] initWithObjects:crew, nil] withBlockOrNil:nil];
        
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_INVITED_CONTACT withProperties:nil];
    }
    
	if([MFMessageComposeViewController canSendText])
	{
        NSString *crewCamLink = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_POST_URL_KEY withDefault:NSLocalizedStringFromTable(@"INVITE_CREWCAM_URL", @"Localizable", nil)];
        
		controller.body = [[NSString alloc] initWithFormat:@"I invited you to \"%@\" on Crewcam!  Check it out at \"%@\".", [crew getName],crewCamLink];
		controller.recipients = phoneNumbers;
        controller.messageComposeDelegate = self;
		[viewController presentModalViewController:controller animated:YES];
	}
    else
    {
        messageInviteCompletionBlock(NO, nil);
        messageInviteCompletionBlock = nil;
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent)
    {
        // Invite everyone
        for (CCBasePerson *person in addressBookContactsToInvite)
        {
            [self addNewUserFromPerson:person toCrews:crewsToInviteTo withBlockOrNil:nil];
        }
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
        if (messageInviteCompletionBlock)
        {
            messageInviteCompletionBlock(result == MessageComposeResultSent, nil);
            messageInviteCompletionBlock = nil;
        }
    }];
}

//These tasks are shared between both facebook and email login.
- (void) performPreloginTasksWithBlockOrNil:(CCBooleanResultBlock) block promoText:(NSString *)promoText
{
    [[[CCCoreManager sharedInstance] server] loadDatabaseKeysInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error){
        BOOL codeSucceeded = NO;
        
        if (![promoText isEqualToString:@""])
        {
            codeSucceeded = [[[CCCoreManager sharedInstance] server] setDatabaseForCode:promoText];
        }
        else
        {
            codeSucceeded = [[[CCCoreManager sharedInstance] server] setDatabaseForCode:nil];     
        }
        
        if (!codeSucceeded)
        {
            CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Code Error" message:@"Invalid Promo Code" withTextField:NO delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [alert show];
            if (block)
                block(NO, error);
            return;
        }
        
        if (block)
            block(succeeded, error);
    }];
}

- (void) changeUsernameAndPasswordWithEmail:(NSString *)email password:(NSString *)password block:(CCBooleanResultBlock)block
{
    if (email != nil)
    {
        [[PFUser currentUser] setUsername:email];
    }
    
    [[PFUser currentUser] setPassword:password];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (block != nil)
        {
            block(succeeded, error);
        }
    }];
    return;
}

- (void) sendPasswordRecoveryEmailWithEmail:(NSString *)email
{
    [PFUser requestPasswordResetForEmailInBackground:email];
}

- (void) doesUserExistWithEmail:(NSString *)email block:(CCBooleanResultBlock)block
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"emailAddress" equalTo:email];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            if ([objects count] >= 1)
            {
                //email was found
                block(YES, nil);
            }
            else
            {
                //email was not found no error though
                block(NO, nil);
            }
        }
        else
        {
            //query in the error
            block(NO, error);
        }
    }];
}

- (void) deleteCurrentUserWithBlock:(CCBooleanResultBlock)block
{
    [[PFUser currentUser]deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [PFUser logOut];
        if (block)
            block(succeeded, error);
    }];
}

@end