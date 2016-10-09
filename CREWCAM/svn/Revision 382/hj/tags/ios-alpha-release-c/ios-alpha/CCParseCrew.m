//
//  CCParseCrew.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseCrew.h"

@implementation CCParseCrew

static NSString *className = @"Crew";

// CCCrew properties
@synthesize ccVideos;
@synthesize numberOfNewVideos;
@synthesize ccUsersThatAreMembers;
@synthesize ccInvites;

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

- (void) notifyListenersThatMembersHaveLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    for (id<CCCrewUpdatesDelegate> delegate in crewUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(finishedLoadingMembersWithSuccess:andError:)])
            [delegate finishedLoadingMembersWithSuccess:success andError:error];
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
    [self setCcVideos:[[NSMutableArray alloc] init]];
    [self setCcUsersThatAreMembers:[[NSMutableArray alloc] init]];
    [self setCcInvites:[[NSMutableArray alloc] init]];
    [self setCrewUpdateDelegates:[[NSMutableArray alloc] init]];        
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
    if ([[data objectForKey:@"type"] intValue] == CCVideoPush)
    {
        if ([[data objectForKey:@"ID"] isEqualToString:[self getObjectID]])
        {        
            [self loadVideosInBackgroundWithBlockOrNil:nil startingAtIndex:0
             forVideoCount:[[self ccVideos] count]];
            [self pullObjectWithBlockOrNil:nil];
            [self setNumberOfNewVideos:numberOfNewVideos++];
            return true;
        }      
    }
    else  if ([[data objectForKey:@"type"] intValue] == CCViewPush || [[data objectForKey:@"type"] intValue] == CCCommentPush) 
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

- (NSString *) getChannelName
{
    return [NSString stringWithFormat:@"crew_%@",[self getObjectID]];
}

- (NSInteger) getNumberOfVideos
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"videosCount"] integerValue];
}

- (NSInteger) getNumberOfMembers
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"membersCount"] integerValue];    
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

- (BOOL) isUploadInProgress
{
    for(id<CCVideo> video in ccVideos)
    {
        if ([video isUploading])
            return true;
    }
    
    return false;
}

- (void) loadVideosInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block startingAtIndex:(NSInteger)index forVideoCount:(NSInteger)count
{    
    if ([self isUploadInProgress])
        return;

    if (OSAtomicTestAndSetBarrier(1, &isLoadingVideos))        
        return;
    
    [self checkForParseDataAndThrowExceptionIfNil];
    
    // Remove any videos that were added "locally"
    for(int videoIndex = 0; videoIndex < [ccVideos count]; videoIndex++)
    {
        if ([[ccVideos objectAtIndex:videoIndex] wasVideoAddedLocally])
        {
            [ccVideos removeObjectAtIndex:videoIndex];
            [self notifyListenersThatVideosHaveBeenAdded:nil andVideosHaveBeenRemoved:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:videoIndex inSection:0], nil]];
            videoIndex--;
        }            
    }
    
    PFRelation *videosRelation = [[self parseObject] relationforKey:@"videos"];
    PFQuery *videosRelationsQuery = [videosRelation query];
    [videosRelationsQuery orderByDescending:@"createdAt"];
    [videosRelationsQuery includeKey:@"theOwner"];
    [videosRelationsQuery setLimit:count];
    [videosRelationsQuery setSkip:index];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    [self notifyListenersThatVideosAreAboutToBeLoaded];
    
    @try 
    {
        [videosRelationsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
         {
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
                     
                     for (PFObject *videoObject in objects)
                     {
                         [pfUsersToBeFetched addObject:[videoObject objectForKey:@"theOwner"]];
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
                                      [self handleNewVideos:objects];
                                  else 
                                      [self handleOldVideos:objects];
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
    BOOL redundantVideoCounts = NO;
    
    for(PFObject *pfObject in pfObjects)
    {
        [allVideos addObject:[[CCParseVideo alloc] initWithServerData:pfObject]];
    }
    
    if ([ccVideos count] == 0 && [self getNumberOfVideos] > 0)
        redundantVideoCounts = YES;
        
    [self handleNewCCObjects:allVideos removedObjectIndexes:removedVideoIndexes addedObjectIndexes:newVideoIndexes finalArrayOfObjects:ccVideos];
    
    // Update the local videos count
    @synchronized([self parseObject])
    {
        if (!redundantVideoCounts)
            [[self parseObject] setObject:[NSNumber numberWithInt:([self getNumberOfVideos] + [newVideoIndexes count] - [removedVideoIndexes count])] forKey:@"videosCount"];
    }    

    if ([removedVideoIndexes count] > 0 || [newVideoIndexes count] > 0)
        [self notifyListenersThatVideosHaveBeenAdded:newVideoIndexes andVideosHaveBeenRemoved:removedVideoIndexes];
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
    
    [ccVideos addObjectsFromArray:oldVideos];
    
    [self notifyListenersThatOldVideosHaveBeenAdded:oldVideoIndexes];
}

- (void) addVideoLocally:(id<CCVideo>) newVideo
{
    if (![CCParseObject isObjectInArray:newVideo arrayOfCCServerStoredObjects:ccVideos])
    {
        [ccVideos insertObject:newVideo atIndex:0];
        [self notifyListenersThatVideosHaveBeenAdded:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] andVideosHaveBeenRemoved:nil];
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
             if (!error)
             {            
                 NSString *newVideoMessage = [[NSString alloc] initWithFormat:@"%@ added a new video to the crew \"%@\"!", 
                                              [[[[CCCoreManager sharedInstance] server] currentUser ]getName], [self getName] ];
                 
                 NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:newVideoMessage, @"alert",
                                              [NSNumber numberWithInt:1], @"badge",
                                              [[[[CCCoreManager sharedInstance] server] currentUser ]getObjectID], @"src_User",
                                              [NSNumber numberWithInt:CCVideoPush], @"type",
                                              [self getObjectID], @"ID",
                                              nil];
                 
                 [self sendNotificationWithData:messageData];
             }                
             
             OSAtomicTestAndClear(YES, &isObjectBusy);
             
             if (block)
                 block(succeeded, error);
         }];
    }
    @catch (NSException *exception) 
    {
        OSAtomicTestAndClear(YES, &isObjectBusy);
        [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error adding video"];
    }    
}

- (void) removeVideoInBackground:(id<CCVideo>) video withBlockOrNil:(CCBooleanResultBlock) block
{
    PFObject *videoObject = [PFUser objectWithoutDataWithClassName:@"Video" objectId:[video getObjectID]];
    
    PFRelation *videoRelation = [[self parseObject] relationforKey:@"videos"];
    
    [videoRelation removeObject:videoObject];
    [[self parseObject] incrementKey:@"videosCount" byAmount:[NSNumber numberWithInt: -1]];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Add the relationship to the existing object
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
     {
         if (!error)
         {
             [[self ccVideos] removeObject:video];
             [self notifyListenersThatVideosHaveBeenAdded:nil andVideosHaveBeenRemoved:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:[[self ccVideos] indexOfObject:video] inSection:0], nil]];              
         }    
         
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
    [videosQuery whereKey:@"viewedBy" equalTo:[[[[CCCoreManager sharedInstance] server] currentUser] getServerData]];
    
    [videosQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) 
    {
        OSAtomicTestAndClear(YES, &isObjectBusy);
        OSAtomicTestAndClear(YES, &isLoadingNumberOfUnwatchedVideos);
        numberOfNewVideos = [self getNumberOfVideos] - number;
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
    [membersRelationQuery orderByDescending:@"createdAt"];
    
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
                 
                 [self notifyListenersThatMembersHaveLoadedWithSuccess:(error == nil ? YES : NO) andError:error];
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
                     [self handleExceptionThrown:exception withBlockOrNil:block andMessage:@"Error addding member"];
                 }                   
             }
             else
             {             
                 OSAtomicTestAndClear(YES, &isObjectBusy);
                 
                 if (block)
                     block(NO,error);
                 
                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error pulling new crew. ObjectID: %@ Error: %@",[self getObjectID],[error localizedDescription]];
             }
         }];
    }
    @catch (NSException *exception) 
    {
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
             
             OSAtomicTestAndClear(YES, &isObjectBusy);
             
             if (block)
                 block(succeeded, error);
         }];
    }
    @catch (NSException *exception) 
    {
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

- (Boolean)memberInvited:(id<CCUser>)user
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
        CCBasePerson *thisFriend = [peopleThatAreFriends objectAtIndex:friendIndex];
        if (![self containsMember:[thisFriend ccUser]] && ![self memberInvited:[thisFriend ccUser]])
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
