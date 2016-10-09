//
//  CCParseInvite.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseInvite.h"

@implementation CCParseInvite

@synthesize name;
@synthesize objectID;

@synthesize userInvitedBy;
@synthesize userInvited;
@synthesize crewInvitedTo;

- (CCParseInvite *) initWithData:(PFObject *)inviteData
{
    self = [super initWithData:inviteData];
    
    if (self != nil)
    {
        [self setUserInvitedBy:[[CCParseUser alloc]initWithData:[inviteData objectForKey:@"userInvitedBy"]]];
        [self setUserInvited:[[CCParseUser alloc]initWithData:[inviteData objectForKey:@"userInvited"]]];        
        [self setCrewInvitedTo:[[CCParseCrew alloc]initWithData:[[inviteData objectForKey:@"crewInvitedTo"] fetchIfNeeded]]];        
        [self setObjectID:[inviteData objectId]];
    }
    
    return self;
}

- (void)pushObjectWithNewThread:(Boolean)useNewThread delegateOrNil:(id<CCConnectorPostObjectCompleteDelegate>)delegateOrNil
{
    
}

- (void)pullObjectWithNewThread:(Boolean)useNewThread
{
    
}

@end
