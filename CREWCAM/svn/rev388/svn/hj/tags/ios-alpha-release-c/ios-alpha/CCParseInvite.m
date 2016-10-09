//
//  CCParseInvite.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseInvite.h"

@implementation CCParseInvite

static NSString *className = @"Invite";

// Required CCServerStoredObject methods
- (void)initialize
{
}

// Required CCUser methods
+ (void) createNewInviteToCrewInBackground:(id<CCCrew>) crew forUser:(id<CCUser>) user
{
    PFObject *newInvite = [PFObject objectWithClassName:@"Invite"];
    
    [newInvite setObject:[crew getServerData] forKey:@"crewInvitedTo"];    
    [newInvite setObject:[user getServerData] forKey:@"invitee"];
    [newInvite setObject:[[[[CCCoreManager sharedInstance] server] currentUser] getServerData] forKey:@"invitedBy"];
    
    CCParseInvite *newCCInvite = [[CCParseInvite alloc] initWithServerData:newInvite];
    
    // Add member will push the object after setting the relation
    [newCCInvite pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
        if(error)
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:@"Failed inviting friend to crew" withProperties:nil];
            
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to create invite!"];
        } 
        else
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:@"Invited friend to crew" withProperties:nil];
            
            NSString *newVideoMessage = [[NSString alloc] initWithFormat:@"%@ invited you to the crew \"%@\"!",[[[[CCCoreManager sharedInstance] server] currentUser ] getName], [[newCCInvite getCrewInvitedTo] getName]];
            
            NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:newVideoMessage, @"alert",
                                         [NSNumber numberWithInt:1], @"badge",
                                         [[[[CCCoreManager sharedInstance] server] currentUser ]getObjectID], @"src_User",
                                         [NSNumber numberWithInt:CCInvitePush], @"type",
                                         [newCCInvite getObjectID], @"ID",
                                         nil];
            
            [user sendNotificationWithData:messageData];

        }
    }];
}

- (void) acceptInviteInbackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    // Are we (i.e., the current user) already in the crew?
    if ([CCParseObject isObjectInArray:[self getCrewInvitedTo] arrayOfCCServerStoredObjects:[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews]])
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:@"Deleting invitation that has already been accepted."];
        [self deleteObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
        {
            if (!succeeded)
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to delete invite: %@", [error localizedDescription]];
            }
            else 
            {
                [[[[CCCoreManager sharedInstance] server] currentUser] removeInviteLocally:self];
                [[[[CCCoreManager sharedInstance] server] currentUser] addUserToCrewLocally:[self getCrewInvitedTo]];
                [[CCCoreManager sharedInstance] recordMetricEvent:@"Left crew" withProperties:nil];
            }
            
            OSAtomicTestAndClear(YES, &isObjectBusy);
            
            if (block)
                block(succeeded, error);                             
        }];

    }
    else 
    {
        [[self getCrewInvitedTo] addMemberInBackground:[[[CCCoreManager sharedInstance] server] currentUser] withBlockOrNil:^(BOOL succeeded, NSError *error) 
         {
             if (succeeded)
             {
                 // Update the invite
                 [self deleteObjectWithBlockOrNil:nil];
                 [[[[CCCoreManager sharedInstance] server] currentUser] removeInviteLocally:self];
                 [[CCCoreManager sharedInstance] recordMetricEvent:@"Joined crew" withProperties:nil];
             }
             else
             {
                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error accepting invite: %@", [error localizedDescription]];
             }
             
             OSAtomicTestAndClear(YES, &isObjectBusy);
             
             if (block)
                 block(succeeded, error);                 
         }]; 
    }    
}

- (void) deleteObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    [super deleteObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
        if (succeeded)
            [[[[CCCoreManager sharedInstance] server] currentUser] removeInviteLocally:self];
        
        if (block)
            block(succeeded, error);
    }];
}

- (id<CCUser>) getUserInvitedBy
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[CCParseUser alloc] initWithServerData:[[self parseObject] objectForKey:@"invitedBy"]];
}

- (id<CCUser>) getUserInvited
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[CCParseUser alloc] initWithServerData:[[self parseObject] objectForKey:@"invitee"]];
}

- (id<CCCrew>) getCrewInvitedTo
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[CCParseCrew alloc] initWithServerData:[[self parseObject] objectForKey:@"crewInvitedTo"]];
}

@end
