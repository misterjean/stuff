//
//  CCParseCrew.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseCrew.h"

@interface CCParseCrew ()
@property int savedNumberOfVideosFromAutoCrews;
@property int savedNumberOfMembersFromAutoCrews;
@end

@implementation CCParseCrew

static NSString *className = @"Crew";

// CCCrew properties
@synthesize ccVideos;
@synthesize numberOfNewVideos;
@synthesize ccUsersThatAreMembers;
@synthesize ccInvites;
@synthesize oldVideosLoaded;
@synthesize numberOfOldVideos;
@synthesize savedNumberOfVideosFromAutoCrews;
@synthesize savedNumberOfMembersFromAutoCrews;

// CCParseCrew helper methods
- (void) notifyListenersThatVideosAreAboutToBeLoaded
{
    @synchronized(crewUpdateDelegates)
    {
        for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
        {
            if ([delegate respondsToSelector:@selector(startingToLoadVideos)])
                [delegate startingToLoadVideos];
        }
    }
}

- (void) notifyListenersThatVideosHaveLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    @synchronized(crewUpdateDelegates)
    {
        for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
        {
            if ([delegate respondsToSelector:@selector(finishedLoadingVideosWithSuccess:andError:)])
                [delegate finishedLoadingVideosWithSuccess:success andError:error];
        }
    }
}

- (void) notifyListenersThatVideosHaveBeenAdded:(NSArray *) newVideoIndexes andVideosHaveBeenRemoved:(NSArray *) deletedVideoIndexes
{
    @synchronized(crewUpdateDelegates)
    {
        for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
        {
            if ([delegate respondsToSelector:@selector(addedNewVideosAtIndexes:andRemovedVideosAtIndexes:)])
            {
                [delegate addedNewVideosAtIndexes:newVideoIndexes andRemovedVideosAtIndexes:deletedVideoIndexes];
            }
        }
    }
}

- (void) notifyListenersThatNumberOfNewVideosHasBeenLoaded:(int) numNewVideos
{
    @synchronized(crewUpdateDelegates)
    {
        for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
        {
            if ([delegate respondsToSelector:@selector(finishedLoadingNumberOfNewVideos:)])
            {
                [delegate finishedLoadingNumberOfNewVideos:numNewVideos];
            }
        }
    }
}

- (void) notifyListenersThatOldVideosHaveBeenAdded:oldVideoIndexes
{
    @synchronized(crewUpdateDelegates)
    {
        for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
        {
            if ([delegate respondsToSelector:@selector(addedOldVideosAtIndexes:)])
            {
                [delegate addedOldVideosAtIndexes:oldVideoIndexes];
            }
            
            
        }
    }
}

- (void) notifyListenersThatMemebersAreAboutToBeLoaded
{
    for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(startingToLoadMembers)])
            [delegate startingToLoadMembers];
    }
}

- (void) notifyListenersThatMembersCountHasLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(finishedLoadingMembersCountWithSuccess:andError:)])
            [delegate finishedLoadingMembersCountWithSuccess:success andError:error];
    }
}

- (void) notifyListenersThatMembersHaveBeenAdded:(NSArray *) newMembersIndexes andMembersHaveBeenDeleted:(NSArray *) deletedMemberIndexes
{
    for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(addedNewMembersAtIndexes:andRemovedMembersAtIndexes:)])
            [delegate addedNewMembersAtIndexes:newMembersIndexes andRemovedMembersAtIndexes:deletedMemberIndexes];
    }
}

- (void) notifyListenersThatInvitesAreAboutToBeLoaded
{
    for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(startingToReloadAllInvites)])
            [delegate startingToReloadAllInvites];
    }    
}

- (void) notifyListenersThatInvitesHaveLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(finishedReloadingAllInvitesWithSucces:andError:)])
            [delegate finishedReloadingAllInvitesWithSucces:success andError:error];
    }
}

- (void) notifyListenersThatInvitesHaveBeenAddedAtIndexes:(NSArray *) newInviteIndexes andRemovedAtIndexes:(NSArray *) deletedInviteIndexes
{
    for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(addedNewInvitesAtIndexes:andRemovedInvitesAtIndexes:)])
            [delegate addedNewInvitesAtIndexes:newInviteIndexes andRemovedInvitesAtIndexes:deletedInviteIndexes];
    }
}

// Optional CCServerStoredObject methods
- (void) purgeRelatedDataInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    
}

// Required CCServerStoredObject methods
- (void)initialize
{
    isLoadingVideos = NO;
    isLoadingMembers = NO;
    isLoadingInvites = NO;
    isLoadingNumberOfUnwatchedVideos = NO;
    oldVideosLoaded = NO;
    numberOfOldVideos = 0;
    savedNumberOfVideosFromAutoCrews = -1;
    savedNumberOfMembersFromAutoCrews = -1;
    didAttemptToLoadThumbnail = NO;
    [self setCcVideos:[[NSMutableArray alloc] init]];
    [self setCcUsersThatAreMembers:[[NSMutableArray alloc] init]];
    [self setCcInvites:[[NSMutableArray alloc] init]];
    [self setCrewUpdateDelegates:[[NSMutableArray alloc] init]];        
}

- (void)dealloc
{
    for(id<CCVideo> video in ccVideos)
    {
        [video removeVideoUpdateListener:self];
    }
    
    videoBeingUploaded = nil;
    crewThumbnail = nil;
    
    [self setCcInvites:nil];
    [self setCcUsersThatAreMembers:nil];
    [self setCcVideos:nil];
    [self setCrewUpdateDelegates:nil];
}

// Required CCCrew methods

+ (void) createNewCrewInBackgroundWithName:(NSString *)name creator:(id<CCUser>)creator privacy:(CCSecuritySetting)privacySetting withBlock:(CCCrewResultBlock)block
{
    PFObject *newCrew = [PFObject objectWithClassName:@"Crew"];
    
    [newCrew setObject:name forKey:@"crewName"];
    
    [newCrew setObject:[NSNumber numberWithInt:privacySetting] forKey:@"securitySetting"];
    
    CCParseCrew *newCCCrew = [[CCParseCrew alloc] initWithServerData:newCrew];
    
    CCParseCrew *retainedPointerToTheNewCrewWhichIsToTheRight = newCCCrew;
    
    // Add member will push the object after setting the relation
    [newCCCrew addMemberInBackground:creator withBlockOrNil:^(BOOL succeeded, NSError *error) {
        if(!error)
        {
            [retainedPointerToTheNewCrewWhichIsToTheRight subscribeToNotifications];
            
            if(block)
                block(retainedPointerToTheNewCrewWhichIsToTheRight,YES,nil);
        }
        else
        {
            if (block)
                block(nil,NO,error);
        }
       
    }];    
}

+ (void) createNewSpecialAutoCrewInBackgroundWithName:(NSString *)name crewtype:(CCCrewType)type autoCrewId:(NSString *)crewId withBlock:(CCCrewResultBlock)block
{
    PFObject *newAutoCrew = [PFObject objectWithClassName:@"Crew"];
    
    [newAutoCrew setObject:name forKey:@"crewName"];
    
    [newAutoCrew setObject:[NSNumber numberWithInt:CCPrivate] forKey:@"securitySetting"];
    
    [newAutoCrew setObject:[NSNumber numberWithInt:type] forKey:@"crewType"];
    
    [newAutoCrew setObject:crewId forKey:@"autoCrewId"];
    
    CCParseCrew *newCCAutoCrew = [[CCParseCrew alloc] initWithServerData:newAutoCrew];
    
    [newCCAutoCrew pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        if (succeeded)
            block((id<CCCrew>)newAutoCrew,succeeded,error);
        else 
            block(nil,succeeded,error);
    }];
    
}

+ (void) loadSingleCrewInBackgroundWithObjectID:(NSString *)objectId andBlock:(CCCrewResultBlock)block
{
    PFQuery *crewQuery = [PFQuery queryWithClassName:@"Crew"];
    
    [crewQuery getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        id<CCCrew> crewObject;
        
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load single crew: %@", [error localizedDescription]];
        }
        
        if (!objectId)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Couldn't find crew matching ID %@", objectId];
        }
        else
        {
            crewObject = [[CCParseCrew alloc] initWithServerData:object];
        }
        
        block(crewObject, !error, error);
    }];
}

// Required CCCrew methods

- (void)sendNotificationWithMessage:(NSString*)message
{
    NSString *channelName = [[NSString alloc] initWithFormat:@"crew_%@", [self getObjectID]];
    [PFPush sendPushMessageToChannelInBackground:channelName
                                     withMessage:message block:^(BOOL succeeded, NSError *error) 
     {
         if(error)
         {
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to send notification to crew %d: %@", [self getObjectID], [error localizedDescription]];   
         }
         
     }];
}

- (void)sendNotificationWithData:(NSDictionary *)data
{
    PFPush *message = [[PFPush alloc] init];
    [message setChannel:[[NSString alloc] initWithFormat:@"crew_%@", [self getObjectID]]];
    [message setData:data];
    [message sendPushInBackground];    
}


- (BOOL) notificationReceivedWithData:(NSDictionary *)data
{
    if ([[data objectForKey:@"type"] intValue] == ccVideoPushNotification)
    {
        if ([[data objectForKey:@"ID"] isEqualToString:[self getObjectID]])
        {        
            [self pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    [self loadVideosInBackgroundWithBlockOrNil:nil startingAtIndex:0 forVideoCount:(oldVideosLoaded)
                     ? [ccVideos count] + 1 : 10];
                    
                    [self loadUnwatchedVideoCountInBackgroundWithBlockOrNil:nil];
                    
                    if ([self getCrewtype] == CCFBSchool || [self getCrewtype] == CCFBWork || [self getCrewtype] == CCFBLocation )
                    {
                        [self loadNumberOfVideosFromAutoCrewWithBlockOrNil:nil];
                    }
                }
            }];
            return true;
        }      
    }
    else if ([[data objectForKey:@"type"] intValue] == ccMemberPushNotification) 
    {
        if ([[data objectForKey:@"ID"] isEqualToString:[self getObjectID]])
        {
            [self pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    if ([self getCrewtype] == CCFBSchool || [self getCrewtype] == CCFBWork || [self getCrewtype] == CCFBLocation )
                    {                        
                        [self loadNumberOfMembersFromAutoCrewWithBlockOrNil:nil];           
                    }
                    else if ([self getCrewtype] == CCNormal  || [self getCrewtype] == CCDeveloper)
                    {
                        [self notifyListenersThatMembersCountHasLoadedWithSuccess:YES andError:nil];
                    }
                }
            }];
            return true;
        }
        
    }
    else if ([[data objectForKey:@"type"] intValue] == ccViewPushNotification || [[data objectForKey:@"type"] intValue] == ccCommentPushNotification) 
    {
        for (int videoIndex = 0; videoIndex < [[self ccVideos] count]; videoIndex++)
        {
            if ([(id<CCVideo>)[[self ccVideos] objectAtIndex:videoIndex] notificationReceivedWithData:data])
                return true;
        }
    }
        
    return false;
}

- (void)subscribeToNotifications
{
    NSString *channelName = [[NSString alloc] initWithFormat:@"crew_%@", [self getObjectID]];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{  
        @synchronized([[CCCoreManager sharedInstance] server])
        {
            NSError *error;
            
            [PFPush subscribeToChannel:channelName error:&error];
            if (error)
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to subscribe to crew channel: %@", [error localizedDescription]];
            }
        }
    });
}

- (void)unsubscribeToNotifications
{
    NSString *channelName = [[NSString alloc] initWithFormat:@"crew_%@", [self getObjectID]];
    [PFPush unsubscribeFromChannelInBackground:channelName block:^(BOOL succeeded, NSError *error)
     {
         if (error)
         {
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to unsubscribe to crew channel: %@", [error localizedDescription]];
         }
         else 
         {
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Unsubcribed from crew %@", [self getObjectID]];
         }
     }];
}

- (void) setName:(NSString *) name
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:name forKey:@"crewName"];
}

- (NSString *) getName
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"crewName"];
}

- (BOOL) isBusy
{
    return isObjectBusy || [self isUploadInProgress];
}

- (NSString *) getChannelName
{
    return [NSString stringWithFormat:@"crew_%@",[self getObjectID]];
}

- (BOOL) hasLoadedThumbnail
{
    return crewThumbnail != nil;
}

- (UIImage *) getCrewIcon
{
    switch ([self getCrewtype]) {
        case CCFBLocation:
            return [UIImage imageNamed:@"icon_Loc.png"];
        case CCFBSchool:
            return [UIImage imageNamed:@"icon_Edu.png"];
        case CCFBWork:
            return [UIImage imageNamed:@"icon_Work.png"];
        case CCNormal:
            return [UIImage imageNamed:@"icon_Default.png"];
        case CCDeveloper:
            return [UIImage imageNamed:@"CC_CrewcamCrew-01.png"];
        default:
            return nil;
            break;
    }
}

- (void) getCrewThumbnailInBackgroundWithBlock:(CCImageResultBlock)block
{
    if ([self getCrewtype] == CCDeveloper)
    {
        if (block)
            block([UIImage imageNamed:@"CC_CrewcamCrew-01.png"], nil);
        
        return;
    }    
    
    if (crewThumbnail)
    {
        if (block)
            block(crewThumbnail, nil);
    }
    else if (didAttemptToLoadThumbnail && [ccVideos count] == 0)
    {
        if (block)
            block(nil, nil);
    }
    else if ([ccVideos count] > 0)
    {
        id<CCVideo> video = [ccVideos objectAtIndex:0];            
        
        [video loadThumbnailInBackgroundWithBlockOrNil:^(UIImage *image, NSError *error) {
            
            if ([ccVideos count] > 0 && video == [ccVideos objectAtIndex:0])
            {
                crewThumbnail = image;
                
                if (block)
                    block(crewThumbnail, error);
            }
        }];
    }
    else
    {        
        // Load top video
        
        [self loadTopVideoInBackgroundWithBlockOrNil:^(id<CCVideo> video, BOOL succeeded, NSError *error) {
            if (!succeeded)
            {
                didAttemptToLoadThumbnail = YES;
                
                if (block)
                    block(nil, error); 
            }
            else 
            {
                [video loadThumbnailInBackgroundWithBlockOrNil:^(UIImage *image, NSError *error){
                    if (image)
                        crewThumbnail = image;
                    
                    if (block)
                        block(image, error);   
                }];
            }
        }];
    }
}

- (void) loadNumberOfVideosFromAutoCrewWithBlockOrNil:(CCBooleanResultBlock) block
{
    PFRelation *videosRelation = [[self parseObject] relationforKey:@"videos"];
    PFQuery *videosRelationsQuery = [videosRelation query];
    
    __block NSArray *CCFriends;
    [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            if (block)
                block(!error,error);
        }
        else 
        {
            CCFriends = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends];
            NSMutableArray *CCFriendsServerObjects = [[NSMutableArray alloc] initWithCapacity:[CCFriends count]];
            
            for (id<CCUser> friend in CCFriends)
            {
                [CCFriendsServerObjects addObject:[friend getServerData]];
            }
            
            [CCFriendsServerObjects addObject:[[[[CCCoreManager sharedInstance] server] currentUser] getServerData]];
            
            [videosRelationsQuery whereKey:@"theOwner" containedIn:CCFriendsServerObjects];
            
            [videosRelationsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                if (error)
                {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load count for videos: %@", [error localizedDescription]];
                }
                else 
                {
                    savedNumberOfVideosFromAutoCrews = number;
                }
                if (block)
                    block(!error,error);
            }];
        }
    }];
}

- (void) getNumberOfVideosWithBlock:(CCIntResultBlock) block andForced:(BOOL)forced
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    if ([self getCrewtype] == CCNormal || [self getCrewtype] == CCDeveloper)
    {
        block([[[self parseObject] objectForKey:@"videosCount"] integerValue],YES,nil);          
    }
    else if ([self getCrewtype] == CCFBSchool || [self getCrewtype] == CCFBWork || [self getCrewtype] == CCFBLocation ) 
    {
        if (savedNumberOfVideosFromAutoCrews > -1 && !forced)
        {
            block(savedNumberOfVideosFromAutoCrews,YES,nil);
        }
        else 
        {
            OSAtomicTestAndSet(YES, &isObjectBusy);
            
            [self loadNumberOfVideosFromAutoCrewWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                OSAtomicTestAndClear(YES, &isObjectBusy);
                block(savedNumberOfVideosFromAutoCrews,!error,error);
            }];
        }
    }
}

- (void) loadNumberOfMembersFromAutoCrewWithBlockOrNil:(CCBooleanResultBlock) block
{
    PFRelation *memberRelation = [[self parseObject] relationforKey:@"crewMembers"];
    PFQuery *memberRelationsQuery = [memberRelation query];
    
    __block NSArray *CCFriends;
    [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            if (block)
                block(!error,error);
        }
        else 
        {
            CCFriends = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends];
            NSMutableArray *CCFriendsServerObjectIds = [[NSMutableArray alloc] initWithCapacity:[CCFriends count]];
            
            for (id<CCUser> friend in CCFriends)
            {
                [CCFriendsServerObjectIds addObject:[friend getObjectID]];
            }
            
            [CCFriendsServerObjectIds addObject:[[[[CCCoreManager sharedInstance] server] currentUser] getObjectID]];
            
            [memberRelationsQuery whereKey:@"objectId" containedIn:CCFriendsServerObjectIds];
            
            [memberRelationsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                if (error)
                {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load count for members: %@", [error localizedDescription]];
                }
                else 
                {
                    savedNumberOfMembersFromAutoCrews = number;
                    [self notifyListenersThatMembersCountHasLoadedWithSuccess:YES andError:nil];
                }
                if (block)
                    block(!error,error);
            }];
        }
    }];
}

- (void) getNumberOfMembersWithBlock:(CCIntResultBlock) block andForced:(BOOL)forced
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    if ([self getCrewtype] == CCNormal || [self getCrewtype] == CCDeveloper)
    {
        block([[[self parseObject] objectForKey:@"membersCount"] integerValue],YES,nil);
    }
    else if ([self getCrewtype] == CCFBSchool || [self getCrewtype] == CCFBWork || [self getCrewtype] == CCFBLocation ) 
    {
        if (savedNumberOfMembersFromAutoCrews > -1 && !forced)
        {
            block(savedNumberOfMembersFromAutoCrews,YES,nil);
        }
        else 
        {
            OSAtomicTestAndSet(YES, &isObjectBusy);
            [self loadNumberOfMembersFromAutoCrewWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                OSAtomicTestAndClear(YES, &isObjectBusy);
                block(savedNumberOfMembersFromAutoCrews,!error,error);
            }];
        }
    }
}

- (void) setSecuritySetting:(CCSecuritySetting) securitySetting
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:[NSNumber numberWithInt:securitySetting] forKey:@"crewName"];
}

- (CCSecuritySetting) getSecuritySetting
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"securitySetting"] integerValue];
}

- (CCCrewType) getCrewtype
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"crewType"] integerValue];
}

- (NSString *) getAutoCrewId
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"autoCrewId"];
}

- (BOOL) isUploadInProgress
{
    for(id<CCVideo> video in ccVideos)
    {
        if ([video isUploading])
            return true;
    }
    
    return false;
}

- (void) loadTopVideoInBackgroundWithBlockOrNil:(CCVideoResultBlock) block
{
    if ([self isUploadInProgress])
        return;
    
    [self checkForParseDataAndThrowExceptionIfNil];
    
    PFRelation *videosRelation = [[self parseObject] relationforKey:@"videos"];
    PFQuery *videosRelationsQuery = [videosRelation query];
    [videosRelationsQuery includeKey:@"videoFileObject"];
    [videosRelationsQuery orderByDescending:@"createdAt"];
    
    
    if ([self getCrewtype] == CCFBSchool || [self getCrewtype] == CCFBWork || [self getCrewtype] == CCFBLocation )
    {
        __block NSArray *CCFriends;
        [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            CCFriends = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends];
            NSMutableArray *CCFriendsServerObjects = [[NSMutableArray alloc] initWithCapacity:[CCFriends count]];
            
            for (id<CCUser> friend in CCFriends)
            {
                [CCFriendsServerObjects addObject:[friend getServerData]];
            }
            
            [CCFriendsServerObjects addObject:[[[[CCCoreManager sharedInstance] server] currentUser] getServerData]];
            
            [videosRelationsQuery whereKey:@"theOwner" containedIn:CCFriendsServerObjects];
            
            [self loadTopVideoInBackgroundWithBlockOrNilInner:block forQuery:videosRelationsQuery];
            
        }];
        
    }
    else if ([self getCrewtype] == CCNormal || [self getCrewtype] == CCDeveloper)
    {
        [self loadTopVideoInBackgroundWithBlockOrNilInner:block forQuery:videosRelationsQuery];
    }

    
    
    
}

- (void) loadTopVideoInBackgroundWithBlockOrNilInner:(CCVideoResultBlock) block forQuery:(PFQuery *)videosRelationsQuery
{
    [videosRelationsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *videoObject, NSError *error) {
        id<CCVideo> topVideo;
        
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crew's top video for crew %@: %@", [self getObjectID], [error localizedDescription]]; 
        }
        else 
        {
            topVideo =  [[CCParseVideo alloc] initWithServerData:videoObject];

        } 
        
        if (block)
            block(topVideo,!error,error);
    }];
}


- (void) reloadVideosInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    [self loadVideosInBackgroundWithBlockOrNil:block startingAtIndex:0 forVideoCount:(oldVideosLoaded) ? [ccVideos count] : 10];
}

- (void) loadVideosInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block startingAtIndex:(NSInteger)index forVideoCount:(NSInteger)count
{    
    if (OSAtomicTestAndSetBarrier(1, &isLoadingVideos))        
        return;
    
    [self checkForParseDataAndThrowExceptionIfNil];
    
    PFRelation *videosRelation = [[self parseObject] relationforKey:@"videos"];
    PFQuery *videosRelationsQuery = [videosRelation query];
    [videosRelationsQuery orderByDescending:@"createdAt"];
    [videosRelationsQuery includeKey:@"theOwner"];
    [videosRelationsQuery includeKey:@"videoFileObject"];
    [videosRelationsQuery setLimit:count];
    [videosRelationsQuery setSkip:index];
    
    if ([self getCrewtype] == CCFBSchool || [self getCrewtype] == CCFBWork || [self getCrewtype] == CCFBLocation )
    {
        __block NSArray *CCFriends;
        [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            CCFriends = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends];
            NSMutableArray *CCFriendsServerObjects = [[NSMutableArray alloc] initWithCapacity:[CCFriends count]];
            
            for (id<CCUser> friend in CCFriends)
            {
                [CCFriendsServerObjects addObject:[friend getServerData]];
            }
            
            [CCFriendsServerObjects addObject:[[[[CCCoreManager sharedInstance] server] currentUser] getServerData]];
            
            [videosRelationsQuery whereKey:@"theOwner" containedIn:CCFriendsServerObjects];
            
            [self loadVideosInBackgroundWithBlockOrNilInner:block startingAtIndex:index forVideoCount:count forQuery:videosRelationsQuery];
        }];
        
    }
    else if ([self getCrewtype] == CCNormal || [self getCrewtype] == CCDeveloper)
    {
        [self loadVideosInBackgroundWithBlockOrNilInner:block startingAtIndex:index forVideoCount:count forQuery:videosRelationsQuery];
    }
    
    
}

- (void) loadVideosInBackgroundWithBlockOrNilInner:(CCBooleanResultBlock) block startingAtIndex:(NSInteger)index forVideoCount:(NSInteger)count forQuery:(PFQuery *)videosRelationsQuery
{
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    [self notifyListenersThatVideosAreAboutToBeLoaded];
    
    @try 
    {
        [videosRelationsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
         {
             NSMutableArray *mutableObjects = [[NSMutableArray alloc] initWithArray:objects];
             if (error)
             {
                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crew's videos for crew %@: %@", [self getObjectID], [error localizedDescription]];                    
                 
                 OSAtomicTestAndClear(YES, &isObjectBusy);
                 OSAtomicTestAndClearBarrier(1, &isLoadingVideos);  
                 
                 if (block)
                     block((error == nil ? YES : NO), error);
                 
                 [self notifyListenersThatVideosHaveLoadedWithSuccess:(error == nil ? YES : NO) andError:error];
             }
             else 
             {
                 @try 
                 {
                     // Iterate through all the videos, create an array of pointers to users, and fetch all their data
                     NSMutableArray *pfUsersToBeFetched = [[NSMutableArray alloc] initWithCapacity:[objects count]];
                     
                     int numberOfRemovedVideos = 0;
                     for (int videoObjectIndex = 0; videoObjectIndex < [objects count]; videoObjectIndex++)
                     {
                         if ([[objects objectAtIndex:videoObjectIndex] objectForKey:@"theOwner"] != nil) 
                         {
                             [pfUsersToBeFetched addObject:[[objects objectAtIndex:videoObjectIndex] objectForKey:@"theOwner"]];
                         }
                         else {       
                             [[mutableObjects objectAtIndex:videoObjectIndex - numberOfRemovedVideos] deleteInBackground];
                             [mutableObjects removeObjectAtIndex:videoObjectIndex - numberOfRemovedVideos];
                             numberOfRemovedVideos++;
                             [[self parseObject] incrementKey:@"videosCount" byAmount:[NSNumber numberWithInt: -1]];
                         }
                         
                     }
                     
                     if (numberOfRemovedVideos > 0) {
                         [self pushObjectWithBlockOrNil:nil];
                     }
                     
                     [PFObject fetchAllIfNeededInBackground:pfUsersToBeFetched block:^(NSArray *userObjects, NSError *error) 
                      {
                          OSAtomicTestAndClear(YES, &isObjectBusy);
                          OSAtomicTestAndClearBarrier(1, &isLoadingVideos);  
                          @try 
                          {
                              if (error)
                              {
                                  [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crew's videos for crew %@: %@", [self getObjectID], [error localizedDescription]];                    
                              }
                              else
                              {
                                  if (index == 0)
                                      [self handleNewVideos:mutableObjects];
                                  else 
                                      [self handleOldVideos:mutableObjects];
                              }
                              
                              if (block)
                                  block((error == nil ? YES : NO), error);
                              
                              [self notifyListenersThatVideosHaveLoadedWithSuccess:(error == nil ? YES : NO) andError:error];  
                          }
                          @catch (NSException *exception) 
                          {
                              [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error loading videos"];
                          }                                         
                      }];
                 }
                 @catch (NSException *exception) 
                 {
                     OSAtomicTestAndClear(YES, &isObjectBusy);
                     OSAtomicTestAndClearBarrier(1, &isLoadingVideos);  
                     [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error loading videos"];
                 }  
             }     
         }];
    }
    @catch (NSException *exception) 
    {
        OSAtomicTestAndClear(YES, &isObjectBusy);
        OSAtomicTestAndClearBarrier(1, &isLoadingVideos);  
        [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error loading videos"];
    }
}

- (void) handleNewVideos:(NSArray *) pfObjects
{
    NSMutableArray *allVideos       = [[NSMutableArray alloc] init];
    NSMutableArray *newVideoIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *removedVideoIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *uploadingVideos = [[NSMutableArray alloc] init];
    
    for(PFObject *pfObject in pfObjects)
    {
        [allVideos addObject:[[CCParseVideo alloc] initWithServerData:pfObject]];
    }
    
    for (id<CCVideo> video in ccVideos)
    {
        if ([video isUploading])
        {
            [uploadingVideos addObject:video];
        }
    }
    
    [self handleNewCCObjects:allVideos removedObjectIndexes:removedVideoIndexes addedObjectIndexes:newVideoIndexes finalArrayOfObjects:ccVideos];
    
    for (int ccVideosIndex = 0; ccVideosIndex < [uploadingVideos count]; ccVideosIndex++)
    {
        [newVideoIndexes addObject:[NSIndexPath indexPathForRow:[ccVideos count] inSection:0]];
        [ccVideos insertObject:[uploadingVideos objectAtIndex:ccVideosIndex] atIndex:ccVideosIndex];
        
    }
    
    [self subscribeToNewVideoNotificationsAtIndexes:newVideoIndexes];
    
    if ([newVideoIndexes count] > 0)
    {
        crewThumbnail = nil;
    }
    
    if ([removedVideoIndexes count] > 0 || [newVideoIndexes count] > 0)
        [self notifyListenersThatVideosHaveBeenAdded:newVideoIndexes andVideosHaveBeenRemoved:removedVideoIndexes];
}

- (void) subscribeToNewVideoNotificationsAtIndexes:(NSArray *)newVideoIndexes
{
    for (NSIndexPath *newVideoIndex in newVideoIndexes) 
    {
        [[ccVideos objectAtIndex:[newVideoIndex row]] addVideoUpdateListener:self];
    }
}

- (void) handleOldVideos:(NSArray *) pfObjects
{
    NSMutableArray *oldVideos       = [[NSMutableArray alloc] init];
    NSMutableArray *oldVideoIndexes = [[NSMutableArray alloc] init];
    
    for(PFObject *pfObject in pfObjects)
    {
        [oldVideos addObject:[[CCParseVideo alloc] initWithServerData:pfObject]];
    }
    
    for (int objectIndex = 0; objectIndex < [oldVideos count]; objectIndex++)
    {
        [oldVideoIndexes addObject:[NSIndexPath indexPathForRow:(objectIndex + [ccVideos count])  inSection:0]];
    }
    
    numberOfOldVideos += [oldVideoIndexes count];
    [ccVideos addObjectsFromArray:oldVideos];
    
    [self subscribeToNewVideoNotificationsAtIndexes:oldVideoIndexes];
    
    [self notifyListenersThatOldVideosHaveBeenAdded:oldVideoIndexes];
}

- (void) addVideoLocally:(id<CCVideo>) newVideo
{
    [self addVideo:newVideo];
}

- (void) addVideo:(id<CCVideo>) newVideo
{
    if (![CCParseObject isObjectInArray:newVideo arrayOfCCServerStoredObjects:ccVideos])
    {
        crewThumbnail = nil;
        
        // If this video is being uploaded, we want to keep track of it
        if ([newVideo isUploading])
        {
            videoBeingUploaded = newVideo;
            [videoBeingUploaded addVideoUpdateListener:self];
        }
        
        [ccVideos insertObject:newVideo atIndex:0];
        
        [self notifyListenersThatVideosHaveBeenAdded:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] andVideosHaveBeenRemoved:nil];
    }
}

- (void) finishedUploadingVideoWithSuccess:(BOOL)successful error:(NSError *)error andVideoReference:(id<CCVideo>)video
{
    // Remove the locally added video
    if (successful)
    {        
        // Add the actual relation
        [self addVideoInBackground:video withBlockOrNil:nil];

        savedNumberOfVideosFromAutoCrews++;
    }
    else
    {
        // Remove the video from the array, and notify people
        int indexForVideo = [ccVideos indexOfObject:video];
        [ccVideos removeObject:video];
        [self notifyListenersThatVideosHaveBeenAdded:nil andVideosHaveBeenRemoved:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexForVideo inSection:0], nil]];
    }

    videoBeingUploaded = nil;
}

- (void) finishedDeletingVideoWithSuccess:(BOOL) successful error:(NSError *)error andVideoReference:(id<CCVideo>)video
{
    if (successful) 
    {
        [self removeVideoInBackground:video withBlockOrNil:^(BOOL succeeded, NSError *error) {
            if (!succeeded)
            {   
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed to find video in crew for Delete %@"];
            }
                
        }];
    }
}

// (Note that this function assumes the video has been uploaded, we're just adding the relation
- (void) addVideoInBackground:(id<CCVideo>) video withBlockOrNil:(CCBooleanResultBlock) block
{
    PFObject *videoObject = [PFUser objectWithoutDataWithClassName:@"Video" objectId:[video getObjectID]];
    
    PFRelation *videoRelation = [[self parseObject] relationforKey:@"videos"];
    
    [videoRelation addObject:videoObject];
    [[self parseObject] incrementKey:@"videosCount"];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Add the relationship to the existing object
    @try 
    {
        [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
         {   
             if (error)
                 [[self parseObject] incrementKey:@"videosCount" byAmount:[NSNumber numberWithInt: -1]];
             else 
             {
                 [self notifyListenersThatVideosHaveLoadedWithSuccess:YES andError:nil];
             }
             
             OSAtomicTestAndClear(YES, &isObjectBusy);
             
             if (block)
                 block(succeeded, error);
         }];
    }
    @catch (NSException *exception) 
    {
        [[self parseObject] incrementKey:@"videosCount" byAmount:[NSNumber numberWithInt: -1]];
        
        OSAtomicTestAndClear(YES, &isObjectBusy);
        [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error adding video"];
    }    
}

- (void) removeVideoInBackground:(id<CCVideo>) video withBlockOrNil:(CCBooleanResultBlock) block
{
    [[self parseObject] incrementKey:@"videosCount" byAmount:[NSNumber numberWithInt: -1]];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Add the relationship to the existing object
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
     {
         if (!error)
         {
             int indexOfVideo = [[self ccVideos] indexOfObject:video];
             [[self ccVideos] removeObject:video];
             crewThumbnail = nil;
             savedNumberOfVideosFromAutoCrews--;
             [self notifyListenersThatVideosHaveBeenAdded:nil andVideosHaveBeenRemoved:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexOfVideo inSection:0], nil]]; 
                       
             NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          [[[[CCCoreManager sharedInstance] server] currentUser ] getObjectID], @"src_User",
                                                          [NSNumber numberWithInt:ccVideoPushNotification], @"type",
                                                          [self getObjectID], @"ID",
                                                          nil];
             
             for (id<CCUser> user in [self ccUsersThatAreMembers])
             {
                 // Send the push notification
                 [user sendNotificationWithData:messageData];
             }
         }  
         else
             [[self parseObject] incrementKey:@"videosCount"];
         
         OSAtomicTestAndClear(YES, &isObjectBusy);
         
         if (block)
             block(succeeded, error);        
     }];
}

- (void) loadUnwatchedVideoCountInBackgroundWithBlockOrNil:(CCIntResultBlock) block
{
    OSAtomicTestAndSet(YES, &isObjectBusy);
    if (OSAtomicTestAndSet(YES, &isLoadingNumberOfUnwatchedVideos))
        return;
    
    PFRelation *videosInCrewRelation = [[self parseObject] relationforKey:@"videos"];
    
    PFQuery *videosQuery = [videosInCrewRelation query];
    
    [videosQuery whereKey:@"viewedBy" notEqualTo:[[[[CCCoreManager sharedInstance] server] currentUser] getServerData]];
    
    if ([self getCrewtype] == CCFBSchool || [self getCrewtype] == CCFBWork || [self getCrewtype] == CCFBLocation )
    {
        __block NSArray *CCFriends;
        [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            CCFriends = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends];
            NSMutableArray *CCFriendsServerObjects = [[NSMutableArray alloc] initWithCapacity:[CCFriends count]];
            
            for (id<CCUser> friend in CCFriends)
            {
                [CCFriendsServerObjects addObject:[friend getServerData]];
            }
            
            [videosQuery whereKey:@"theOwner" containedIn:CCFriendsServerObjects];
            
            [self loadUnwatchedVideoCountInBackgroundWithBlockOrNilInner:block forQuery:videosQuery];
        }];
        
    }
    else if ([self getCrewtype] == CCNormal || [self getCrewtype] == CCDeveloper)
    {
        [videosQuery whereKey: @"theOwner" notEqualTo:[[[[CCCoreManager sharedInstance] server] currentUser] getServerData]];
        [self loadUnwatchedVideoCountInBackgroundWithBlockOrNilInner:block forQuery:videosQuery];
    }
    
    
}

- (void) loadUnwatchedVideoCountInBackgroundWithBlockOrNilInner:(CCIntResultBlock) block forQuery:(PFQuery *)videosQuery
{
    [videosQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) 
     {
         OSAtomicTestAndClear(YES, &isObjectBusy);
         OSAtomicTestAndClear(YES, &isLoadingNumberOfUnwatchedVideos);
         numberOfNewVideos = number;
         if (error)
         {
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load number of unwatched videos: %@", [error localizedDescription]];
             
             [self notifyListenersThatNumberOfNewVideosHasBeenLoaded:0];
             if (block)
                 block(0, NO, error);           
         }
         else 
         {
             [self notifyListenersThatNumberOfNewVideosHasBeenLoaded:numberOfNewVideos];
             if (block)
                 block(numberOfNewVideos, YES, nil);
         }
     }];

}

- (void) loadMembersInBackgroundWithBlock:(CCBooleanResultBlock) block
{
    if (OSAtomicTestAndSetBarrier(1, &isLoadingMembers))        
        return;
    
    [self checkForParseDataAndThrowExceptionIfNil];

    PFRelation *membersRelation = [[self parseObject] relationforKey:@"crewMembers"];
    PFQuery *membersRelationQuery = [membersRelation query];
    [membersRelationQuery orderByAscending:@"firstName"];
    [membersRelationQuery addAscendingOrder:@"lastName"];
    
    if ([self getCrewtype] == CCFBSchool || [self getCrewtype] == CCFBWork || [self getCrewtype] == CCFBLocation )
    {
        __block NSArray *CCFriends;
        [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            CCFriends = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends];
            NSMutableArray *CCFriendsServerObjectIds = [[NSMutableArray alloc] initWithCapacity:[CCFriends count]];
            
            for (id<CCUser> friend in CCFriends)
            {
                [CCFriendsServerObjectIds addObject:[friend getObjectID]];
            }
            
            [CCFriendsServerObjectIds addObject:[[[[CCCoreManager sharedInstance] server] currentUser] getObjectID]];
            
            [membersRelationQuery whereKey:@"objectId" containedIn:CCFriendsServerObjectIds];
            
            [self loadMembersInBackgroundWithBlockInner:block forQuery:membersRelationQuery];
        }];
    }
    else if ([self getCrewtype] == CCNormal || [self getCrewtype] == CCDeveloper)
    {
         [self loadMembersInBackgroundWithBlockInner:block forQuery:membersRelationQuery];
    }
}


- (void) loadMembersInBackgroundWithBlockInner:(CCBooleanResultBlock) block forQuery:(PFQuery *)membersRelationQuery
{
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    [self notifyListenersThatMemebersAreAboutToBeLoaded];
    
    @try 
    {
        [membersRelationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
         {
             OSAtomicTestAndClear(YES, &isObjectBusy);
             OSAtomicTestAndClearBarrier(1, &isLoadingMembers);   
             @try 
             {
                 if (error)
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crew's members for crew %@: %@", [self getObjectID], [error localizedDescription]];                    
                 }
                 else 
                 {
                     [self handleNewMembers:objects];
                 }
                 if (block)
                     block((error == nil ? YES : NO), error);
                 
                 [self notifyListenersThatMembersCountHasLoadedWithSuccess:(error == nil ? YES : NO) andError:error];
             }
             @catch (NSException *exception) 
             {
                 [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error loading members"];
             }             
         }];
    }
    @catch (NSException *exception) 
    {
        OSAtomicTestAndClear(YES, &isObjectBusy);
        OSAtomicTestAndClearBarrier(1, &isLoadingMembers);   
        [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error loading members"];
    }
}

- (BOOL) loadMembers
{
    NSCondition *isLoadComplete = [[NSCondition alloc] init];
    __block BOOL wasLoadSuccesfull;
    
    [self loadMembersInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        wasLoadSuccesfull =  succeeded;
        [isLoadComplete signal];
    }];
    [isLoadComplete lock];
    [isLoadComplete wait];
    [isLoadComplete unlock];
    
    return wasLoadSuccesfull;
}

- (void) handleNewMembers:(NSArray *) pfObjects
{
    NSMutableArray *allMembers = [[NSMutableArray alloc] init];
    NSMutableArray *newMembersIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *oldMemberIndexes = [[NSMutableArray alloc] init];    
    
    for(PFObject *pfObject in pfObjects)
    {
        [allMembers addObject:[[CCParseUser alloc] initWithServerData:pfObject]];
    }
    
    [self handleNewCCObjects:allMembers removedObjectIndexes:oldMemberIndexes addedObjectIndexes:newMembersIndexes finalArrayOfObjects:ccUsersThatAreMembers];
    
    @synchronized([self parseObject])
    {
        [[self parseObject] setObject:[NSNumber numberWithInt:[ccUsersThatAreMembers count]] forKey:@"membersCount"];
    }
    
    if ([newMembersIndexes count] > 0 || [oldMemberIndexes count] > 0)
        [self notifyListenersThatMembersHaveBeenAdded:newMembersIndexes andMembersHaveBeenDeleted:oldMemberIndexes];
    
}

// (Note that this function assumes the user has been uploaded, we're just adding the relation
- (void) addMemberInBackground:(id<CCUser>) user withBlockOrNil:(CCBooleanResultBlock) block
{
    PFObject *memberObject = [PFUser objectWithoutDataWithClassName:@"_User" objectId:[user getObjectID]];
    
    PFRelation *memberRelation = [[self parseObject] relationforKey:@"crewMembers"];
    
    [memberRelation addObject:memberObject];
    [[self parseObject] incrementKey:@"membersCount"];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Add the relationship to the existing object
    @try 
    {
        [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
         {
             if (!error)
             {
                 @try 
                 {
                     [self pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
                      {
                          if (!error)
                          {
                              [[self ccUsersThatAreMembers] insertObject:user atIndex:0];                                                               
                              [user addUserToCrewLocally:self];
                                
                              [self loadMembersInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                 
                                  if(!error)
                                  {
                                      NSDictionary *messageDataForMemberUpdate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                  [[[[CCCoreManager sharedInstance] server] currentUser ] getObjectID], @"src_User",
                                                                                  [NSNumber numberWithInt:ccMemberPushNotification], @"type",
                                                                                  [self getObjectID], @"ID",
                                                                                  nil];

// The below commented out code is part of Gamification... saving for a later release.
//                                      [[[[CCCoreManager sharedInstance] server] currentUser] creatUserCrewInfoObjectWithCrewInBackground:self block:^(BOOL succeeded, NSError *error) {
//                                          if (error)
//                                          {
//                                              [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error creating user's crew info for this crew"];
//                                          }
//                                      }];
                                      
                                      for (id<CCUser> user in [self ccUsersThatAreMembers])
                                      {
                                          // Send the push notification
                                          [user sendNotificationWithData:messageDataForMemberUpdate];
                                      }
                                  }
                                  
                              }];
                          }
                          else
                          {                     
                              [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error pushing new crew. ObjectID: %@ Error: %@",[self getObjectID],[error localizedDescription]];
                          }
                          
                          OSAtomicTestAndClear(YES, &isObjectBusy);
                          
                          if (block)
                              block(succeeded,error);
                      }];
                 }
                 @catch (NSException *exception) 
                 {
                     OSAtomicTestAndClear(YES, &isObjectBusy);
                     [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error addding member"];
                 }                   
             }
             else
             {      

                [[self parseObject] incrementKey:@"membersCount" byAmount:[NSNumber numberWithInt: -1]];
                 
                 OSAtomicTestAndClear(YES, &isObjectBusy);
                 
                 if (block)
                     block(NO,error);
                 
                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error pulling new crew. ObjectID: %@ Error: %@",[self getObjectID],[error localizedDescription]];
             }
         }];
    }
    @catch (NSException *exception) 
    {
        [[self parseObject] incrementKey:@"membersCount" byAmount:[NSNumber numberWithInt: -1]];
        
        OSAtomicTestAndClear(YES, &isObjectBusy);
        
        [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error addding member"];
    }    
}                

- (void) removeMemberInBackground:(id<CCUser>) user withBlockOrNil:(CCBooleanResultBlock) block
{
    PFObject *memberObject = [PFUser objectWithoutDataWithClassName:@"_User" objectId:[user getObjectID]];
    
    PFRelation *memberRelation = [[self parseObject] relationforKey:@"crewMembers"];
    
    [memberRelation removeObject:memberObject];
    [[self parseObject] incrementKey:@"membersCount" byAmount:[NSNumber numberWithInt: -1]];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Add the relationship to the existing object
    @try 
    {
        [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
         {         
             if (!error)
             {
                 [self unsubscribeToNotifications];
             } 
             else
             {
                 [[self parseObject] incrementKey:@"membersCount"];
             }
             
             OSAtomicTestAndClear(YES, &isObjectBusy);
             
             if (block)
                 block(succeeded, error);
         }];
    }
    @catch (NSException *exception) 
    {
        [[self parseObject] incrementKey:@"membersCount"];
        OSAtomicTestAndClear(YES, &isObjectBusy);
        [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error removing member"];
    } 
    
}

- (void) loadInvitesInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{ 
    if (OSAtomicTestAndSetBarrier(YES, &isLoadingInvites))
        return;
    
    [self checkForParseDataAndThrowExceptionIfNil];
    PFQuery *invitesQuery = [PFQuery queryWithClassName:@"Invite"];
    [invitesQuery whereKey:@"crewInvitedTo" equalTo:[self parseObject]];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    @try {
        [invitesQuery findObjectsInBackgroundWithBlock:^(NSArray *invites, NSError *error) 
        {
            OSAtomicTestAndClear(YES, &isObjectBusy);
            OSAtomicTestAndClearBarrier(1, &isLoadingInvites); 
            
            if (error)
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crew's invites for crew %@: %@", [self getObjectID], [error localizedDescription]];                    
            }
            else 
            {
                @try 
                {
                    [self handleNewInvites:invites];
                }
                @catch (NSException *exception) 
                {
                    [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error loading invites"];
                } 
                
            }
                        
            if (block)
                block((error == nil ? YES : NO), error);
        }];
    }
    @catch (NSException *exception) 
    {
        [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error loading invites"];
    } 
    
}

- (void) handleNewInvites:(NSArray *) pfObjects
{
    NSMutableArray *allInvites       = [[NSMutableArray alloc] init];
    NSMutableArray *newInviteIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *removedInviteIndexes = [[NSMutableArray alloc] init];
    
    for(PFObject *pfObject in pfObjects)
    {
        [allInvites addObject:[[CCParseInvite alloc] initWithServerData:pfObject]];
    }
    
    [self handleNewCCObjects:allInvites removedObjectIndexes:removedInviteIndexes addedObjectIndexes:newInviteIndexes finalArrayOfObjects:ccInvites];
    
     if ([removedInviteIndexes count] > 0 || [newInviteIndexes count] > 0)
        [self notifyListenersThatInvitesHaveBeenAddedAtIndexes:newInviteIndexes andRemovedAtIndexes:removedInviteIndexes];
}

// Utility methods
- (Boolean)containsMember:(id<CCUser>)user 
{    
    return [CCParseObject isObjectInArray:user arrayOfCCServerStoredObjects:ccUsersThatAreMembers];
}

- (Boolean)memberInvited:(id<CCUser>) user
{
    for (id<CCInvite> invite in [self ccInvites])
    {
        if ([[[invite getUserInvited] getObjectID] isEqualToString:[user getObjectID]])
            return YES;
    }
    
    return NO;
}

- (NSArray *)getFriendsNotInCrewFromList:(NSArray *)peopleThatAreFriends
{
    NSMutableArray *friendsNotInCrew = [[NSMutableArray alloc] init];
    
    for(int friendIndex = 0; friendIndex < [peopleThatAreFriends count]; friendIndex++)
    {
        id<CCUser> thisFriend = [peopleThatAreFriends objectAtIndex:friendIndex];
        if (![self containsMember:thisFriend] && ![self memberInvited:thisFriend])
        {            
            [friendsNotInCrew addObject:[peopleThatAreFriends objectAtIndex:friendIndex]];             
        }
    }
    
    return friendsNotInCrew;
}

@synthesize crewUpdateDelegates;

- (void) addCrewUpdateListener:(id<CCCrewUpdatesDelegate>) delegate
{
    @synchronized(crewUpdateDelegates)
    {
        if (![crewUpdateDelegates containsObject:delegate])
            [crewUpdateDelegates addObject:delegate];
    }
}

- (void) removeCrewUpdateListener:(id<CCCrewUpdatesDelegate>) delegate
{
    @synchronized(crewUpdateDelegates)
    {    
        if ([crewUpdateDelegates containsObject:delegate])
            [crewUpdateDelegates removeObject:delegate];
    }
}

@end
