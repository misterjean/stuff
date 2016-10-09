//
//  CCParseCrew.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseCrew.h"

@implementation CCParseCrew

// CCServerStoredObject properties
@synthesize name;
@synthesize objectID;

// CCCrew properties
@synthesize members;
@synthesize creadedDate;
@synthesize securitySetting;
@synthesize videos;

- (id) initWithData:(PFObject *) crewData
{   
    self = [super initWithData:crewData];
    
    if (self != nil)    
    {
        members = [[NSMutableArray alloc] init];
        videos = [[NSMutableArray alloc] init];
        
#warning See the warning in loadCrewsWithNewThread for CCParseCrew        
        [self setParseObject:crewData];
        [self setObjectID:[crewData     objectId]];
        [self setName:[crewData         objectForKey:@"crewName"]];
        
        NSArray *tempVideos = [[NSArray alloc] initWithArray:(NSArray *)[crewData objectForKey:@"videos"]];
        NSMutableArray *videoObjectIds = [[NSMutableArray alloc] init];
        for (int tempVideosIndex = 0; tempVideosIndex < [tempVideos count]; tempVideosIndex++) 
        {
            PFObject *tempPFObject = [(NSArray *)[crewData objectForKey:@"videos"] objectAtIndex:tempVideosIndex];
            [videoObjectIds addObject:tempPFObject.objectId];
        }
        
        PFQuery *queryOnVideos = [PFQuery queryWithClassName:@"Video"];
        [queryOnVideos orderByDescending:@"createdAt"];
        [queryOnVideos whereKey:@"objectId" containedIn:videoObjectIds];
        [queryOnVideos includeKey:@"theOwner"];
        [queryOnVideos setLimit:10];

        [members addObjectsFromArray:[crewData objectForKey:@"crewMembers"]];
    
        NSError *error;
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

    return self;
    
}

- (id<CCCrew>)initLocalCrewWithName:(NSString *)crewName
{
    self = [super init];
    
    if (self != nil)
    {
        members = [[NSMutableArray alloc] init];
        videos = [[NSMutableArray alloc] init];
        
        [self setParseObject:[[PFObject alloc] initWithClassName:@"Crew"]];
        [self setName:crewName];
    }
    
    return self;
}


// CCServerStoredObject methods
- (void)pushObjectWithNewThread:(Boolean)useNewThread delegateOrNil:(id<CCConnectorPostObjectCompleteDelegate>)delegateOrNil
{
    NSError *error;   
    
    if (members != nil)
    {
        [[self parseObject] setObject:[[NSArray alloc] initWithArray:members]  forKey:@"crewMembers"];
        
    }
    if (videos != nil)
    {
        NSArray *parseVideos = [[NSArray alloc] initWithArray:[self getArrayOfPFObjectsFromObjects:videos]];
        
        if (parseVideos != nil)
        {
            [[self parseObject] setObject:parseVideos  forKey:@"videos"];
        }
        
    }
    
    [[self parseObject] setObject:name     forKey:@"crewName"];
    
    if (useNewThread)
    {
        [[self parseObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
        {
            if (error)
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to push CCParseCrew: %@", [error localizedDescription]];
                return;
            } 
            else
            {
                [self setObjectID:[[self parseObject] objectId]];
                
                if (delegateOrNil != nil)
                    [delegateOrNil objectPostSuccessWithType:ccCrew];
            }
        }];
    }
    else
    {
    
        [[self parseObject] save:&error];
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:[error localizedDescription], nil];
            return;
        }   
        else 
        {
            [self setObjectID:[[self parseObject] objectId]];
            
            if (delegateOrNil != nil)
                [delegateOrNil objectPostSuccessWithType:ccCrew];
        }
    }
}

- (void)pullObjectWithNewThread:(Boolean)useNewThread
{
    
}

// CCCrew methods
- (void)sendNotificationWithMessage:(NSString*)message
{
    NSString *channelName = [[NSString alloc] initWithFormat:@"crew_%@", [self objectID]];
    [PFPush sendPushMessageToChannelInBackground:channelName
                                     withMessage:message block:^(BOOL succeeded, NSError *error) 
    {
          [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to send notification to crew %d: %@", [self objectID], [error localizedDescription]];                               
    }];
}

- (void)subscribeToNotifications
{
    NSString *channelName = [[NSString alloc] initWithFormat:@"crew_%@", [self objectID]];

    [PFPush subscribeToChannelInBackground:channelName block:^(BOOL succeeded, NSError *error) 
    {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to subscribe to crew channel: %@", [error localizedDescription]];
        }
    }];
}

- (Boolean)containsMember:(id<CCUser>)user 
{    
    for(PFObject *member in members)
    {
        if ([[member objectId] isEqualToString:[user objectID]])
             return YES;
    }
             
    return NO;
}

- (void)addMember:(id<CCUser>)user useNewThread:(Boolean)useNewThread
{
    if (![self containsMember:user])
    {
        // Add the User's ID to the array, and push the object
        [members addObject:[PFUser objectWithoutDataWithClassName:@"User" objectId:[user objectID]]];
    }
}

- (void)removeMember:(id<CCUser>)user useNewThread:(Boolean)useNewThread
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
        if([[[members objectAtIndex:currentMember] objectId] isEqualToString:[[[CCCoreManager sharedInstance] currentUser] objectID]])
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
        if (![self containsMember:[friendsList objectAtIndex:friendIndex]])
            [friendsNotInCrew addObject:[friendsList objectAtIndex:friendIndex]];             
    }
    
    return friendsNotInCrew;
}

@end
