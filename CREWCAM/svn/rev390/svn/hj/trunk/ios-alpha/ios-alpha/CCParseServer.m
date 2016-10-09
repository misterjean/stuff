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
@synthesize uploaderIsBusy;

-(CCParseServer *)init
{
    self = [super init];
    
    if (self != nil)
    {
        [Parse setApplicationId:CC_PARSE_APPLICATION_ID 
                      clientKey:CC_PARSE_CLIENT_KEY];
        
        coreObjectsDelegates = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markUploaderAsBusy:) name:CC_VIDEO_UPLOADER_BUSY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markUploaderAsFree:) name:CC_VIDEO_UPLOADER_FREE object:nil];
        
        uploaderIsBusy = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) markUploaderAsBusy: (id) sender
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    uploaderIsBusy = YES;
}

- (void) markUploaderAsFree: (id) sender
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    uploaderIsBusy = NO;
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
        
        block(!error, error);
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
        [user pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            [[[CCCoreManager sharedInstance] server] setCurrentUser:user];
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_LOGGED_IN withProperties:nil];
            [self loadGlobalSettingsInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                block(user, succeeded, error);
            }];
        }];
    }
    else
    {
        block(user, success, error);
    }
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

- (void) handleVideoUploadResult:(id<CCVideo>)ccVideo:(BOOL)succeeded:(NSError *)error forCrew:(id<CCCrew>)crew forUsersNotInlist:(NSMutableArray *)usersThatHaveBeenNotified
{
    [[NSNotificationCenter defaultCenter] postNotificationName: CC_VIDEO_UPLOADER_FREE object: nil];

    if (succeeded)
    {
        [self sendNotificationsInBackgroundForVideo:ccVideo toCrew:crew forUsersNotInlist:usersThatHaveBeenNotified];
    }   
}

- (void) sendNotificationsInBackgroundForVideo:(id<CCVideo>) video toCrew:(id<CCCrew>) crew forUsersNotInlist:(NSMutableArray *)usersThatHaveBeenNotified
{
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       
       {
           // Blocking load
           [crew loadMembers];
       
           NSString *newVideoMessage = [[NSString alloc] initWithFormat:@"%@ added a new video to the crew \"%@\"!",
                                        [[[[CCCoreManager sharedInstance] server] currentUser ] getName], [crew getName]];
           
           NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:newVideoMessage, @"alert",
                                        [NSNumber numberWithInt:1], @"badge",
                                        [[[[CCCoreManager sharedInstance] server] currentUser ] getObjectID], @"src_User",
                                        [NSNumber numberWithInt:ccVideoPushNotification], @"type",
                                        [crew getObjectID], @"ID",
                                        nil];
           
           NSDictionary *messageDataForSecondaryCrew = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [[[[CCCoreManager sharedInstance] server] currentUser ] getObjectID], @"src_User",
                                                        [NSNumber numberWithInt:ccVideoPushNotification], @"type",
                                                        [crew getObjectID], @"ID",
                                                        nil];
           
           for (id<CCUser> user in [crew ccUsersThatAreMembers])
           {
               // Is the user this user?
               if ([[user getObjectID] isEqualToString:[[[[CCCoreManager sharedInstance] server] currentUser] getObjectID]])
                   continue;
               
               // Has the user been notified by another crew?
               if ([CCParseObject isObjectInArray:user arrayOfCCServerStoredObjects:usersThatHaveBeenNotified])
               {
                   [user sendNotificationWithData:messageDataForSecondaryCrew];
                   continue;
               }
               
               [usersThatHaveBeenNotified addObject:user];
               
               // Send the "Crewcam" notification
               [CCParseNotification createNewNotificationInBackgroundWithType:ccNewVideoNotification
                                    andTargetUser:user andSourceUser:[video getTheOwner]
                                    andTargetObject:video
                                    andTargetCrewOrNil:crew
                                    andMessage:newVideoMessage];
               
               // Send the push notification
               [user sendNotificationWithData:messageData];
           }
       }
    });
}

- (void)addNewVideoWithName:(NSString *)name currentVideoLocation:(NSString *)currentVideoLocation addToCrews:(NSArray *)addToCrews delegate:(id<CCVideoFilesUpdatesDelegate>)delegate mediaSource:(ccMediaSources)mediaSource
{
    [[CCCoreManager sharedInstance]checkNetworkConnectivity:^(BOOL succeeded, NSError *error){
        if (!succeeded)
        {
            if ([delegate respondsToSelector:@selector(finishedUploadingVideoFilesWithSucces:error:andVideoFilesReference:)])
                [delegate finishedUploadingVideoFilesWithSucces:succeeded error:error andVideoFilesReference:nil];
            
            return;
        }
        else 
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName: CC_VIDEO_UPLOADER_BUSY object: nil];
            
            NSMutableArray *usersThatHaveBeenNotified = [[NSMutableArray alloc] init];
            
            __block id<CCVideoFiles> newVideoFiles = [CCParseVideoFiles createNewVideoFilesWithName:name mediaSource:mediaSource 
                                                                                   delegate:delegate andVideoPath:currentVideoLocation];
            
            for (id<CCCrew> crew in addToCrews)
            {
                id<CCVideo> newVideo = [CCParseVideo createNewVideoObjectWithName:name creator:[[[CCCoreManager sharedInstance] server] currentUser] videoPath:currentVideoLocation mediaSource:mediaSource videoFiles:newVideoFiles withBlock:^(id<CCVideo> newCCVideo, BOOL succeeded, NSError *error) 
                                        {        
                                            [self handleVideoUploadResult:newCCVideo :succeeded :error forCrew:crew forUsersNotInlist:usersThatHaveBeenNotified];
                                        }];
                
                [crew addVideoLocally:newVideo];
            }
            
            [newVideoFiles uploadAndSaveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 NSString *videoSourceString;
                 switch (mediaSource)
                 {
                     case ccCamera:
                         videoSourceString = CC_VIDEO_SOURCE_CAMERA;
                         break;
                     case ccVideoLibrary:
                         videoSourceString = CC_VIDEO_SOURCE_LIBRARY;
                         break;
                         
                 }
                 
                 // Read the duration
                 AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:currentVideoLocation] options:nil];        
                 Float64 durationSeconds = CMTimeGetSeconds([videoAsset duration]);
                 
                 NSDictionary *kissMetricDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [NSNumber numberWithInteger:[addToCrews count]],  CC_NUMBER_OF_CREWS_POSTED_TO,
                                                       [NSNumber numberWithFloat:durationSeconds],       CC_LENGTH_OF_VIDEO_KEY,
                                                       videoSourceString,                                CC_SOURCE_FOR_VIDEO_KEY,
                                                       nil];
                 
                 if (succeeded)
                     [[CCCoreManager sharedInstance] recordMetricEvent:CC_SUCCESSFULLY_ADDED_VIDEO withProperties:kissMetricDictionary];
                 else 
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error uploading video: %@", [error localizedDescription]];
                     [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ADDING_VIDEO withProperties:nil]; 
                 }
             }];
        }
    }];
}

- (void) loadSingleVideoInBackgroundWithObjectID:(NSString *) objectId andBlock:(CCVideoResultBlock)block
{
    [CCParseVideo loadSingleVideoInBackgroundWithObjectID:objectId andBlock:block];
}

- (void) loadSingleVideoInBackgroundIfNeededWithObjectID:(NSString *)objectId fromArray:(NSArray *)array andBlock:(CCVideoResultBlock)block
{
    id<CCVideo> video = (id<CCVideo>)[CCParseObject getCCServerStoredObjectFromArray:array forObjectID:objectId];
    
    if (video)
    {
        block(video,YES,nil);
    }
    else 
    {
        [self loadSingleVideoInBackgroundWithObjectID:objectId andBlock:block];
    }

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
    [CCParseInvite createNewInviteToCrewInBackground:crew forUser:user fromUser:invitor withNotification:sendNotification];    
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


- (void) addNewCommentToVideo:(id<CCVideo>)video withText:(NSString *)text withBlockOrNil:(CCBooleanResultBlock) block 
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
        
        NSString *newVideoMessage = [[NSString alloc] initWithFormat:@"%@ added a new comment to the video \"%@\"!", 
                                     [[[[CCCoreManager sharedInstance] server] currentUser ]getName], [video getName] ];
        
        NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [[[[CCCoreManager sharedInstance] server] currentUser] getObjectID], @"src_User",
                                     [NSNumber numberWithInt:CCCommentPush], @"type",
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
                       [NSNumber numberWithInt:CCCommentPushAlert], @"type",
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
        
        // Notify the video creator, if he isn't the commentor
        if (![[[comment getCommenter] getUserID] isEqualToString: [[video getTheOwner] getUserID]])
        {
            newVideoMessage = [[NSString alloc] initWithFormat:@"%@ added a new comment to your video \"%@\"!", 
                               [[[[CCCoreManager sharedInstance] server] currentUser] getName], [video getName] ];
            
            messageData = [NSDictionary dictionaryWithObjectsAndKeys:newVideoMessage, @"alert",
                           [NSNumber numberWithInt:1], @"badge",
                           [[[[CCCoreManager sharedInstance] server] currentUser] getObjectID], @"src_User",
                           [NSNumber numberWithInt:CCCommentPushAlert], @"type",
                           [video getObjectID], @"ID",
                           nil];
            
            [[video getTheOwner] sendNotificationWithData:messageData];
            
            [CCParseNotification createNewNotificationInBackgroundWithType:ccNewCommentNotification
                                                             andTargetUser:[video getTheOwner]
                                                             andSourceUser:[comment getCommenter]
                                                             andTargetObject:video
                                                             andTargetCrewOrNil:nil
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
    
    for (CCBasePerson *person in ccPeople)
    {        
        // Post on their wall
        [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"/%@/feed",[person getUniqueID]] 
                              andParams:params 
                          andHttpMethod:@"POST"
                            andDelegate:self];
        
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

@end