//
//  CCContactListPerson.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCBasePerson.h"

@interface CCContactListPerson : CCBasePerson
{
    NSString *phoneNumber;
    NSString *emailAddress;
}

- (id) initWithFirstName:(NSString *) usersFirstName andLastName:(NSString *) usersLastName andPhoneNumber:(NSString *) usersPhoneNumber;
- (id) initWithFirstName:(NSString *) usersFirstName andLastName:(NSString *) usersLastName andEmailAddress:(NSString *) usersEmailAddress;

@end
