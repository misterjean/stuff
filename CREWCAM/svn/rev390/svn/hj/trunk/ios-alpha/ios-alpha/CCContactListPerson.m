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

- (id) initWithFirstName:(NSString *) usersFirstName andLastName:(NSString *) usersLastName andPhoneNumber:(NSString *) usersPhoneNumber andEmailAddress:(NSString *) usersEmailAddress
{
    self = [super initWithFirstName:usersFirstName andLastName:usersLastName andUniqueID:usersPhoneNumber];
    
    if (self)
    {
        [self setPersonType:ccPersonTypeContact];
        phoneNumber = usersPhoneNumber;        
        emailAddress = usersEmailAddress;
    }
    
    return self;
}

- (NSString *) getEmailAddress
{
    return emailAddress;
}

- (NSString *) getPhoneNumber
{
    return phoneNumber;
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
