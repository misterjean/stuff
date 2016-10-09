//
//  CCBasePerson.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCUser.h"
#import "CCCrew.h"

typedef enum {
    ccPersonTypeContact,
    ccPersonTypeFacebook,
} ccPersonTypes;

@interface CCBasePerson : NSObject

@property (strong, nonatomic) NSString    *firstName;
@property (strong, nonatomic) NSString    *lastName;
@property (strong, nonatomic) NSString    *uniqueID;
@property (strong, nonatomic) id<CCUser>  ccUser;
@property ccPersonTypes                   personType;

+ (id) initWithCCUser:(id<CCUser>) user;
- (id) initWithCCUser:(id<CCUser>) user;
- (id) initWithFirstName:(NSString *) usersFirstName andLastName:(NSString *) usersLastName andUniqueID:(NSString *) usersUniqueID;
- (NSString *) getFirstName;
- (NSString *) getLastName;
- (NSString *) getName;
- (NSString *) getUniqueID;
- (NSString *) getEmailAddress;
- (NSString *) getPhoneNumber;
- (BOOL) getIsCrewcamMember;

@end
