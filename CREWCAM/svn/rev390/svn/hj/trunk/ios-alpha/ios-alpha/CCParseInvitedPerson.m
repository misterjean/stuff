//
//  CCParseInvitedPerson.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseInvitedPerson.h"

@implementation CCParseInvitedPerson

+ (void) createNewInvitedPersonInBackgroundFromPerson:(CCBasePerson *) person invitor:(id<CCUser>)invitor toCrews:(NSArray *) ccCrews withBlock:(CCBooleanResultBlock) block
{
    // First, check if this person, either via phone number or FacebookID has already been invited:
    PFQuery *checkForUserQuery = [PFQuery queryWithClassName:@"InvitedPerson"];
    
    switch ([person personType]) {
            
        case ccPersonTypeContact:
            if ([person getPhoneNumber])
            {
                [checkForUserQuery whereKey:@"phoneNumber" equalTo:[person getPhoneNumber]];
            }
            else if ([person getEmailAddress])
            {
                [checkForUserQuery whereKey:@"emailAddress" equalTo:[person getEmailAddress]];
            }
            break;
            
        case ccPersonTypeFacebook:
            [checkForUserQuery whereKey:@"facebookId" equalTo:[person getUniqueID]];
            break;
    }
    
    [checkForUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object)
        {
            if (block)
                block(YES, nil);
            return;
        }
        else 
        {
            // We couldn't find the person by his unique ID, create a new one:
            PFObject *pfInvitedPerson = [PFObject objectWithClassName:@"InvitedPerson"];
            
            // Save the name
            [pfInvitedPerson setObject:[person getFirstName] forKey:@"firstName"];
            [pfInvitedPerson setObject:[person getLastName] forKey:@"lastName"];    
            
            // Save the unique ID
            switch ([person personType]) {
                case ccPersonTypeContact:
                    if ([person getEmailAddress])
                    {
                        [pfInvitedPerson setObject:[person getEmailAddress] forKey:@"emailAddress"];
                    }
                    if ([person getPhoneNumber])
                    {
                        [pfInvitedPerson setObject:[person getPhoneNumber] forKey:@"phoneNumber"];
                    }
                    break;
                case ccPersonTypeFacebook:
                    [pfInvitedPerson setObject:[person getUniqueID] forKey:@"facebookId"];                            
                    break;
                default:
                    break;
            }
            
            // Save the invitor
            [pfInvitedPerson setObject:[invitor getServerData] forKey:@"invitedBy"];
            
            // Save the crews I'm invited to
            PFRelation *crewsRelations = [pfInvitedPerson relationforKey:@"crewsInvitedTo"];
            
            for(id<CCCrew> crew in ccCrews)
            {
                [crewsRelations addObject:[crew getServerData]];
            }
            
            // Save the whole shebang
            [pfInvitedPerson saveEventually:^(BOOL succeeded, NSError *error) 
             {
                 if (block)
                     block(succeeded, error);
             }];

        }
    }];
    }

@end
