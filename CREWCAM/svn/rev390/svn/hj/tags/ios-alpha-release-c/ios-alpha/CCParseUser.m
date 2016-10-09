//
//  CCParseUser.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseUser.h"

@implementation CCParseUser

static NSString *className = @"_User";

// CCUser properties
@synthesize ccCrews;
@synthesize ccInvites;
@synthesize userImageData;

// CCParseUser helper methods
- (void) notifyListenersThatCrewsAreAboutToBeLoaded
{
    [userUpdateDelegatesLock lock];
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(startingToReloadAllCrews)])
            [delegate startingToReloadAllCrews];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatCrewsHaveLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    [userUpdateDelegatesLock lock];
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(finishedLoadingAllCrewsWithSuccess:andError:)])
            [delegate finishedLoadingAllCrewsWithSuccess:success andError:error];
    }    
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatCrewsHaveBeenAdded:(NSArray *) newCrewIndexes andCrewsHaveBeenRemoved:(NSArray *) deletedCrewIndexes
{
    [userUpdateDelegatesLock lock];
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(addedNewCrewsAtIndexes:andRemovedCrewsAtIndexes:)])
            [delegate addedNewCrewsAtIndexes:newCrewIndexes andRemovedCrewsAtIndexes:deletedCrewIndexes];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatUserIsAboutToLeaveCrew:(id<CCCrew>) crew 
{
    [userUpdateDelegatesLock lock];
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(startingToLeaveCrew:)])
            [delegate startingToLeaveCrew:crew];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatUserHasFinishedLeavingCrew:(id<CCCrew>) crew 
{
    [userUpdateDelegatesLock lock];
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(finishedLeavingCrew:)])
            [delegate finishedLeavingCrew:crew];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatInvitesAreAboutToBeLoaded
{
    [userUpdateDelegatesLock lock];
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(startingToReloadAllInvites)])
            [delegate startingToReloadAllInvites];
    }    
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatInvitesHaveLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    [userUpdateDelegatesLock lock];
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(finishedReloadingAllInvitesWithSucces:andError:)])
            [delegate finishedReloadingAllInvitesWithSucces:success andError:error];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatInvitesHaveBeenAddedAtIndexes:(NSArray *) newInviteIndexes andRemovedAtIndexes:(NSArray *) deletedInviteIndexes
{
    [userUpdateDelegatesLock lock];
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(addedNewInvitesAtIndexes:andRemovedInvitesAtIndexes:)])
            [delegate addedNewInvitesAtIndexes:newInviteIndexes andRemovedInvitesAtIndexes:deletedInviteIndexes];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

// Optional CCServerStoredObject methods
- (void) purgeRelatedDataInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    
}

// Required CCServerStoredObject methods
- (void)initialize
{
    isLoadingCrews = NO;
    isLoadingInvites = NO;
    userUpdateDelegatesLock = [NSLock new];
    [self setCcCrews:[[NSMutableArray alloc] init]];
    [self setCcInvites:[[NSMutableArray alloc] init]];
    [self setUserUpdateDelegates:[[NSMutableArray alloc] init]];
    [self setUserUpdateDelegatesToAdd:[[NSMutableArray alloc] init]];
    [self setUserUpdateDelegatesToRemove:[[NSMutableArray alloc] init]];
}

- (NSString *) getName
{
    return [[NSString alloc] initWithFormat:@"%@ %@", [self getFirstName], [self getLastName]];
}

- (void) logOutUserInBackground
{
    [self unsubscribeToUserAndGlobalChannelInBackground];
    [PFUser logOut]; 
}

// Required CCUser methods
- (void)sendNotificationWithMessage:(NSString *)message
{
    NSString *channelName = [[NSString alloc] initWithFormat:@"user_%@", [self getObjectID]];
    
    [PFPush sendPushMessageToChannelInBackground:channelName
                                     withMessage:message];
}

- (void)sendNotificationWithData:(NSDictionary *)data
{
    PFPush *message = [[PFPush alloc] init];
    [message setChannel:[[NSString alloc] initWithFormat:@"user_%@", [self getObjectID]]];
    [message setData:data];
    [message sendPushInBackground];
}

- (BOOL) notificationReceivedWithData:(NSDictionary *)data
{ 
    if ([[data objectForKey:@"type"] intValue] == CCInvitePush || [[data objectForKey:@"type"] intValue] == CCCrewPush)
    {
        if ([[data objectForKey:@"ID"] isEqualToString:[self getObjectID]])
        {
            if ([[data objectForKey:@"type"] intValue] == CCInvitePush)
            {
                [self loadInvitesInBackgroundWithBlockOrNil:nil];
            } 
            else if ([[data objectForKey:@"type"] intValue] == CCCrewPush)
            {
                [self loadCrewsInBackgroundWithBlockOrNil:nil];
            }
            return true;
        }
    }
    else
    {
        for (int crewIndex = 0; crewIndex < [[self ccCrews] count]; crewIndex++)
        {
            [(id<CCCrew>)[[self ccCrews] objectAtIndex:crewIndex] notificationReceivedWithData:data];
        }
        return true;
    }
    
    return false;
}


- (void) clearNotificationSubscriptions 
{
    @synchronized([[CCCoreManager sharedInstance] server])
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
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to unsubscribe to crew channel: %@", [error localizedDescription]];
                }
            }
        }
    }
}

- (void)subscribeToUserAndGlobalChannelInBackground
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{        
        @synchronized([[CCCoreManager sharedInstance] server])
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

        
        
            NSString *userChannelName = [[NSString alloc] initWithFormat:@"user_%@", [self getObjectID]];
                
                [PFPush subscribeToChannel:userChannelName error:&error];
                 if (error)
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to subscribe to the user's channel: %@", [error localizedDescription]];                         
                 }
                 else 
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Succesfully subscribed to the user's channel."];
                 }
        }
    });
}

- (void)unsubscribeToUserAndGlobalChannelInBackground
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{        
        [self clearNotificationSubscriptions];
    });
}

- (NSString *) getUserID
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [self getObjectID];
}

- (BOOL) getIsUserNew
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [((PFUser *)[self parseObject]) isNew];
}

- (void)    setHasUserLoggedIn:(BOOL) hasLoggedOn
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:[NSNumber numberWithBool:hasLoggedOn] forKey:@"hasUserLoggedIn"];
}

- (BOOL)    getHasUserLoggedIn
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"hasUserLoggedIn"] boolValue];
}

- (NSString *) getUserChannel
{
    return [NSString stringWithFormat:@"user_%@", [self getObjectID]];
}

- (void) setLastName:(NSString *) lastName
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:lastName forKey:@"lastName"];
}

- (NSString *) getLastName
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"lastName"];
}

- (void) setFirstName:(NSString *) firstName
{
    [self checkForParseDataAndThrowExceptionIfNil];

    [[self parseObject] setObject:firstName forKey:@"firstName"];
}

- (NSString *) getFirstName
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"firstName"];
}

- (void) setEmailAddress:(NSString *) emailAddress
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:emailAddress forKey:@"email"];
}

- (NSString *) getEmailAddress
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"email"];
}

- (void) setGender:(NSString *) gender
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:gender forKey:@"gender"];   
}

- (NSString *) getGender
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"gender"]; 
}
    
@synthesize localUIImage;

- (void) setProfilePicture:(UIImage *) profilePicture
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:profilePicture forKey:@"profilePicture"];  
}

- (UIImage *) getProfilePicture
{
    if (localUIImage == nil)
        localUIImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", [self getFacebookID]]]]];
    
    return localUIImage;
}

- (void) setLocation:(CLLocation *) location
{
    [self checkForParseDataAndThrowExceptionIfNil];
            
    PFGeoPoint *locationGeoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude  longitude:location.coordinate.longitude];
    
    [[self parseObject] setObject:locationGeoPoint forKey:@"userLocation"];  
}

- (CLLocation *) getLocation
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    PFGeoPoint *usersLocation = [[self parseObject] objectForKey:@"usersLocation"];            
    if (usersLocation == nil)
    {
        return nil;
    }
    
    return [[CLLocation alloc] initWithLatitude:[usersLocation latitude] longitude:[usersLocation longitude]];
}                                    

- (void) setFacebookID:(NSString *) facebookID
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:facebookID forKey:@"facebookId"];  
}

- (NSString *) getFacebookID
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"facebookId"]; 
}

- (void) setPhoneNumber:(NSString *) phoneNumber
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:phoneNumber forKey:@"phoneNumber"];  
}

- (NSString *) getPhoneNumber
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"phoneNumber"]; 
}

- (void) setUserLock:(BOOL) isLocked
{
    [self checkForParseDataAndThrowExceptionIfNil];

    [[self parseObject] setObject:[NSNumber numberWithBool:isLocked] forKey:@"isLocked"];  
}

- (BOOL) isUserLocked
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"isLocked"] boolValue]; 
}

- (void) setNumberOfInvites:(NSNumber *) numberOfInvites
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:numberOfInvites forKey:@"invitesLeft"]; 
}

- (NSNumber *) getNumberOfInvitesLeft
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"invitesLeft"]; 
}

- (void) loadCrewsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    @synchronized(ccCrews)
    {
        if (OSAtomicTestAndSetBarrier(1, &isLoadingCrews))        
            return;

        [self notifyListenersThatCrewsAreAboutToBeLoaded];
        
        PFQuery *thisUsersCrewsQuery = [PFQuery queryWithClassName:@"Crew"];    
        [thisUsersCrewsQuery whereKey:@"crewMembers" equalTo:[self parseObject]];
        [thisUsersCrewsQuery orderByDescending:@"updatedAt"];
        
        [thisUsersCrewsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
        {        
            if (!error)
            {
                [self handleNewCrews:objects];
            }
            
            OSAtomicTestAndClear(YES, &isObjectBusy);
            
            if (block)
                block((error != nil ? NO : YES), error);
            
            [self notifyListenersThatCrewsHaveLoadedWithSuccess:(error != nil ? NO : YES) andError:error];
            
            OSAtomicTestAndClearBarrier(1, &isLoadingCrews);
        }];
    }
}

- (void) handleNewCrews:(NSArray *) pfObjects
{
    NSMutableArray *allCrews = [[NSMutableArray alloc] init];
    NSMutableArray *newCrewIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *removedCrewIndexes = [[NSMutableArray alloc] init];

    for (PFObject *pfObject in pfObjects)
    {
        CCParseCrew *crew = [[CCParseCrew alloc] initWithServerData:pfObject];
        
        if ([self isCrewNew:crew])
            [crew subscribeToNotifications];
        
        [allCrews addObject:crew];
    }
    
    [self handleNewCCObjects:allCrews removedObjectIndexes:removedCrewIndexes addedObjectIndexes:newCrewIndexes finalArrayOfObjects:ccCrews];
    
    if ([removedCrewIndexes count] > 0 || [newCrewIndexes count] > 0)
        [self notifyListenersThatCrewsHaveBeenAdded:newCrewIndexes andCrewsHaveBeenRemoved:removedCrewIndexes];    
}

- (BOOL) isCrewNew:(id<CCCrew>) newCrew
{
    return ![CCParseObject isObjectInArray:newCrew arrayOfCCServerStoredObjects:ccCrews];
}

- (void) loadInvitesInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{        
    if(OSAtomicTestAndSetBarrier(YES, &isLoadingInvites))
        return;
        
    [self notifyListenersThatInvitesAreAboutToBeLoaded];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    PFQuery *thisUsersInvitesQuery = [PFQuery queryWithClassName:@"Invite"];
    
    [thisUsersInvitesQuery whereKey:@"invitee" equalTo:[self parseObject]];
    [thisUsersInvitesQuery includeKey:@"invitee"];
    [thisUsersInvitesQuery includeKey:@"crewInvitedTo"];
    [thisUsersInvitesQuery includeKey:@"invitedBy"];
    [thisUsersInvitesQuery orderByDescending:@"createdAt"];
    
    [thisUsersInvitesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
     {          
         if (!error)
         {
             [self handleNewInvites:objects];
         }
         
         OSAtomicTestAndClear(YES, &isObjectBusy);
         
         if (block)
             block((error != nil ? NO : YES), error);
         
         [self notifyListenersThatInvitesHaveLoadedWithSuccess:(error != nil ? NO : YES) andError:error];
         
         OSAtomicTestAndClearBarrier(YES, &isLoadingInvites);
     }];
}

- (void) removeInviteLocally:(id<CCInvite>) invite
{
    if ([ccInvites containsObject:invite])
    {
        int inviteIndex = [ccInvites indexOfObject:invite];
        [ccInvites removeObject:invite];
        [self notifyListenersThatInvitesHaveBeenAddedAtIndexes:nil andRemovedAtIndexes:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:inviteIndex inSection:0], nil]];
    }
}

- (void) handleNewInvites:(NSArray *) pfObjects
{
    NSMutableArray *allInvites = [[NSMutableArray alloc] init];
    NSMutableArray *newInviteIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *oldInviteIndexes = [[NSMutableArray alloc] init];
    
    for (PFObject *pfObject in pfObjects)
    {
        [allInvites addObject:[[CCParseInvite alloc] initWithServerData:pfObject]];
    }
    
    //Purges Invites to crews you have already joined
    for (int inviteIndex = 0; inviteIndex < [allInvites count]; inviteIndex++)
    {
        if ([CCParseObject isObjectInArray:[(id<CCInvite>)[allInvites objectAtIndex:inviteIndex] getCrewInvitedTo] arrayOfCCServerStoredObjects:ccCrews])
        {
            [[allInvites objectAtIndex:inviteIndex] deleteObjectWithBlockOrNil:nil];
            [allInvites removeObjectAtIndex:inviteIndex];
            
        }
    }
    
    [self handleNewCCObjects:allInvites removedObjectIndexes:oldInviteIndexes addedObjectIndexes:newInviteIndexes finalArrayOfObjects:ccInvites];

    if ([oldInviteIndexes count] > 0 || [newInviteIndexes count] > 0)
        [self notifyListenersThatInvitesHaveBeenAddedAtIndexes:newInviteIndexes andRemovedAtIndexes:oldInviteIndexes];
    
}

- (BOOL) isInviteNew:(id<CCInvite>) newInvite
{
    for(id<CCInvite> invite in [self ccInvites])
    {
        if ([[invite getObjectID] isEqualToString:[newInvite getObjectID]])
            return YES;
    }
    
    return NO;
}

- (void) addUserToCrewLocally:(id<CCCrew>)crew
{
    if (![CCParseObject isObjectInArray:crew arrayOfCCServerStoredObjects:ccCrews])
    {
        [crew subscribeToNotifications];
        [ccCrews insertObject:crew atIndex:0];
        [self notifyListenersThatCrewsHaveBeenAdded:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] andCrewsHaveBeenRemoved:nil];        
    }
}

- (void) removeUserFromCrewLocally:(id<CCCrew>)crew
{
    int removedCrewIndex = [self indexForCCServerStoredObject:crew inArrayOfCCServerStoredObjects:ccCrews];
    if (removedCrewIndex >= 0)
    {
        [ccCrews removeObjectAtIndex:removedCrewIndex];
        [self notifyListenersThatCrewsHaveBeenAdded:nil andCrewsHaveBeenRemoved:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:removedCrewIndex inSection:0], nil]];
    }
}

- (void) removeUserFromCrew:(id<CCCrew>)crew WithBlockOrNil:(CCBooleanResultBlock)block
{             
    OSAtomicTestAndSet(YES, &isObjectBusy);
    [self notifyListenersThatUserIsAboutToLeaveCrew:crew];  
    [crew removeMemberInBackground:[[[CCCoreManager sharedInstance] server] currentUser] withBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
        if (succeeded)
        {                  
            [[CCCoreManager sharedInstance] recordMetricEvent:@"Left crew" withProperties:nil];
            
            if ([crew getNumberOfMembers] == 0)
            {
                [crew deleteObjectWithBlockOrNil:nil];
            }
            else 
            {
                // Force a refresh
                [self pullObjectWithBlockOrNil:nil];
            }    
        }    
        else 
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:@"Failed leaving crew" withProperties:nil];
        }
        
        [self removeUserFromCrewLocally:crew];
        
        OSAtomicTestAndClear(YES, &isObjectBusy);
        
        if (block)
            block(succeeded, error);
        
    }];
}


- (id<CCCrew>) getCrewFromObjectID: (NSString*)crewObjectID
{
    for (int crewIndex = 0;crewIndex < [[self ccCrews] count]; crewIndex++)
    {
        if ( [[[[self ccCrews] objectAtIndex:crewIndex] getObjectID] isEqualToString:crewObjectID])
        {
            return [[self ccCrews] objectAtIndex:crewIndex];
        }
    }
    
    return nil;
}

- (NSArray *) getArrayOfCrewIDs
{
    NSMutableArray *crewIDs = [[NSMutableArray alloc] initWithCapacity:[ccCrews count]];
    
    for (id<CCCrew> crew in ccCrews)
    {
        [crewIDs addObject:[crew getObjectID]];
    }

    return crewIDs;
}


- (void) getVideoAndCrewFromServerFromVideoID:(NSString *)videoID withBlock:(CCCrewVideoResultBlock)block
{
    __block id<CCCrew>  foundCrew;
    __block id<CCVideo> foundVideo;
    
    PFQuery *commentedVideoQuery = [PFQuery queryWithClassName:@"Video"];
    [commentedVideoQuery whereKey:@"objectId" matchesRegex:videoID];
    
    PFQuery *crewWithCommentedVideoQuery= [PFQuery queryWithClassName:@"Crew"];
    [crewWithCommentedVideoQuery whereKey:@"videos" matchesQuery:commentedVideoQuery];
    
    [crewWithCommentedVideoQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error)
        {
            CCParseCrew *foundCrewFromServer = [[CCParseCrew alloc] initWithServerData:object];
            
            for (id<CCCrew> crew in [self ccCrews]) {
                if ([[crew getObjectID] isEqualToString:[foundCrewFromServer getObjectID]])
                {
                    // we found the crew in your local crews, we will now use the local reference
                    foundCrew = crew;
                    break;
                }
            }
            
            if (foundCrew) 
            {
                [foundCrew loadVideosInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                    {
                        for (id<CCVideo> video in [foundCrew ccVideos]) {
                            if ([[video getObjectID] isEqualToString:videoID])
                            {
                                foundVideo = video;
                                block(foundCrew,foundVideo,YES,nil);
                                break;
                            } 
                        }
                    }
                    
                } startingAtIndex:0 forVideoCount:[foundCrew getNumberOfVideos]];
            }
            
        }
        
    }];
}

- (void) getVideo:(out id<CCVideo> *)foundVideo InCrew:(out id<CCCrew> *)foundCrew FromObjectID:(NSString *)objectID;
{
    for (id<CCCrew> crew in [self ccCrews]) {
        for (id<CCVideo> video in [crew ccVideos]) {
            if ([[video getObjectID] isEqualToString:objectID])
            {
                *foundVideo = video;
                *foundCrew = crew;
                break;
            }
        }
    }
}

@synthesize userUpdateDelegates;
@synthesize userUpdateDelegatesToAdd;
@synthesize userUpdateDelegatesToRemove;
- (void) addUserUpdateListener:(id<CCUserUpdatesDelegate>) delegate
{
    if (![userUpdateDelegatesLock tryLock])
    {
        if (![userUpdateDelegates containsObject:delegate])
            [userUpdateDelegatesToAdd addObject:delegate];
        return;
    }
    
    if (![userUpdateDelegates containsObject:delegate])
        [userUpdateDelegates addObject:delegate];
    [userUpdateDelegatesLock unlock];
}

- (void) removeUserUpdateListener:(id<CCUserUpdatesDelegate>) delegate
{
    if (![userUpdateDelegatesLock tryLock])
    {
        if ([userUpdateDelegates containsObject:delegate])
            [userUpdateDelegatesToRemove addObject:delegate];
        return;
    }
    
    if ([userUpdateDelegates containsObject:delegate])
        [userUpdateDelegates removeObject:delegate];
    [userUpdateDelegatesLock unlock];
}

- (void) completeAddingUpdateListeners
{
    [userUpdateDelegatesLock lock];
    [userUpdateDelegates addObjectsFromArray:userUpdateDelegatesToAdd];
    [userUpdateDelegatesToAdd removeAllObjects];
    [userUpdateDelegates removeObjectsInArray:userUpdateDelegatesToRemove];
    [userUpdateDelegatesToRemove removeAllObjects];
    [userUpdateDelegatesLock unlock];
}

@end
