//
//  CCParseFriendRequest.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-10.
//
//

#import "CCParseFriendRequest.h"

@implementation CCParseFriendRequest

+ (void) createNewFriendRequestInBackgroundForCCUser:(id<CCUser>)requestedPerson byCCUser:(id<CCUser>)inviter andIsPreAccepted:(BOOL) isPreAccepted withBlockOrNil:(CCBooleanResultBlock)block
{
    PFObject *newFriendRequest = [PFObject objectWithClassName:@"FriendRequest"];
    
    [newFriendRequest setObject:[inviter getServerData] forKey:@"personInvitedBy"];
    [newFriendRequest setObject:[requestedPerson getServerData] forKey:@"personInvited"];
    
    if (isPreAccepted)
        [newFriendRequest setObject:[NSNumber numberWithBool:YES] forKey:@"isAccepted"];
    
    CCParseFriendRequest *newCCFriendRequest = [[CCParseFriendRequest alloc] initWithServerData:newFriendRequest];
    
#warning Ensure this request doesn't exist already
    
    // Add member will push the object after setting the relation
    [newCCFriendRequest pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error)
     {
         if(error)
         {
             [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_SENDING_FRIEND_REQUEST withProperties:nil];
             
             [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to create friend request!"];
             
             if (block)
                 block (NO, error);
         }
         else
         {
             [newCCFriendRequest sendPushNotificationForRequest:newCCFriendRequest];
             [newCCFriendRequest createCrewcamNotificationForRequest:newCCFriendRequest];
         }
     }];
}

+ (void) loadSingleFriendRequestInBackgroundForObjectId:(NSString *) objectId withBlockOrNil:(CCFriendRequestResultBlock) block
{
    PFQuery *requestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
    [requestQuery includeKey:@"personInvited"];
    [requestQuery includeKey:@"personInvitedBy"];
    [requestQuery getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        CCParseFriendRequest *thisCCFriendRequest;
        
        if (object)
        {
            thisCCFriendRequest = [[CCParseFriendRequest alloc] initWithServerData:object];
        }
        
        if (block)
            block(thisCCFriendRequest, error);
    }];
}

- (void) sendPushNotificationForRequest:(CCParseFriendRequest *) request
{
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_SENT_FRIEND_REQUEST withProperties:nil];
    
    NSString *friendRequestMessage = [[NSString alloc] initWithFormat:@"%@ has sent you a friend request!", [[request getCCUserThatRequested] getName]];
    
    NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 friendRequestMessage, @"alert",
                                 [NSNumber numberWithInt:1], @"badge",
                                 [[request getCCUserThatRequested] getObjectID], @"src_User",
                                 [NSNumber numberWithInt:ccFriendRequestPushNotification], @"type",
                                 //                  [[newCCFriendRequest getUserInvited] getObjectID], @"ID",
                                 nil];
    
    [[request getCCUserThatIsRequestee] sendNotificationWithData:messageData];
}

- (void) createCrewcamNotificationForRequest:(CCParseFriendRequest *) request
{
    [CCParseNotification createNewNotificationInBackgroundWithType:ccFriendRequestNotification
                                                     andTargetUser:[request getCCUserThatIsRequestee]
                                                     andSourceUser:[request getCCUserThatRequested]
                                                   andTargetObject:request
                                                andTargetCrewOrNil:nil
                                                        andMessage:[[NSString alloc] initWithFormat:@"%@ has sent you a friend request!", [[request getCCUserThatRequested] getName]]];
}

- (void) initialize
{
    
}

- (void) acceptInviteInBackgroundWithBlockOrNil:(CCBooleanResultBlock)block
{
    id<CCUser> currentUser = [[[CCCoreManager sharedInstance] server] currentUser];

    if ([[currentUser getObjectID] isEqualToString:[[self getCCUserThatIsRequestee] getObjectID]])
    {
        // We simply need to add the "has accepted" bool and add the friend
        [self setHasRequestBeenAcceptedByRequestee:YES];
        
        [currentUser addFriendInBackground:[self getCCUserThatRequested] withBlockOrNil:^(BOOL succeeded, NSError *error) {
#warning KISSMetrics!
            
            if (error)
            {
#warning Log error messages
                if (block)
                    block(NO, error);
                
                return;
            }
            
            NSString *message = [NSString stringWithFormat:@"%@ accepted your friend request!", [[self getCCUserThatIsRequestee] getName]];
            
            NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                         message, @"alert",
                                         [[[[CCCoreManager sharedInstance] server] currentUser ] getObjectID], @"src_User",
                                         [NSNumber numberWithInt:ccFriendRequestAcceptedPushNotification], @"type",
                                         [self getObjectID], @"ID",
                                         nil];
                        
            [[self getCCUserThatRequested] sendNotificationWithData:messageData];
            
            [CCParseNotification createNewNotificationInBackgroundWithType:ccFriendRequestAcceptedNotification
                                                             andTargetUser:[self getCCUserThatRequested]
                                                             andSourceUser:[self getCCUserThatIsRequestee]
                                                           andTargetObject:self
                                                        andTargetCrewOrNil:nil
                                                                andMessage:message];
            
            [self pushObjectWithBlockOrNil:nil];
            
            if (block)
                block(YES, nil);
        }];
    }
    else
    {
        // We should never get here
    }
}

- (BOOL) getHasRequestBeenAcceptedByRequestee
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self getServerData] objectForKey:@"isAccepted"] boolValue];
}

- (void) setHasRequestBeenAcceptedByRequestee:(BOOL) hasAccepted
{
    [[self getServerData] setObject:[NSNumber numberWithBool:hasAccepted] forKey:@"isAccepted"];
}

- (id<CCUser>) getCCUserThatIsRequestee
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[CCParseUser alloc] initWithServerData:[[self getServerData] objectForKey:@"personInvited"]];
}

- (id<CCUser>) getCCUserThatRequested
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[CCParseUser alloc] initWithServerData:[[self getServerData] objectForKey:@"personInvitedBy"]];
}

@end
