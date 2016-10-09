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

- (id) initWithFirstName:(NSString *) usersFirstName andLastName:(NSString *) usersLastName andPhoneNumber:(NSString *) usersPhoneNumber
{
    self = [super initWithFirstName:usersFirstName andLastName:usersLastName andUniqueID:usersPhoneNumber];
    
    if (self)
    {
        [self setPersonType:ccPersonTypeContactWithNumber];
        phoneNumber = usersPhoneNumber;
    }
    
    return self;
}

- (id) initWithFirstName:(NSString *) usersFirstName andLastName:(NSString *) usersLastName andEmailAddress:(NSString *) usersEmailAddress
{
    self = [super initWithFirstName:usersFirstName andLastName:usersLastName andUniqueID:usersEmailAddress];
    
    if (self)
    {
        [self setPersonType:ccPersonTypeContactWithEmail];
        emailAddress = usersEmailAddress;
    }
    
    return self;
}


- (NSString *) getUniqueID
{
    if ([self ccUser])
    {
        if (![[[self ccUser] getPhoneNumber] isEqualToString:@""])
            return [[self ccUser] getPhoneNumber];
        
        return [[self ccUser] getEmailAddress];
    }
    
    if (phoneNumber)
        return phoneNumber;
    
    return emailAddress;
}


@end
