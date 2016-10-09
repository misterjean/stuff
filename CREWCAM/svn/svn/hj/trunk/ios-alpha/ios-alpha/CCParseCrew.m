//
//  CCParseCrew.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseCrew.h"

@implementation CCParseCrew

// CCCrew properties
@synthesize members;
@synthesize creadedDate;
@synthesize securitySetting;
@synthesize videos;
@synthesize pfInvites;
@synthesize crewUpdateDelegates;

- (id) initWithData:(PFObject *) crewData
{   
    self = [super initWithData:crewData];
    
    if (self != nil)    
    {
    	[self updatePropertiesWithParseData:crewData];    
    }           
    
    return self;
    
}

- (void) updatePropertiesWithParseData:(PFObject *)newData
{
       	members = [[NSMutableArray alloc] init];
        videos = [[NSMutableArray alloc] init];
        pfInvites = [[NSMutableArray alloc] init];
        
        //Useing the passed newData to initialize the local parse data info.
        [self setParseObject:newData];
        [self setObjectID:[newData     objectId]];
        [self setName:[newData         objectForKey:@"crewName"]];
    
    if ([newData objectForKey:@"securitySetting"] != nil )
    {
        switch ([[newData objectForKey:@"securitySetting"] intValue]) {
            case CCPrivate:
                [self setSecuritySetting:CCPrivate];
                break;
                
            default:
                [self setSecuritySetting:CCPublic];
                break;
        }
    }
    

        
        //The following interates through all videos from crewData and extracs the ObjectID used for queryOnVideos
        NSArray *tempVideos = [[NSArray alloc] initWithArray:(NSArray *)[newData objectForKey:@"videos"]];
        NSMutableArray *videoObjectIds = [[NSMutableArray alloc] init];
        for (int tempVideosIndex = 0; tempVideosIndex < [tempVideos count]; tempVideosIndex++) 
        {
            PFObject *tempPFObject = [(NSArray *)[newData objectForKey:@"videos"] objectAtIndex:tempVideosIndex];
            [videoObjectIds addObject:tempPFObject.objectId];
        }
        
        PFQuery *queryOnVideos = [PFQuery queryWithClassName:@"Video"];
        [queryOnVideos orderByDescending:@"createdAt"];
        [queryOnVideos whereKey:@"objectId" containedIn:videoObjectIds];
        [queryOnVideos includeKey:@"theOwner"];
        [queryOnVideos includeKey:@"videoComments"];
        [queryOnVideos setLimit:10];
        
    
        NSArray *tempMembersArray = [newData objectForKey:@"crewMembers"];    
            
        for (int tempMembersIndex = 0; tempMembersIndex < [[newData objectForKey:@"crewMembers"] count]; tempMembersIndex++)
        {
            if([[tempMembersArray objectAtIndex: tempMembersIndex] class] != [NSNull class])
            {
                id<CCUser> thisUser = [[CCParseUser alloc] initWithData:[tempMembersArray objectAtIndex: tempMembersIndex]];
                if (thisUser)
                    [members addObject:thisUser];
            }
            
        }
    
    
        PFQuery *queryOnInvites = [PFQuery queryWithClassName:@"Invite"];
        [queryOnInvites whereKey:@"crewInvitedTo" matchesRegex: [newData objectId]];
        
        NSError *error;
        
        NSArray *parseInvites = [queryOnInvites findObjects:&error];
    
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error querying crew for invites. %@", [error userInfo]];
        }
    
        else
        {
            
            [pfInvites addObjectsFromArray:parseInvites];
            
#warning the constructor for invites tries to init a crew which calls this function which tries to init an invite that inits a crew and so on
            /*
             for (int parseInvitesIndex = 0; parseInvitesIndex < [parseInvites count]; parseInvitesIndex ++ ) 
            {
                
                [invites addObject:[[CCParseInvite alloc] initWithData:[parseInvites objectAtIndex: parseInvitesIndex]]];
            }
             */
        }
        
        
            
        NSArray *parseVideos = [[NSArray alloc] initWithArray:[queryOnVideos findObjects:&error]];
        if(!error)
        {
            if(parseVideos != nil)
            {
                for(int videoIndex = 0; videoIndex < [parseVideos count]; videoIndex++)
                {                         
                    [videos addObject:[[CCParseVideo alloc] initWithData:[parseVideos objectAtIndex: videoIndex]]];
                }
            }
            else
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Crew's video was nil.  Skipping."];
            }
            
        }
        else 
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error querying crew for videos. %@", [error userInfo]];
        }
        
    
}

- (id<CCCrew>)initLocalCrewWithName:(NSString *)crewName privacy:(NSInteger)privacy
{
    self = [super init];
    
    if (self != nil)
    {
        members = [[NSMutableArray alloc] init];
        videos = [[NSMutableArray alloc] init];
        pfInvites = [[NSMutableArray alloc] init];
        
        switch (privacy) 
        {
            case CCPrivate:
                securitySetting = CCPrivate;
                break;
                
            default:
                securitySetting = CCPublic;
                break;
        }
        
        [self setParseObject:[[PFObject alloc] initWithClassName:@"Crew"]];
        [self setName:crewName];
    }
    
    return self;
}


// CCServerStoredObject methods
- (void)pushObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    if (members != nil)
    {
        NSArray *parseMembers = [[NSArray alloc] initWithArray:[self getArrayOfPFObjectsFromObjects:members]];
        
        if (parseMembers != nil)
        {
            [[self parseObject] setObject:parseMembers forKey:@"crewMembers"];
        }
    }
    if (videos != nil)
    {
        NSArray *parseVideos = [[NSArray alloc] initWithArray:[self getArrayOfPFObjectsFromObjects:videos]];
        
        if (parseVideos != nil)
        {
            [[self parseObject] setObject:parseVideos  forKey:@"videos"];
        }
        
    }
    
    [[self parseObject] setObject:[self name] forKey:@"crewName"];
    
    switch (securitySetting) 
    {
        case CCPrivate:
            [[self parseObject] setObject:[NSNumber numberWithInt:CCPrivate] forKey:@"securitySetting"];
            break;
            
        default:
            [[self parseObject] setObject:[NSNumber numberWithInt:CCPublic] forKey:@"securitySetting"];
            break;
    }    
    
    [[self parseObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
    {
        if (error)
        {
            if (block)
                block(NO, error);
        } 
        else
        {
            [self setObjectID:[[self parseObject] objectId]];
            
            if (block)
                block(YES, nil);
        }
    }];
}

- (void)pullObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    if ([self parseObject] != nil)
    {
        [[self parseObject] refreshInBackgroundWithBlock:^(PFObject *resultOfQuery, NSError *error)
        {
            if (!error) 
            {
                [self setParseObject: resultOfQuery];
                [self updatePropertiesWithParseData:[self parseObject]];
                if (block)
                    block(YES, nil);
            }
            else 
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to refresh local parse object %d: %@", [self objectID], [error localizedDescription]];
                if (block)
                    block(NO, error);
            }               
        }];

    }
    else 
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"pullObjectWithNewThred failed local parseObject == nil"];
    }
}

- (void)sendNotificationWithData:(NSDictionary *)data
{
    PFPush *message = [[PFPush alloc] init];
    [message setChannel:[[NSString alloc] initWithFormat:@"crew_%@", [self objectID]]];
    [message setData:data];
    [message sendPushInBackground];
    
}
    
// CCCrew methods
- (void)sendNotificationWithMessage:(NSString*)message
{
    NSString *channelName = [[NSString alloc] initWithFormat:@"crew_%@", [self objectID]];
    [PFPush sendPushMessageToChannelInBackground:channelName
                                     withMessage:message block:^(BOOL succeeded, NSError *error) 
    {
        if(error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to send notification to crew %d: %@", [self objectID], [error localizedDescription]];   
        }
                            
    }];
}

- (void)subscribeToNotifications
{
    NSString *channelName = [[NSString alloc] initWithFormat:@"crew_%@", [self objectID]];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{  
        @synchronized([[[CCCoreManager sharedInstance] server] currentUser])
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
   NSString *channelName = [[NSString alloc] initWithFormat:@"crew_%@", [self objectID]];
    [PFPush unsubscribeFromChannelInBackground:channelName block:^(BOOL succeeded, NSError *error)
    {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to unsubscribe to crew channel: %@", [error localizedDescription]];
        }
        else 
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Unsubcribed from crew %@", [self objectID]];
        }
    }];
}

- (Boolean)containsMember:(id<CCUser>)user 
{    
    for (int membersIndex = 0; membersIndex < [members count]; membersIndex++)
    {
        if ([[[members objectAtIndex:membersIndex]objectID] isEqualToString:[user objectID]])
             return YES;
    }
             
    return NO;
}

- (Boolean)memberInvited:(id<CCUser>)user
{
    for (PFObject *invite in pfInvites)
    {
        if ([[[invite objectForKey:@"userInvited"]  objectId] isEqualToString:[user objectID]])
            return YES;
    }
    
    return NO;
}

- (void)addMember:(id<CCUser>)user
{
    if (![self containsMember:user])
    {
        // Add the User's ID to the array, and push the object
        [members addObject:user];
    }
}

- (void)removeMember:(id<CCUser>)user
{
    // Delete the crew from the user
    for (int currentCrew = 0; currentCrew < [[user crews] count]; currentCrew++)
    {
        if ([[[[user crews] objectAtIndex:currentCrew] objectID] isEqualToString:[self objectID]])
        {
            [[user crews] removeObjectAtIndex:currentCrew];
            break;
        }
    }
    
    // Delete the user from the crew
    for(int currentMember = 0; currentMember < [members count]; currentMember++)
    {
        if([[[members objectAtIndex:currentMember] objectID] isEqualToString:[[[[CCCoreManager sharedInstance] server] currentUser] objectID]])
        {
            [members removeObjectAtIndex:currentMember];
            break;
        }
    }
}

- (void)loadVideosWithNewThread:(Boolean)useNewThread
{
    PFQuery *query = [PFQuery queryWithClassName:@"Crew"];
    [query getObjectWithId:[self objectID]];
    
    if (useNewThread)
    {
        [query getObjectInBackgroundWithId:[self objectID] block:^(PFObject *object, NSError *error) 
        {
            if (error)
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:[error localizedDescription]];
            }
            else 
            {
                [self setParseObject:object];     
                if ([[[self parseObject] objectForKey:@"videos"] class] != [NSNull class])
                {
                    [self initializeVideosWithParseResponse:[[self parseObject] objectForKey:@"videos"]];
                }
                else 
                {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Crew's video object was null.  Skipping."];                     
                }
            }

        }];
    }
    else 
    {
        [self setParseObject:[query getObjectWithId:[self objectID]]];
        [self initializeVideosWithParseResponse:[[self parseObject] objectForKey:@"videos"]];        
    }
}

- (void)initializeVideosWithParseResponse:(NSArray *)videoData
{
    for(int currentVideo = 0; currentVideo < [videoData count]; currentVideo++)
    {
        // Allocate a new CCParseVideo object and save it in this CCParseCrew's array
        [videos addObject:[[CCParseVideo alloc] initWithData:[videoData objectAtIndex:currentVideo]]];
    }
}

- (void)addVideo:(id<CCVideo>)videoToPost
{
    [[self videos] insertObject:videoToPost atIndex:0];    
}

- (NSArray *)getFriendsNotInCrewFromList:(NSArray *)friendsList
{
    NSMutableArray *friendsNotInCrew = [[NSMutableArray alloc] init];
    
    for(int friendIndex = 0; friendIndex < [friendsList count]; friendIndex++)
    {
        if (![self containsMember:[friendsList objectAtIndex:friendIndex]] && ![self memberInvited:[friendsList objectAtIndex:friendIndex]])
        {
            
            [friendsNotInCrew addObject:[friendsList objectAtIndex:friendIndex]];             
        }
    }
    
    return friendsNotInCrew;
}

- (id<CCVideo>)getVideoForID:(NSString *)videoID
{
    for(id<CCVideo> video in videos)
    {
        if ([[video objectID] isEqualToString:videoID])
            return video;
    }
    
    return nil;
}

// It is assumed that this will be called on the main thread
- (void)notifyDelegatesOfNewVideo:(id<CCVideo>) video
{
    for(id<CCCrewUpdateDelegate> delegate in crewUpdateDelegates)
    {
        [delegate addingVideoToCrew:self videoBeingAdded:video];
    }
}

- (void)addCrewUpdateDelegate:(id<CCCrewUpdateDelegate>) delegate
{
    if (![crewUpdateDelegates containsObject:delegate])
        [crewUpdateDelegates addObject:delegate];
}

- (void)removeCrewUpdateDelegate:(id<CCCrewUpdateDelegate>) delegate
{
    if ([crewUpdateDelegates containsObject:delegate])
        [crewUpdateDelegates removeObject:delegate];
}

@end
