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
@synthesize ccFriendRequestsSent;
@synthesize ccCrewcamFriends;
@synthesize ccInvites;
@synthesize ccNotifications;
@synthesize FBEducationIds;
@synthesize FBWorkIds;
@synthesize FBLocationId;
@synthesize FBHometownId;
@synthesize isUserNewlyActivated;

// CCParseUser helper methods
- (void) notifyListenersThatCrewsAreAboutToBeLoaded
{
    if (![userUpdateDelegatesLock tryLock])
        return;
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
    if (![userUpdateDelegatesLock tryLock])
        return;
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
    if (![userUpdateDelegatesLock tryLock])
        return;
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
    if (![userUpdateDelegatesLock tryLock])
        return;
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
    if (![userUpdateDelegatesLock tryLock])
        return;
    
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(finishedLeavingCrew:)])
            [delegate finishedLeavingCrew:crew];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatFriendsAreAboutToBeLoaded
{
    if (![userUpdateDelegatesLock tryLock])
        return;

    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(startingToReloadAllFriends)])
            [delegate startingToReloadAllFriends];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatFriendsWereLoadedWithSuccess:(BOOL) successful andError:(NSError *) error
{
    if (![userUpdateDelegatesLock tryLock])
        return;
    
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(finishedLoadingFriendsWithSuccess:andError:)])
            [delegate finishedLoadingFriendsWithSuccess:successful andError:error];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatFriendsWereAddedAtIndexes:(NSArray *) addedFriendIndexes andRemovedAtIndexes:(NSArray *) removedFriendIndexes;
{
    if (![userUpdateDelegatesLock tryLock])
        return;
    
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(addedNewFriendsAtIndexes:andRemovedFriendsAtIndexes:)])
            [delegate addedNewFriendsAtIndexes:addedFriendIndexes andRemovedFriendsAtIndexes:removedFriendIndexes];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatInvitesAreAboutToBeLoaded
{
    if (![userUpdateDelegatesLock tryLock])
        return;
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
    if (![userUpdateDelegatesLock tryLock])
        return;
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
    if (![userUpdateDelegatesLock tryLock])
        return;
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(addedNewInvitesAtIndexes:andRemovedInvitesAtIndexes:)])
            [delegate addedNewInvitesAtIndexes:newInviteIndexes andRemovedInvitesAtIndexes:deletedInviteIndexes];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatNotificationsAreAboutToBeLoaded
{
    if (![userUpdateDelegatesLock tryLock])
        return;
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(startingToReloadAllNotifications)])
            [delegate startingToReloadAllNotifications];
    }    
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatNotificationsHaveLoadedWithSuccess:(BOOL) success andError:(NSError *) error
{
    if (![userUpdateDelegatesLock tryLock])
        return;
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(finishedReloadingAllNotificationsWithSucces:andError:)])
            [delegate finishedReloadingAllNotificationsWithSucces:success andError:error];
    }
    [userUpdateDelegatesLock unlock];
    [self completeAddingUpdateListeners];
}

- (void) notifyListenersThatNotificationsHaveBeenAddedAtIndexes:(NSArray *) newNotificationIndexes andRemovedAtIndexes:(NSArray *) deletedNotificationIndexes
{
    if (![userUpdateDelegatesLock tryLock])
        return;
    for (id<CCUserUpdatesDelegate> delegate in userUpdateDelegates)
    {
        if ([delegate respondsToSelector:@selector(addedNewNotificationsAtIndexes:andRemovedNotificationsAtIndexes:)])
            [delegate addedNewNotificationsAtIndexes:newNotificationIndexes andRemovedNotificationsAtIndexes:deletedNotificationIndexes];
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
    isLoadingFriendRequests = NO;
    isLoadingFriends = NO;
    isLoadingInvites = NO;
    isLoadingNotifications = NO;
    userUpdateDelegatesLock = [NSLock new];
    crewcamFriendsBlockArray = [[NSMutableArray alloc] init];
    [self setIsUserNewlyActivated:NO];
    [self setCcCrews:[[NSMutableArray alloc] init]];
    [self setCcFriendRequestsSent:[[NSMutableArray alloc] init]];
    [self setCcCrewcamFriends:[[NSMutableArray alloc] init]];
    [self setCcInvites:[[NSMutableArray alloc] init]];
    [self setCcNotifications:[[NSMutableArray alloc] init]];
    [self setUserUpdateDelegates:[[NSMutableArray alloc] init]];
    [self setUserUpdateDelegatesToAdd:[[NSMutableArray alloc] init]];
    [self setUserUpdateDelegatesToRemove:[[NSMutableArray alloc] init]];
}

- (void) dealloc
{
    localUIImage = nil;
    userUpdateDelegatesLock = nil;
    crewcamFriendsBlockArray = nil;
    [self setCcCrews:nil];
    
    [self setFBEducationIds:nil];
    [self setFBWorkIds:nil];
    [self setFBLocationId:nil];
    [self setFBHometownId:nil];
    
    [self setCcFriendRequestsSent:nil];
    [self setCcCrewcamFriends:nil];
    [self setCcInvites:nil];
    [self setCcNotifications:nil];
    
    [self setUserUpdateDelegates:nil];
    [self setUserUpdateDelegatesToAdd:nil];
    [self setUserUpdateDelegatesToRemove:nil];
}

- (NSString *) getName
{
    return [[NSString alloc] initWithFormat:@"%@ %@", [self getFirstName], [self getLastName]];
}

- (void) logOutUserInBackground
{
    [self unsubscribeToUserAndGlobalChannelInBackground];
    [PFUser logOut];
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_LOGGED_OUT withProperties:nil];
}

- (void) deleteUser
{
    [self unsubscribeToUserAndGlobalChannelInBackground];
    [[PFUser currentUser] delete];
    
}

- (void) deleteUserInBackgroundWithBlock:(CCBooleanResultBlock)block
{
    [self unsubscribeToUserAndGlobalChannelInBackground];
    [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        block(succeeded, nil);
    }];
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
    // Reload "Crewcam" notificaitons
    [self loadNotificationsInBackgroundWithBlockOrNil:nil];
    
    // Handle this notification specifically
    if ([[data objectForKey:@"type"] intValue] == ccInvitePushNotification || [[data objectForKey:@"type"] intValue] == ccCrewPushNotification)
    {
        if ([[data objectForKey:@"ID"] isEqualToString:[self getObjectID]])
        {
            if ([[data objectForKey:@"type"] intValue] == ccInvitePushNotification)
            {
                [self loadInvitesInBackgroundWithBlockOrNil:nil];
            } 
            else if ([[data objectForKey:@"type"] intValue] == ccCrewPushNotification)
            {
                [self loadCrewsInBackgroundWithBlockOrNil:nil];
            }
            return true;
        }
    }
    else if ([[data objectForKey:@"type"] intValue] == ccFriendJoinedPushNotification)
    {
        [[[CCCoreManager sharedInstance] friendManager] addFacebookFriendsAndContactsWhoAreUsingCrewcamWithBlockOrNil:nil];
    }
    else if([[data objectForKey:@"type"] intValue] == ccFriendRequestAcceptedPushNotification)
    {
        [self loadFriendRequestsInBackgroundWithBlockOrNil:nil];
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
    
    [[self parseObject] setObject:emailAddress forKey:@"emailAddress"];
}

- (NSString *) getEmailAddress
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"emailAddress"];
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

- (NSArray *) getArrayOfUserCrewInfo
{
    return [[self parseObject] objectForKey:@"userCrewInfo"];
}

- (void) setProfilePicture:(UIImage *) profilePicture
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    localUIImage = profilePicture;
    
    if (profilePicture)
    {
        PFFile *pictureFile = [PFFile fileWithName:@"profilePicture.jpeg" data:UIImageJPEGRepresentation(profilePicture, 0.1)];
        
        [pictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
           if (succeeded)
           {
               [[self parseObject] setObject:pictureFile forKey:@"profilePicture"];
               [[[[CCCoreManager sharedInstance] server] currentUser] pushObjectWithBlockOrNil:nil];
           }
        }];
    }
    else 
    {
        NSNull *nullPicture = [[NSNull alloc] init];
        [[self parseObject] setObject:nullPicture forKey:@"profilePicture"];
        [[[[CCCoreManager sharedInstance] server] currentUser] pushObjectWithBlockOrNil:nil];
    }
}



- (void) clearProfilePicture
{
    localUIImage = nil;
}

- (void) getProfilePictureInBackgroundWithBlock:(CCImageResultBlock) block
{
    if (localUIImage != nil)
    {
        block(localUIImage, nil);
        return;
    }
    
    if (![[[self parseObject] objectForKey:@"profilePicture"] isKindOfClass:[NSNull class]] && [[self parseObject] objectForKey:@"profilePicture"])
    {
        PFFile *pictureFile = [[self parseObject] objectForKey:@"profilePicture"];
        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error)
            {
                localUIImage = [UIImage imageNamed:@"default-profile.png"];
            }
            else
            {
                localUIImage = [UIImage imageWithData:data];
            }
            block(localUIImage, error);
        }];
    }
    else if ([self isUserLinkedToFacebook])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            localUIImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", [self getFacebookID]]]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(localUIImage, nil);
            });
        });
    }
    else
    {
        localUIImage = [UIImage imageNamed:@"default-profile.png"];
        block(localUIImage, nil);
    }    
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

- (void) setUserRevisionToCurrentRevision
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"softwareRevision"];
}

-(NSString *) getUserRevision
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"softwareRevision"];
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

- (void) setUserActive:(BOOL) isActive
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:[NSNumber numberWithBool:isActive] forKey:@"isUserActivated"];  
}

- (BOOL) isUserActive
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"isUserActivated"] boolValue]; 
}

- (void) setUserIsDeveloper:(BOOL) isDeveloper
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:[NSNumber numberWithBool:isDeveloper] forKey:@"isDeveloper"];  
}

- (BOOL) isUserDeveloper
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self parseObject] objectForKey:@"isDeveloper"] boolValue]; 
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

- (void) setFacebookUserWallPostPermission:(BOOL)permission
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:[NSNumber numberWithBool:!permission] forKey:@"notAbleToPostOnWall"];
}

- (BOOL) getFacebookUserWallPostPermission
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return ![[[self parseObject] objectForKey:@"notAbleToPostOnWall"] boolValue];
}

- (NSString *) getPassword
{
    return [(PFUser*)[self parseObject] password];
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

//- (void) oneTimeAddUserCrewInfoObjectsForExistingCrew:(NSArray *)crews
//{
//    for()
//    {
//        
//    }
//}

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

- (void) sendFriendRequestInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    [CCParseFriendRequest createNewFriendRequestInBackgroundForCCUser:self byCCUser:[[[CCCoreManager sharedInstance] server] currentUser] andIsPreAccepted:NO withBlockOrNil:block];
}

- (void) loadFriendRequestsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    @synchronized(ccCrews)
    {
        if (OSAtomicTestAndSetBarrier(1, &isLoadingFriendRequests))
            return;        
        
        PFQuery *thisUsersFriendRequestsSent = [PFQuery queryWithClassName:@"FriendRequest"];
        [thisUsersFriendRequestsSent whereKey:@"personInvitedBy" equalTo:[self parseObject]];
        
        [thisUsersFriendRequestsSent findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 NSMutableArray *newFriendRequests = [[NSMutableArray alloc] initWithCapacity:[objects count]];
                 
                 NSMutableArray *friendRequestsThatHaveBeenAccepted = [[NSMutableArray alloc] init];
                 
                 for(PFObject *pfRequest in objects)
                 {
                     CCParseFriendRequest *friendRequest = [[CCParseFriendRequest alloc] initWithServerData:pfRequest];
                     
                     if ([friendRequest getHasRequestBeenAcceptedByRequestee])
                     {
                         [friendRequestsThatHaveBeenAccepted addObject:friendRequest];
                     }
                     else
                     {
                         [newFriendRequests addObject:friendRequest];
                     }
                 }
                 
                 [self addFriendsFromAcceptedInvitesInBackground:friendRequestsThatHaveBeenAccepted withBlockOrNil:nil];
                 
                 ccFriendRequestsSent = newFriendRequests;
             }
             
             OSAtomicTestAndClear(YES, &isObjectBusy);
             
             if (block)
                 block((error != nil ? NO : YES), error);             
             
             OSAtomicTestAndClearBarrier(1, &isLoadingFriendRequests);
         }];
    }
}

- (BOOL) hasFriendRequestedUser:(id<CCUser>) user
{
    for(id<CCFriendRequest> request in ccFriendRequestsSent)
    {
        if ([[user getObjectID] isEqualToString:[[request getCCUserThatIsRequestee] getObjectID]])
            return YES;
    }
    
    return NO;
}

- (void) addFriendInBackground:(id<CCUser>) friendToAdd withBlockOrNil:(CCBooleanResultBlock) block
{
    // Is the user already a friend?
#warning Should we reload friends before checking?!
    if ([CCParseObject isObjectInArray:friendToAdd arrayOfCCServerStoredObjects:ccCrewcamFriends])
    {
        if (block)
            block(YES, nil);
        
        return;
    }
    
    [ccCrewcamFriends addObject:friendToAdd];
    
    PFRelation *pfFriendsRelation = [[self getServerData] relationforKey:@"friends"];
    
    [pfFriendsRelation addObject:[friendToAdd getServerData]];
    
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        
       if (block)
           block(succeeded, error);
    }];
}

- (void) addFriendsInBackground:(NSArray *) ccUsersToBeAdded withBlockOrNil:(CCBooleanResultBlock) block
{
    for (id<CCUser> user in ccUsersToBeAdded)
    {        
        if ([CCParseObject isObjectInArray:user arrayOfCCServerStoredObjects:ccCrewcamFriends])
        {
            continue;
        }
        
        [ccCrewcamFriends addObject:user];
        
        PFRelation *pfFriendsRelation = [[self getServerData] relationforKey:@"friends"];
        
        [pfFriendsRelation addObject:[user getServerData]];
    }
    
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {        
        if (block)
            block(succeeded, error);
    }];
}

- (void) addFriendsFromAcceptedInvitesInBackground:(NSArray *) acceptedCCRequests withBlockOrNil:(CCBooleanResultBlock) block
{
    NSMutableArray *ccUsersThatAccepted = [[NSMutableArray alloc] initWithCapacity:[acceptedCCRequests count]];
    for (id<CCFriendRequest> request in acceptedCCRequests)
    {
        [ccUsersThatAccepted addObject:[request getCCUserThatIsRequestee]];
        
        [request deleteObjectWithBlockOrNil:nil];
    }
    
    [self addFriendsInBackground:ccUsersThatAccepted withBlockOrNil:block];
}

- (BOOL) isFriendOfUser:(id<CCUser>) user
{
    return [CCParseObject isObjectInArray:user arrayOfCCServerStoredObjects:ccCrewcamFriends];
}

- (void) loadCrewcamFriendsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    if (block)
        [crewcamFriendsBlockArray addObject:[block copy]];
    
    if (OSAtomicTestAndSet(YES, &isLoadingFriends))
        return;
    
    [self notifyListenersThatFriendsAreAboutToBeLoaded];
    
    [self updateFriendsInBackground];
}

- (void) updateFriendsInBackground
{
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    PFRelation *friendsRelation = [[self getServerData] relationforKey:@"friends"];
    
    [[friendsRelation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [self handleNewFriends:objects];
        }
        
        OSAtomicTestAndClear(YES, &isObjectBusy);
        
        for (CCBooleanResultBlock block in crewcamFriendsBlockArray)
        {
            if (block)
                block((error != nil ? NO : YES), error);
        }
        
        [crewcamFriendsBlockArray removeAllObjects];
        
        [self notifyListenersThatFriendsWereLoadedWithSuccess:(error != nil ? NO : YES) andError:error];
        
        OSAtomicTestAndClear(YES, &isLoadingFriends);
    }];
}

- (void) handleNewFriends:(NSArray *) pfObjects
{
    NSMutableArray *allFriends = [[NSMutableArray alloc] init];
    NSMutableArray *newFriendIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *oldFriendIndexes = [[NSMutableArray alloc] init];
    
    for (PFObject *pfObject in pfObjects)
    {
        [allFriends addObject:[[CCParseUser alloc] initWithServerData:pfObject]];
    }
    
    [self handleNewCCObjects:allFriends removedObjectIndexes:oldFriendIndexes addedObjectIndexes:newFriendIndexes finalArrayOfObjects:ccCrewcamFriends];
    
    if ([oldFriendIndexes count] > 0 || [newFriendIndexes count] > 0)
        [self notifyListenersThatFriendsWereAddedAtIndexes:newFriendIndexes andRemovedAtIndexes:oldFriendIndexes];
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

- (void) removeInviteLocally:(id<CCInvite>) invite
{
    if ([ccInvites containsObject:invite])
    {
        int inviteIndex = [ccInvites indexOfObject:invite];
        [ccInvites removeObject:invite];
        [self notifyListenersThatInvitesHaveBeenAddedAtIndexes:nil andRemovedAtIndexes:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:inviteIndex inSection:0], nil]];
    }
}

- (void) loadNotificationsInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    if (isDeletingNotifications)
        return;
    
    if(OSAtomicTestAndSetBarrier(YES, &isLoadingNotifications))
        return;
    
    [self notifyListenersThatNotificationsAreAboutToBeLoaded];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    PFQuery *thisUsersNotificationsQuery = [PFQuery queryWithClassName:@"Notification"];
    
    [thisUsersNotificationsQuery whereKey:@"targetUser" equalTo:[self parseObject]];
    [thisUsersNotificationsQuery includeKey:@"targetUser"];
    [thisUsersNotificationsQuery includeKey:@"sourceUser"];
    [thisUsersNotificationsQuery orderByDescending:@"createdAt"];
    
    [thisUsersNotificationsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
     {          
         if (!error)
         {
             [self handleNewNotifications:objects];
         }
         
         OSAtomicTestAndClear(YES, &isObjectBusy);
         
         if (block)
             block((error != nil ? NO : YES), error);
         
         [self notifyListenersThatNotificationsHaveLoadedWithSuccess:(error != nil ? NO : YES) andError:error];
         
         OSAtomicTestAndClearBarrier(YES, &isLoadingNotifications);
     }];
}

- (void) handleNewNotifications:(NSArray *) pfObjects
{
    NSMutableArray *allNotifications = [[NSMutableArray alloc] init];
    NSMutableArray *newNotificationIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *oldNotificationIndexes = [[NSMutableArray alloc] init];
    
    for (PFObject *pfObject in pfObjects)
    {
        [allNotifications addObject:[[CCParseNotification alloc] initWithServerData:pfObject]];
    }
    
    //LOGIC GOES HERE FOR COMBINING
    
    NSMutableArray *mergedNotifications = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *originalsWorkingCopy = [[NSMutableArray alloc] initWithArray:allNotifications];
    int endingIndex = 10;
    
    NSString *mergedMessage;
    NSString *mergedMessageNames;
    NSMutableArray *mergedMessageNamesArray = [[NSMutableArray alloc] init];
    
    for (int notficationIndex = 0; notficationIndex < [originalsWorkingCopy count]; notficationIndex++)
    {
        id<CCNotification> notification = [originalsWorkingCopy objectAtIndex:notficationIndex];
        
        mergedMessage = [notification getNotificationMessage];
        mergedMessageNames = [NSString stringWithFormat:@"%@",[[notification getSourceUser] getName]];
        [mergedMessageNamesArray addObject:[[notification getSourceUser] getName]];
        
        for (int otherNotificationsIndex = notficationIndex + 1; otherNotificationsIndex < [originalsWorkingCopy count]; otherNotificationsIndex++)
        {
            id<CCNotification> notificationToCompareWith = [originalsWorkingCopy objectAtIndex:otherNotificationsIndex];
            
            if ([[notification getTargetObjectId] isEqualToString:[notificationToCompareWith getTargetObjectId]] 
                && [notification getNotificationType] == [notificationToCompareWith getNotificationType])
            {
                if ([notification getNotificationType] == ccNewViewNotification || [notification getNotificationType] == ccNewCommentNotification)
                {
                    if (![mergedMessageNamesArray containsObject:[[notificationToCompareWith getSourceUser] getName]])
                        [mergedMessageNamesArray addObject:[[notificationToCompareWith getSourceUser] getName]];
                    
                    [originalsWorkingCopy removeObjectAtIndex:otherNotificationsIndex];
                    otherNotificationsIndex--;
                    endingIndex++;
                }
            }
        }
        
        if ([mergedMessageNamesArray count] > 1)
        {
            if ([mergedMessageNamesArray count] < 4)
            {
                for (int nameIndex = 1; nameIndex < [mergedMessageNamesArray count]; nameIndex++)
                {
                    NSString *name = [mergedMessageNamesArray objectAtIndex:nameIndex];
                    
                    if ([mergedMessageNames rangeOfString:name].location == NSNotFound)
                    {
                        if (nameIndex == [mergedMessageNamesArray count] -1)
                            mergedMessageNames = [NSString stringWithFormat:@"%@ and %@", mergedMessageNames, name];
                        else 
                            mergedMessageNames = [NSString stringWithFormat:@"%@, %@", mergedMessageNames, name];
                    }
                } 
            }
            else 
                mergedMessageNames = [NSString stringWithFormat:@"%d people",[mergedMessageNamesArray count] - 1];
            
            
            switch ([notification getNotificationType])
            {
                case ccNewViewNotification:
                {
                    mergedMessage = [NSString stringWithFormat:@"%@ have watched one of your videos!", mergedMessageNames];
                   break; 
                }

                case ccNewCommentNotification:
                {
                    if ([mergedMessage rangeOfString:@"your"].location == NSNotFound )
                        mergedMessage = [NSString stringWithFormat:@"%@ have also commented on a video!",mergedMessageNames];
                    else 
                        mergedMessage = [NSString stringWithFormat:@"%@ have commented on one of your videos!",mergedMessageNames];
                }
                default:
                    break;
            }
            
        [notification setNotificationMessage:mergedMessage];
        }
        
        [mergedMessageNamesArray removeAllObjects];
        
        [mergedNotifications addObject:notification];
        if ([mergedNotifications count] == 10)
            break;
    }
    
    for(int notificationIndex = endingIndex; notificationIndex < [allNotifications count];)
    {
        [[allNotifications objectAtIndex:notificationIndex] deleteObjectWithBlockOrNil:nil];
        [allNotifications removeObjectAtIndex:notificationIndex];
    }
    
    [self handleNewCCObjects:mergedNotifications removedObjectIndexes:oldNotificationIndexes addedObjectIndexes:newNotificationIndexes finalArrayOfObjects:ccNotifications];
    
    if ([oldNotificationIndexes count] > 0 || [newNotificationIndexes count] > 0)
        [self notifyListenersThatNotificationsHaveBeenAddedAtIndexes:newNotificationIndexes andRemovedAtIndexes:oldNotificationIndexes];
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
    int removedCrewIndex = [CCParseObject indexForCCServerStoredObject:crew inArrayOfCCServerStoredObjects:ccCrews];
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
             [[CCCoreManager sharedInstance] recordMetricEvent:CC_LEFT_CREW withProperties:nil];
             
             [crew getNumberOfMembersWithBlock:^(int numberOfMembers, BOOL succeded, NSError *error) {
                 if (numberOfMembers == 0 && [crew getCrewtype] == CCNormal)
                 {
                     [crew deleteObjectWithBlockOrNil:nil];
                 }
                 else 
                 {
                     // Force a refresh
                     [self pullObjectWithBlockOrNil:nil];
                 }

             } andForced:NO];
             
                          
             [self startDeletingNotificationsInBackgroundForCrew:crew];
// The below commented out code is part of Gamification... saving for a later release.
             //[self startDeletingUserCrewInfoObjectsInBackgroundForCrew:crew];
             
             NSDictionary *messageDataForMemberUpdate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                         [[[[CCCoreManager sharedInstance] server] currentUser ] getObjectID], @"src_User",
                                                         [NSNumber numberWithInt:ccMemberPushNotification], @"type",
                                                         [self getObjectID], @"ID",
                                                         nil];
             
             if ([crew getCrewtype] == CCFBSchool || [crew getCrewtype] == CCFBWork || [crew getCrewtype] == CCFBLocation )
             {
                 [[[[CCCoreManager sharedInstance] server] currentUser] loadCrewcamFriendsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {                     
                     if (error)
                     {
                         if (block)
                             block(NO,error);
                     }
                     else 
                     {                         
                         for (id<CCUser> user in [crew ccUsersThatAreMembers])
                         {
                             //Is this not our friend?
                             if (![CCParseObject isObjectInArray:user arrayOfCCServerStoredObjects:[[[[CCCoreManager sharedInstance] server] currentUser] ccCrewcamFriends]])
                                 continue;
                             
                             // Send the push notification
                             [user sendNotificationWithData:messageDataForMemberUpdate];
                         }
                     }
                 }];
             } 
             else if ([crew getCrewtype] == CCNormal || [crew getCrewtype] == CCDeveloper)
             {
                 for (id<CCUser> user in [crew ccUsersThatAreMembers])
                 {
                     // Send the push notification
                     [user sendNotificationWithData:messageDataForMemberUpdate];
                 }
             }
  
         }
         else 
         {
             [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_LEAVING_CREW withProperties:nil];
         }
         
         [self removeUserFromCrewLocally:crew];
         
         if (block)
             block(succeeded, error);
         
         OSAtomicTestAndClear(YES, &isObjectBusy);
         
     }];
}

- (void) startDeletingUserCrewInfoObjectsInBackgroundForCrew:(id<CCCrew>) crew
{
    if ([[self getArrayOfUserCrewInfo] class]!= [NSNull class])
    {
        NSMutableArray *userCrewInfo = [[NSMutableArray alloc] initWithArray:[self getArrayOfUserCrewInfo]];
        [PFObject fetchAllIfNeededInBackground:userCrewInfo block:^(NSArray *objects, NSError *error) {
            if (!error) {
                for(PFObject *object in objects)
                {
                    if([[[object objectForKey:@"Crew"] objectId] isEqualToString:[crew getObjectID]])
                    {
                        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            //
                        }];
                        [userCrewInfo removeObject:object];
                        [[self parseObject] setObject:userCrewInfo forKey:@"userCrewInfo"];
                        [self pushObjectWithBlockOrNil:nil];
                    }
                }
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Successfully deleted "];
            }
        }];
    }
}

- (void) startDeletingNotificationsInBackgroundForCrew:(id<CCCrew>) crew
{
    if(OSAtomicTestAndSetBarrier(YES, &isDeletingNotifications))
        return;
        
    PFQuery *queryForNotifications = [PFQuery queryWithClassName:@"Notification"];
    [queryForNotifications whereKey:@"targetCrewObjectId" matchesRegex:[crew getObjectID]];
    [queryForNotifications whereKey:@"targetUser" matchesRegex:[self getObjectID]];
    
    [queryForNotifications findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             OSAtomicTestAndClear(YES, &isDeletingNotifications);
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error deleting notifications for crew: %@", [error localizedDescription]];
             
             return;
         }
         
         // Delete all the notifications
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{             
             for(PFObject *notification in objects)
             {
                 [notification delete];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 OSAtomicTestAndClear(YES, &isDeletingNotifications);
                 [self loadNotificationsInBackgroundWithBlockOrNil:nil];
             });
         });
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

- (BOOL) isUserLinkedToFacebook
{
    return ([self getFacebookID] && [[self getFacebookID] class] != [NSNull class]);
}

- (BOOL) isBusy
{
    return isLoadingCrews || isLoadingInvites || isLoadingNotifications || [super isBusy];
}

- (void) creatUserCrewInfoObjectWithCrewInBackground:(id<CCCrew>)crew block:(CCBooleanResultBlock)block
{
    PFObject *newUserCrewInfo = [PFObject objectWithClassName:@"UserCrewInfo"];

    [newUserCrewInfo setObject:[crew getServerData] forKey:@"Crew"];
    
    [newUserCrewInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (succeeded)
        {
            [[self getServerData] addObject:newUserCrewInfo forKey:@"userCrewInfo"];
            [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                block(succeeded, error);
            }];
        }
        else
        {
            block(succeeded, error);
        }
            
    }];
}

- (void) incrementUserRewardPointsByValueInBackground:(int)value forCrew:(id<CCCrew>)crew block:(CCBooleanResultBlock)block
{
    //Get array of userCrewInfo's
    //Find the userCrewInfo associated with the passed crew.
    //Increment the reward points in the found userCrewInfo by the passed value
    
    NSArray *userCrewInfo = [[NSArray alloc] initWithArray:[self getArrayOfUserCrewInfo]];

    [PFObject fetchAllIfNeededInBackground:userCrewInfo block:^(NSArray *objects, NSError *error) {
        if (!error) {
            for(PFObject *object in objects)
            {
                if([[[object objectForKey:@"Crew"] objectId] isEqualToString:[crew getObjectID]])
                {
                    [object incrementKey:@"rewardPoints" byAmount:[NSNumber numberWithInt:value]];
                    [object save];
                }
            }
            block(!error, error);
        }
        else
        {
            block(!error, error);
        }
        
    }];
}

@end
