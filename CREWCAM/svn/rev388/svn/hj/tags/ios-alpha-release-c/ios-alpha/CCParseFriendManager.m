//
//  CCFriendManager.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseFriendManager.h"

@implementation CCParseFriendManager
@synthesize ccFriendConnectors;

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        ccFriendConnectors = [[NSMutableArray alloc] init];
        contactListFriendConnector = [[CCContactListFriendConnector alloc] init];
        facebookFriendConnector = [[CCFacebookFriendConnector alloc] init];
        isLoadingFriends = NO;
        isLoadingCrews = NO;
    }
    
    return self;
}

- (void) removeCrewcamPFUsers:(NSArray *) pfUsers fromArrayOfCCBasePeople:(NSMutableArray *) ccBasePeople
{
    for(PFUser *person in pfUsers)
    {
        CCParseUser *ccPerson = [[CCParseUser alloc] initWithServerData:person];
        // Find the object to remove
        for (CCBasePerson *friend in ccBasePeople)
        {
            if ([[friend getUniqueID] isEqualToString:[ccPerson getPhoneNumber]] || [[friend getUniqueID] isEqualToString:[ccPerson getFacebookID]])
            {                        
                [ccBasePeople removeObject:friend]; 
                break;
            }
        }
    }
}

// Required functions
- (void) loadContactListPeopleInBackgroundWithBlock:(CCArrayResultBlock) block
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *contactListPeople = [[NSMutableArray alloc] initWithArray:[self sortArrayOfPeopleAlphabetically:[contactListFriendConnector loadFriends]]];        
        
        // We need to remove Address Book people that are already on the App:
        PFQuery *crewcamUserQuery = [PFUser query];
        [crewcamUserQuery whereKey:@"phoneNumber" containedIn:[self getArrayOfIDsFromFriends:contactListPeople]];
        
        NSError *error;
        
        NSArray *peopleThatAreAlreadyMembers = [crewcamUserQuery findObjects:&error];
        
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load people that are already members: %@", [error localizedDescription]];
        }
        else 
        {
            // Remove friends that are Crewcam members
            [self removeCrewcamPFUsers:peopleThatAreAlreadyMembers fromArrayOfCCBasePeople:contactListPeople];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{            
            block(contactListPeople, nil);
        });
    });
}

- (void) loadFacebookFriendPeopleInBackgroundWithBlock:(CCArrayResultBlock) block
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{           
        
        NSMutableArray *facebookFriends = [[NSMutableArray alloc] initWithArray:[self sortArrayOfPeopleAlphabetically:[facebookFriendConnector loadFriends]]];
        
        // We need to remove Facebook friends that are already on the App
        PFQuery *crewcamUserQuery = [PFUser query];
        [crewcamUserQuery whereKey:@"facebookId" containedIn:[self getArrayOfIDsFromFriends:facebookFriends]];
        
        NSError *error;
        
        NSArray *peopleThatAreAlreadyMembers = [crewcamUserQuery findObjects:&error];
        
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load people that are already members: %@", [error localizedDescription]];
        }
        else 
        {
            // Remove friends that are Crewcam members
            [self removeCrewcamPFUsers:peopleThatAreAlreadyMembers fromArrayOfCCBasePeople:facebookFriends];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{            
            block(facebookFriends, nil);
        });
    });
}

- (void) loadCrewcamFriendsInBackgroundWithBlock:(CCArrayResultBlock) block
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{               
        
        NSMutableArray *ccFriends;
        NSArray *facebookFriendIDs = [self getArrayOfIDsFromFriends:[facebookFriendConnector loadFriends]];
        NSArray *contactsPhoneNumbers = [self getArrayOfIDsFromFriends:[contactListFriendConnector loadFriends]];
        
        // Find all the users that are Facebook friends
        PFQuery *facebookUsersQuery = [PFUser query];                
        [facebookUsersQuery whereKey:@"facebookId" containedIn:facebookFriendIDs];
        
        // Find all the users that are in my contacts
        PFQuery *contactsUsersQuery = [PFUser query];                
        [contactsUsersQuery whereKey:@"phoneNumber" containedIn:contactsPhoneNumbers];
        
        PFQuery *userQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:facebookUsersQuery, contactsUsersQuery, nil]];
        
        NSError *error;
        NSArray *pfFriends = [userQuery findObjects:&error];
        
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load friends: %@", [error localizedDescription]];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                block(ccFriends, error);
            });
        }
        else 
        {
            NSMutableArray *ccFriends = [[NSMutableArray alloc] initWithCapacity:[pfFriends count]];
            
            // Allocate CCUsers and CCBasePersons
            for(PFObject *user in pfFriends)
            {
                [ccFriends addObject:[[CCBasePerson alloc] initWithCCUser:[[CCParseUser alloc] initWithServerData:user]]];
            }
            
            NSArray *sortedCCFriends = [self sortArrayOfPeopleAlphabetically:ccFriends];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                block(sortedCCFriends, nil);
            });
        }
        
        
    });
}

- (void) loadFriendsPublicCrewsInBackgroundWithBlock:(CCArrayResultBlock) block
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *friendsCrews;
        NSArray *contacts = [contactListFriendConnector loadFriends];
        NSArray *facebookFriends = [facebookFriendConnector loadFriends];
       
        // Find all the users that are Facebook friends
        PFQuery *facebookUsersQuery = [PFUser query];                
        [facebookUsersQuery whereKey:@"facebookId" containedIn:[self getArrayOfIDsFromFriends:facebookFriends]];
        
        // Find all the users that are in my contacts
        PFQuery *contactsUsersQuery = [PFUser query];                
        [contactsUsersQuery whereKey:@"phoneNumber" containedIn:[self getArrayOfIDsFromFriends:contacts]];
       
        PFQuery *userQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:facebookUsersQuery, contactsUsersQuery, nil]];
       
        // Find all the crews that have members matching the previous query
        PFQuery *friendsCrewsQuery = [PFQuery queryWithClassName:@"Crew"];
       
        // Crews that my friends are in
        [friendsCrewsQuery whereKey:@"crewMembers" matchesQuery:userQuery];        
       
        // Crews that are public
        [friendsCrewsQuery whereKey:@"securitySetting" notEqualTo:[NSNumber numberWithInt:1]];
       
        // Crews that the current user is not a member of
        [friendsCrewsQuery whereKey:@"objectId" notContainedIn:[[[[CCCoreManager sharedInstance] server] currentUser] getArrayOfCrewIDs]];
        
        // Sort by name
        [friendsCrewsQuery orderByAscending:@"crewName"];
       
        NSError *error;
        NSArray *objects = [friendsCrewsQuery findObjects:&error];
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to load crews from Facebook friends: %@", [error localizedDescription]]; 
        }
        else 
        {
            friendsCrews = [[NSMutableArray alloc] init];
            for(PFObject *object in objects)
            {
                [friendsCrews addObject:[[CCParseCrew alloc] initWithServerData:object]];
            }
        }
       
        dispatch_async( dispatch_get_main_queue(), ^{ 
            if (block)
                block(friendsCrews, error);            
        });
    });
}

// Helper functions

- (NSArray *)getArrayOfIDsFromFriends:(NSArray *)friends
{
    NSMutableArray *facebookIds = [[NSMutableArray alloc] init];
    
    for (CCBasePerson *facebookFriend in friends)
    {
        [facebookIds addObject:[facebookFriend getUniqueID]];
    }
    
    return [[NSArray alloc] initWithArray:facebookIds];
}

- (NSArray *) sortArrayOfPeopleAlphabetically:(NSArray *) people
{
    NSMutableArray *sortedPeople = [[NSMutableArray alloc] initWithArray:people];
    [sortedPeople sortUsingComparator:^NSComparisonResult(CCBasePerson *obj1, CCBasePerson *obj2) 
    {
        if ([[obj1 getFirstName] compare:[obj2 getFirstName]] != NSOrderedSame)
        {
            return ([[obj1 getFirstName] compare:[obj2 getFirstName]]);
        }
        else 
        {
            return ([[obj1 getLastName] compare:[obj2 getLastName]]);
        }
    }];
    return sortedPeople;
}

@end
