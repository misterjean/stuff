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

@protocol CCInvite <CCServerStoredObject>

@required

// Factory methods
+ (void) createNewInviteToCrewInBackground:(id<CCCrew>) crew forUser:(id<CCUser>) user fromUserOrNil:(id<CCUser>) invitor withNotification:(BOOL)sendNotification;

// Utitilty methods
- (void) acceptInviteInbackgroundWithBlockOrNil:(CCBooleanResultBlock) block;

// Getter/Setter methods
- (id<CCUser>) getUserInvitedBy;
- (id<CCUser>) getUserInvited;
- (id<CCCrew>) getCrewInvitedTo;

@end
