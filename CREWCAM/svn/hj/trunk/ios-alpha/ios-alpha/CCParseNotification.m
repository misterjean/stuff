//
//  CCParseNotification.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseNotification.h"

@implementation CCParseNotification

- (void)initialize
{
}

+ (id<CCNotification>) createNewNotificationInBackgroundWithType:(ccNotificationTypes) notificationType andTargetUser:(id<CCUser>) targetUser andSourceUser:(id<CCUser>) sourceUser andTargetObject:(id<CCServerStoredObject>) targetObject andTargetCrewOrNil:(id<CCCrew>) targetCrew andMessage:(NSString *) message
{
    PFObject *notificationObject = [PFObject objectWithClassName:@"Notification"];
    [notificationObject setObject:[NSNumber numberWithInt:notificationType] forKey:@"notificationType"];
    [notificationObject setObject:[targetUser getServerData] forKey:@"targetUser"];    
    [notificationObject setObject:[targetUser getServerData] forKey:@"targetUser"];
    [notificationObject setObject:[sourceUser getServerData] forKey:@"sourceUser"];    
    [notificationObject setObject:[targetObject getObjectID] forKey:@"targetObjectId"];        
    [notificationObject setObject:message forKey:@"message"];
    
    if (targetCrew)
        [notificationObject setObject:[targetCrew getObjectID] forKey:@"targetCrewObjectId"];
    
    CCParseNotification *parseNotification = [[CCParseNotification alloc] initWithServerData:notificationObject];
    [parseNotification pushObjectWithBlockOrNil:nil];
    return parseNotification;
}

- (ccNotificationTypes) getNotificationType
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[[self getServerData] objectForKey:@"notificationType"] intValue];
}

- (id<CCUser>) getTargetUser
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    if (!targetUser)
    {
        targetUser = [[CCParseUser alloc] initWithServerData:[[self getServerData] objectForKey:@"targetUser"]];
    }
        
    return targetUser;
}

- (id<CCUser>) getSourceUser
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    if (!sourceUser)
    {
        sourceUser = [[CCParseUser alloc] initWithServerData:[[self getServerData] objectForKey:@"sourceUser"]];
    }
    
    return sourceUser;
}

- (NSString *) getTargetObjectId
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self getServerData] objectForKey:@"targetObjectId"];
}

- (NSString *) getNotificationMessage
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self getServerData] objectForKey:@"message"];
}

- (NSString *) getTargetCrewObjectID
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self getServerData] objectForKey:@"targetCrewObjectId"];

}


@end
