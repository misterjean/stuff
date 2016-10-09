//
//  CCInvite.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCUser.h"
#import "CCCrew.h"

@protocol CCInviteChangedDelegate

@end

@protocol CCInvite <CCServerStoredObject>

@property (strong, nonatomic) id<CCUser> userInvitedBy;
@property (strong, nonatomic) id<CCUser> userInvited;
@property (strong, nonatomic) id<CCCrew> crewInvitedTo;

@end
