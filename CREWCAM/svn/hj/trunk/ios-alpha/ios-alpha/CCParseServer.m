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

-(CCParseServer *)init
{
    self = [super init];
    
    if (self != nil)
    {
        [Parse setApplicationId:@"UA2bjSA0tJQ3eajFVMs6rO1CEKldAaADYdUC8h6F" 
                      clientKey:@"tqFvnlKUw9gYNi4qGEWec7dUPDZ0CW0jE7wiYSBk"];    
        
        coreObjectsDelegates = [[NSMutableArray alloc] init];
    }
    
    return self;
}

// Required CCServer methods
- (void) loadGlobalSettingsInBackgroundWithBlock:(CCBooleanResultBlock) block
{
    PFQuery *globalSettingsQuery = [PFQuery queryWithClassName:@"GlobalSettings"];
    
    [globalSettingsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error || !object)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load global configuration: %@", [error localizedDescription]];
            return;
        }
        
        globalSettings.isInLockdown  = [[object objectForKey:@"isInLockdown"] boolValue];
        globalSettings.isOpenAccess = [[object objectForKey:@"isOpenAccess"] boolValue];        
        
    }];
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

- (void)startFacebookAuthenticationInBackgroundWithForce:(BOOL) forceFacebook andBlock:(CCUserResultBlock) block
{
    authenticator = [[CCParseAuthenticator alloc] init];
    
    [authenticator authenticateInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) {
        [self handleAuthenticatorCompletionForUser:user success:succeeded andError:error andBlock:block];        
    } forceFacebookAuthentication:forceFacebook];
}

- (void) handleAuthenticatorCompletionForUser:(id<CCUser>) user success:(BOOL) success andError:(NSError *) error andBlock:(CCUserResultBlock) block
{
    if (success)
    {
        [[[CCCoreManager sharedInstance] server] setCurrentUser:user];
        [self loadGlobalSettingsInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            block(user, succeeded, error);            
        }];
    }
    
    block(user, success, error);
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

- (void) handleVideoUploadResult:(id<CCVideo>)CCVideo:(BOOL)succeeded:(NSError *)error forCrews:(NSArray *)crews
{
    if (succeeded)
    {
        [[CCCoreManager sharedInstance] recordMetricEvent:@"Succesfully added video" withProperties:nil];
        for (int crewsIndex = 0; crewsIndex < [crews count]; crewsIndex++) 
        {
            CCParseCrew *crew = [crews objectAtIndex:crewsIndex];
            CCParseCrew *pointertoCrew = crew;
            [crew addVideoInBackground:CCVideo withBlockOrNil:^(BOOL succeeded, NSError *error) {
                [pointertoCrew loadVideosInBackgroundWithBlockOrNil:nil startingAtIndex:0 forVideoCount:10];
            }];
        }
    }   
    else 
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error uploading video: %@", [error localizedDescription]];
        [[CCCoreManager sharedInstance] recordMetricEvent:@"Failed adding video" withProperties:nil];
    }
}

- (void)addNewVideoWithName:(NSString *)name currentVideoLocation:(NSString *)currentVideoLocation addToCrews:(NSArray *)addToCrews delegate:(id<CCVideoUpdatesDelegate>)delegate mediaSource:(ccMediaSources)mediaSource
{
    id<CCVideo> newVideo = [CCParseVideo createNewVideoInBackgroundWithName:name creator:[[[CCCoreManager sharedInstance] server] currentUser] videoPath:currentVideoLocation delegate:delegate mediaSource:mediaSource withBlock:^(id<CCVideo> newCCVideo, BOOL succeeded, NSError *error) 
    {        
        [self handleVideoUploadResult:newCCVideo :succeeded :error forCrews:addToCrews];
    }];
    
    for (id<CCCrew> crew in addToCrews)
    {
        [crew addVideoLocally:newVideo];
    }
}

- (void) loadSingleVideoInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCVideoResultBlock)block
{
    [CCParseVideo loadSingleVideoInBackgroundWithObjectID:objectId andBlock:block];
}

- (void) retryVideoUpload:(id<CCVideo>)video forCrews:(NSArray *)crews
{
    [video uploadAndSaveInBackgroundWithBlock:^(id<CCVideo> CCVideo, BOOL succeeded, NSError *error)
    {
        [self handleVideoUploadResult:CCVideo :succeeded :error forCrews:crews];
    }];
}

- (void)addNewInviteToCrewInBackground:(id<CCCrew>) crew forUser:(id<CCUser>) user fromUser:(id<CCUser>) invitor
{
    [CCParseInvite createNewInviteToCrewInBackground:crew forUser:user fromUser:invitor];    
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

- (void)getParseCrewsInBackgroundForFriends:(NSArray *)friendIds withBlock:(CCArrayResultBlock) block
{
    // Find all the users that are my Facebook friends    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"facebookId" containedIn:friendIds];
    
    // Find all the crews that have members matching the previous query
    PFQuery *crewQuery = [PFQuery queryWithClassName:@"Crew"];
    [crewQuery whereKey:@"crewMembers" matchesQuery:userQuery];
    [crewQuery orderByDescending:@"membersCount"];
    
    [crewQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crews from Facebook friends: %@", [error localizedDescription]]; 
        }
        
        if (block)
            block(objects, error);            
    }];
}

- (void)loadCrewsFromFacebookFriends:(NSArray *)friendIds
{
    NSMutableArray *friendsCrews = [[NSMutableArray alloc] init];
    
    [self getParseCrewsInBackgroundForFriends:friendIds withBlock:^(NSArray *array, NSError *error) 
    {
        if (!error)
        {
            // Iterate through the resulting crews, and save them in an array
            for(int crewIndex = 0; crewIndex < [array count]; crewIndex++)
            {
                PFObject *crew = [array objectAtIndex:crewIndex];
                // Create the crew object, and add it to the array
                if ([[crew objectForKey:@"securitySetting"] intValue] == CCPublic)
                {
                    [friendsCrews addObject:[[CCParseCrew alloc] initWithServerData:crew]];
                }
            }  
            
            
        }
    }];
}

- (void)findCCUsersFromFacebookFriendsInBackground:(NSArray *)friendIds withBlockOrNil:(CCArrayResultBlock) block
{
    // Find all the users that are my Facebook friends
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"facebookId" containedIn:friendIds];
    [userQuery orderByAscending:@"firstName"];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
    {
        NSMutableArray *ccFriends = [[NSMutableArray alloc] init];
        
        if (!error) 
        {
            for(int userIndex = 0; userIndex < [objects count]; userIndex++)
            {
                [ccFriends addObject:[[CCParseUser alloc] initWithServerData:[objects objectAtIndex:userIndex]]];                             
            }
        }
        
        if (block)
            block(ccFriends, error); 
       
    }];      
}

- (void)failedLoadingFriendsWithReason:(NSString *)reason
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:reason];
}

- (void) addNewCrewWithName:(NSString *)name privacy:(CCSecuritySetting)privacy withBlock:(CCCrewResultBlock)block
{         
    [CCParseCrew createNewCrewInBackgroundWithName:name creator:[[[CCCoreManager sharedInstance] server] currentUser] privacy:privacy withBlock:^(id<CCCrew> newCrew, BOOL succeeded, NSError *error) 
    {            
        if (succeeded)
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:@"Succesfully added crew" withProperties:nil];
        }
        else
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:@"Failed adding crew" withProperties:nil];
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


- (void) addNewCommentToVideo:(id<CCVideo>)video withText:(NSString *)text withBlockOrNil:(CCBooleanResultBlock) block 
{
    [CCParseComment createNewCommentInBackGroundWithText:text withBlockOrNil:^(id<CCComment> newComment, BOOL succeeded, NSError *error)
    {
        if (succeeded)
        {
            
            [video addCommentInBackground:newComment withBlockOrNil:^(BOOL succeeded, NSError *error)
            {
                if (succeeded)
                {
                    [[CCCoreManager sharedInstance] recordMetricEvent:@"Succesfully added comment" withProperties:nil];
                }
                else 
                {
                    [[CCCoreManager sharedInstance] recordMetricEvent:@"Failed adding comment" withProperties:nil];
                }
                if (block)
                    block(succeeded, error);
            }];
        }
        else 
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:@"Failed adding comment" withProperties:nil];
            
            if (block)
                block(succeeded, error);
        }
        
    }];
}

- (void) addNewUserFromPerson:(CCBasePerson *) person toCrews:(NSArray *) ccCrews withBlockOrNil:(CCBooleanResultBlock) block
{
    [CCParseInvitedPerson createNewInvitedPersonInBackgroundFromPerson:person invitor:[[[CCCoreManager sharedInstance] server] currentUser] toCrews:ccCrews withBlock:block];
}

- (void) inviteCCFacebookPersons:(NSArray *) ccPeople toCrew:(id<CCCrew>) crew
{       
    NSMutableDictionary* params = [NSMutableDictionary
                                   dictionaryWithObjectsAndKeys:
                                   CREWCAM_FACEBOOK_ID_STRING, @"app_id",
                                   @"http://crewc.am", @"link",                                   
                                   @"http://crewc.am/crewcam-splash.png", @"picture",
                                   @"Crewcam", @"name",
                                   @"The supercoolest video messaging app", @"caption",
                                   @"Coming soon to the App Store", @"description",
                                   [NSString stringWithFormat:@"You've been invited to the crew called \"%@\" on Crewcam!", [crew getName]],  @"message",
                                   nil];
    
    for (CCBasePerson *person in ccPeople)
    {        
        // Post on their wall
        [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"/%@/feed",[person getUniqueID]] 
                              andParams:params 
                          andHttpMethod:@"POST"
                            andDelegate:self];
        
        // Add our new "temporary" person
        [self addNewUserFromPerson:person toCrews:[[NSArray alloc] initWithObjects:crew, nil] withBlockOrNil:nil];
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
    }
    
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = [[NSString alloc] initWithFormat:@"I invited you to \"%@\" on Crewcam!  Check it out at http://crewc.am/theapp.", [crew getName]];
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

@end