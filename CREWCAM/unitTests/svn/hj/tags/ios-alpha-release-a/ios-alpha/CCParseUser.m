//
//  CCParseUser.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseUser.h"

@implementation CCParseUser

// CCServerStoredObject properties
@synthesize     name;
@synthesize     objectID;

// CCUser properties
@synthesize     userId;
@synthesize     emailAddress;
@synthesize     gender;
@synthesize     firstName;
@synthesize     lastName;
@synthesize     profilePicture;
@synthesize     location;
@synthesize     crews;
@synthesize     facebookId;
@synthesize     ccInvites;

- (id) initWithData:(PFUser *) userData
{
    [userData fetchIfNeeded];
    self = [super initWithData:userData];

    if (self != nil)
    {        
        [self setCrews:[[NSMutableArray alloc] init]]; 
        [self setCcInvites:[[NSMutableArray alloc] init]];
        [self saveParseData:userData];
    }
    
    return self;
}

- (void) saveParseData:(PFUser *) userData
{
    [self setObjectID:[userData                                         objectId]];
    [self setUserId:[userData                                           objectForKey:@"userId"]];    
    [self setEmailAddress:[userData                                     objectForKey:@"emailAddress"]];
    [self setGender:[userData                                           objectForKey:@"gender"]];
    [self setFirstName:[userData                                        objectForKey:@"firstName"]];
    [self setLastName:[userData                                         objectForKey:@"lastName"]];    
    [self setFacebookId:[userData                                       objectForKey:@"facebookId"]];
    [self setName:[[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName]];
}

- (void)setCCInvitesFromParseData:(NSArray *)parseInvites
{
    NSMutableArray *invites = [[NSMutableArray alloc] init];
    
    for(int inviteIndex = 0; inviteIndex < [parseInvites count]; inviteIndex++)
    {
        [invites addObject:[[CCParseInvite alloc] initWithData:[parseInvites objectAtIndex:inviteIndex]]];
    }
    
    [self setCcInvites:invites];
}

- (NSArray *)getParseInvites
{
    NSMutableArray *parseInvites = [[NSMutableArray alloc] init];
    
    for (int inviteIndex = 0; inviteIndex < [ccInvites count]; inviteIndex++)
    {
        [parseInvites addObject:[PFObject objectWithoutDataWithClassName:@"Invite" objectId:[[ccInvites objectAtIndex:inviteIndex] objectID]]];
    }
    
    return parseInvites;
}

- (void)pushObjectWithNewThread:(Boolean)useNewThread delegateOrNil:(id<CCConnectorPostObjectCompleteDelegate>)delegateOrNil
{
    NSError *error;   
    
    if (emailAddress != nil)
        [[self parseObject] setObject:emailAddress  forKey:@"emailAddress"];    
    
    if (gender != nil)
        [[self parseObject] setObject:gender        forKey:@"gender"];        
    
    [[self parseObject] setObject:firstName         forKey:@"firstName"];
    [[self parseObject] setObject:lastName          forKey:@"lastName"];
    
    if (facebookId != nil)
        [[self parseObject] setObject:facebookId  forKey:@"facebookId"];
    
    [[self parseObject] setObject:[self getParseInvites] forKey:@"invites"];
    
    if (useNewThread)
    {
        [[self parseObject] saveInBackground];
        return;
    }
    
    [[self parseObject] save:&error];
    if (error)
    {
        NSLog(@"Error updating user: %@", error);
    }
}

- (void)pullObjectWithNewThread:(Boolean)useNewThread
{
    PFQuery *query = [PFQuery queryForUser];
    [query whereKey:@"objectId" equalTo:objectID];
    
    if (useNewThread)
    {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
        {
            if (error)
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:[error localizedDescription], nil];
            }
            else 
            {
                [self handleNewObjectData:objects];                
            }
        }];
    }
    else 
    {
        NSArray * objects = [query findObjects];        
        
        [self handleNewObjectData:objects];          
    }
}

- (void)handleNewObjectData:(NSArray *)objects
{
    if ([objects count] == 0)
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error retrieving PFUser from database.  Found no matches!"]; 
    }
    else 
    {
        [self saveParseData:[objects objectAtIndex:0]];                
    }  
}

- (void)sendNotificationWithMessage:(NSString *)message
{
    NSString *channelName = [[NSString alloc] initWithFormat:@"user_%@", [self objectID]];
    
    [PFPush sendPushMessageToChannelInBackground:channelName
                                     withMessage:message];
}

#warning We need to be able to do this async. with callbacks.  The GUI threads can't wait for this to finish!
- (void)loadCrewsWithNewThread:(Boolean)useNewThread
{
    PFQuery *query = [PFQuery queryWithClassName:@"Crew"];
    
#warning For some reason includeKey is giving us <null> for related objects.  This forces us to call fetchIfNeeded which is absolutly unreasonable
//    [query includeKey:@"crewMembers"];
    [query includeKey:@"videos"];
    [query includeKey:@"theOwner"];
    [query whereKey:@"crewMembers" equalTo:[PFUser objectWithoutDataWithClassName:@"User" objectId:objectID]];    
    
    if (useNewThread)
    {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
        {            
            if (error)
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:[error localizedDescription], nil];
            }
            else 
            {
                [self initializeCrewsWithParseResponse:objects];
            }
        }];
    }
    else 
    {
        NSError *error;
        NSArray *result = [query findObjects:&error];
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:[error localizedDescription], nil];
        }
        else 
        {  
            [self initializeCrewsWithParseResponse:result];            
        }

    }
}

#warning We need to be able to do this async. with callbacks.  The GUI threads can't wait for this to finish!
- (void)inviteToCrew:(id<CCCrew>)crew useNewThread:(Boolean)useNewThread
{        
    PFObject *invite = [PFObject objectWithClassName:@"Invite"];
    [invite setObject:[PFObject objectWithoutDataWithClassName:@"Crew" objectId:[crew objectID]] forKey:@"crewInvitedTo"];
    [invite setObject:[PFUser currentUser] forKey:
     @"userInvitedBy"];
    [invite setObject:[self parseObject] forKey:
     @"userInvited"];    
    
    if (useNewThread)
    {
        [invite saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
        {
            if (error)
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to save invite: %@", [error localizedDescription]];
            }
            else 
            {                
                [self sendNotificationWithMessage:[[NSString alloc] initWithFormat:@"You've been invited to the crew \"%@\"!", [crew name]]];
                [[self ccInvites] addObject:[[CCParseInvite alloc] initWithData:[invite fetchIfNeeded]]];
            }
            
        }];
    }   
    else 
    {
        NSError *error;
        [invite save:&error];
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to save invite: %@", [error localizedDescription]];
        }
        else 
        {
            PFQuery *getInviteQuery = [PFQuery queryWithClassName:@"Invite"];           
            invite = [getInviteQuery getObjectWithId:[invite objectId]];
            [self sendNotificationWithMessage:[[NSString alloc] initWithFormat:@"You've been invited to the crew \"%@\"!", [crew name]]];
            [[self ccInvites] addObject:[[CCParseInvite alloc] initWithData:[invite fetchIfNeeded]]];
        }
    }    
}

- (void)subscribeToUserChannel
{
    NSString *userChannelName = [[NSString alloc] initWithFormat:@"user_%@", [self objectID]];
    [PFPush subscribeToChannelInBackground:userChannelName block:^(BOOL succeeded, NSError *error) 
     {
         if (error)
         {
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to subscribe to the user's channel: %@", [error localizedDescription]];                         
         }
         else 
         {
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Succesfully subscribed to the user's channel."];
         }
     }];
}

- (void)initializeCrewsWithParseResponse:(NSArray *)crewData
{
    [crews removeAllObjects];
    
    for (int currentCrew = 0; currentCrew < [crewData count]; currentCrew++)
    {
        // Allocate a new CCParseCrew object, and save it in this CCUser's array
        CCParseCrew *crew = [[CCParseCrew alloc] initWithData:[[crewData objectAtIndex:currentCrew] fetchIfNeeded]];
        
        [crew subscribeToNotifications];
        [crews addObject:crew];
    }
}

- (void)initializeInvitesWithParseResponse:(NSArray *)inviteData
{
    [ccInvites removeAllObjects];
    
    for (int inviteIndex = 0; inviteIndex < [inviteData count]; inviteIndex++)
    {
        // Allocate a new CCParseCrew object, and save it in this CCUser's array
        CCParseInvite *invite = [[CCParseInvite alloc] initWithData:[inviteData objectAtIndex:inviteIndex]];
        [ccInvites addObject:invite];
    }
}

- (void)loadInvitesWithNewThread:(Boolean)useNewThread
{
    PFQuery *query = [PFQuery queryWithClassName:@"Invite"];

    [query includeKey:@"crewInvitedTo"];
    [query includeKey:@"userInvited"];
    [query includeKey:@"userInvitedBy"];    
    [query whereKey:@"userInvited" equalTo:[PFUser currentUser]];    
    
    if (useNewThread)
    {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) 
         {            
             if (error)
             {
                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:[error localizedDescription], nil];
             }
             else 
             {
                 [self initializeInvitesWithParseResponse:objects];
             }
         }];
    }
    else 
    {
        NSError *error;
        [query findObjects:&error];
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:[error localizedDescription], nil];
        }
        else 
        {  
            [self initializeInvitesWithParseResponse:[query findObjects]];            
        }
        
    }
}

@end
