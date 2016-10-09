//
//  CCContactListPerson.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCContactListPerson.h"
#import "CCCoreManager.h"

@implementation CCContactListPerson

- (id) initWithFirstName:(NSString *) usersFirstName andLastName:(NSString *) usersLastName andUniqueID:(NSString *) usersPhoneNumber
{
    self = [super initWithFirstName:usersFirstName andLastName:usersLastName andUniqueID:usersFirstName];
    
    if (self)
    {
        [self setPersonType:ccPersonTypeContact];
        phoneNumber = usersPhoneNumber;
    }
    
    return self;
}


- (NSString *) getUniqueID
{
    if ([self ccUser])
        return [[self ccUser] getPhoneNumber];
    
    return phoneNumber;
}


@end
