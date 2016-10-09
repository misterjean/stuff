//
//  CCBasePerson.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBasePerson.h"
#import "CCFacebookPerson.h"
#import "CCContactListPerson.h"
#import "CCCoreManager.h"

@implementation CCBasePerson

@synthesize firstName;
@synthesize lastName;
@synthesize uniqueID;
@synthesize ccUser;
@synthesize personType;

+ (id) initWithCCUser:(id<CCUser>) user
{
    if ([user getFacebookID] != nil)
    {
        return [[CCFacebookPerson alloc] initWithCCUser:user];
    }
    else 
    {
        return [[CCContactListPerson alloc] initWithCCUser:user];
    }
            
}

- (id) initWithCCUser:(id<CCUser>) user
{
    self = [super init];
    
    if (self)
    {
        [self setCcUser:user];
    }
    
    return self; 
}

- (id) initWithFirstName:(NSString *) usersFirstName andLastName:(NSString *) usersLastName andUniqueID:(NSString *) usersUniqueID
{
    self = [super init];
    
    if (self)
    {
        [self setFirstName:usersFirstName];
        [self setLastName:usersLastName];
    }
    
    return self;
}

- (NSString *) getFirstName
{
    if (ccUser)
        return [ccUser getFirstName];
    
    return firstName;
}

- (NSString *) getLastName
{
    if (ccUser)
        return [ccUser getLastName];
    
    return lastName;
}

- (NSString *) getName
{
    return [NSString stringWithFormat:@"%@ %@", [self getFirstName], [self getLastName]];
}

- (NSString *) getUniqueID
{
    if (ccUser)
        return [ccUser getUserID];
    
    return nil;
}

- (NSString *) getEmailAddress
{
    return nil;
}

- (NSString *) getPhoneNumber
{
    return nil;
}

- (BOOL) getIsCrewcamMember
{
    return (ccUser != nil);
}

@end
