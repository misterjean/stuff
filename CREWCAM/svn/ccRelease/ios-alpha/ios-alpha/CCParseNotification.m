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

- (void) dealloc
{
    targetUser = nil;
    sourceUser = nil;
}

+ (id<CCNotification>) createNewNotificationInBackgroundWithType:(ccNotificationTypes) notificationType andTargetUser:(id<CCUser>) targetUser andSourceUser:(id<CCUser>) sourceUser andTargetObject:(id<CCServerStoredObject>) targetObject andTargetCrewOrNil:(id<CCCrew>) targetCrew andMessage:(NSString *) message
{
    PFObject *notificationObject = [PFObject objectWithClassName:@"Notification"];
    [notificationObject setObject:[NSNumber numberWithInt:notificationType] forKey:@"notificationType"];
    [notificationObject setObject:[targetUser getServerData] forKey:@"targetUser"];    
    [notificationObject setObject:[sourceUser getServerData] forKey:@"sourceUser"];
    [notificationObject setObject:message forKey:@"message"];
    
    if (targetObject)
        [notificationObject setObject:[targetObject getObjectID] forKey:@"targetObjectId"];
    
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

- (void) setNotificationMessage:(NSString *)message 
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    [[self parseObject] setObject:message forKey:@"message"];
}

- (NSString *) getTargetCrewObjectID
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self getServerData] objectForKey:@"targetCrewObjectId"];

}

- (BOOL) getIsViewed
{
    [self checkForParseDataAndThrowExceptionIfNil];
    return [[[self parseObject] objectForKey:@"viewed"] boolValue];
}

- (BOOL) getIsClicked
{
    [self checkForParseDataAndThrowExceptionIfNil];
    return [[[self parseObject] objectForKey:@"clicked"] boolValue];
}

- (void) setIsViewedWithBlock:(CCBooleanResultBlock)block
{
    [self checkForParseDataAndThrowExceptionIfNil];
    [[self parseObject] setObject:[NSNumber numberWithBool:YES] forKey:@"viewed"];
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed to set Notification as viewed: %@", [error localizedDescription]];
        }
        block(succeeded, error);
    }];
}

- (void) setIsClickedWithBlock:(CCBooleanResultBlock)block
{
    [self checkForParseDataAndThrowExceptionIfNil];
    [[self parseObject] setObject:[NSNumber numberWithBool:YES] forKey:@"clicked"];
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed to set Notification as clicked: %@", [error localizedDescription]];
        }
        block(succeeded, error);
    }];
}


@end
