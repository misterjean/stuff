//
//  CCFacebookPerson.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCFacebookPerson.h"
#import "CCCoreManager.h"

@implementation CCFacebookPerson

- (id) initWithFirstName:(NSString *) usersFirstName andLastName:(NSString *) usersLastName andUniqueID:(NSString *) usersFacebookID
{
    self = [super initWithFirstName:usersFirstName andLastName:usersLastName andUniqueID:usersFirstName];
    
    if (self)
    {
        [self setPersonType:ccPersonTypeFacebook];        
        facebookID = usersFacebookID;
    }
    
    return self;
}

- (NSString *) getUniqueID
{
    if ([self ccUser])
        return [[self ccUser] getFacebookID];
    
    return facebookID;
}

@end
