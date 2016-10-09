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
+ (void) createNewInviteToCrewInBackground:(id<CCCrew>) crew forUser:(id<CCUser>) user fromUserOrNil:(id<CCUser>) invitor withNotification:(BOOL)sendNotification
{
    PFObject *newInvite = [PFObject objectWithClassName:@"Invite"];
    
    [newInvite setObject:[crew getServerData] forKey:@"crewInvitedTo"];    
    [newInvite setObject:[user getServerData] forKey:@"invitee"];
    if (invitor)
        [newInvite setObject:[invitor getServerData] forKey:@"invitedBy"];
    
    CCParseInvite *newCCInvite = [[CCParseInvite alloc] initWithServerData:newInvite];
    
    // Add member will push the object after setting the relation
    [newCCInvite pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
        if(error)
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_INVITING_FRIEND_TO_CREW withProperties:nil];
            
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to create invite!"];
        } 
        else
        {
            if (sendNotification)
            {
                [[CCCoreManager sharedInstance] recordMetricEvent:CC_INVITED_FRIEND_TO_CREW withProperties:nil];
                
                NSString *newInviteMessage;
                
                if (invitor)
                {
                    newInviteMessage = [[NSString alloc] initWithFormat:@"%@ invited you to the crew \"%@\"!",[invitor getName], [[newCCInvite getCrewInvitedTo] getName]];
                }
                else 
                    newInviteMessage = [[NSString alloc] initWithFormat:@"You have been inivited to the crew \"%@\"!",[[newCCInvite getCrewInvitedTo] getName]];
                
                NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:newInviteMessage, @"alert",
                                             [NSNumber numberWithInt:1], @"badge",
                                             [invitor getObjectID], @"src_User",
                                             [NSNumber numberWithInt:ccInvitePushNotification], @"type",
                                             [[newCCInvite getUserInvited] getObjectID], @"ID",
                                             nil];
                
                [user sendNotificationWithData:messageData];
            }

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
                 [[CCCoreManager sharedInstance] recordMetricEvent:CC_JOINED_CREW_FROM_INVITE withProperties:nil];
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
    
    if (![[self parseObject] objectForKey:@"invitedBy"])
        return nil;
    
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
