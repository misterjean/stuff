//
//  CCInvitedPerson.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCServerStoredObject.h"
#import "CCBasePerson.h"

@protocol CCInvitedPerson <CCServerStoredObject>

// Factory methods
+ (void) createNewInvitedPersonInBackgroundFromPerson:(CCBasePerson *) person invitor:(id<CCUser>)invitor toCrews:(NSArray *) ccCrews withBlock:(CCBooleanResultBlock) block;

@end
