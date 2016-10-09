//
//  CCFriendRequest.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-10.
//
//

#import <Foundation/Foundation.h>
#import "CCServerStoredObject.h"
#import "CCUser.h"
#import "CCConstants.h"

@protocol CCFriendRequest <CCServerStoredObject>

+ (void) createNewFriendRequestInBackgroundForCCUser:(id<CCUser>)requestedPerson byCCUser:(id<CCUser>)inviter andIsPreAccepted:(BOOL) isPreAccepted withBlockOrNil:(CCBooleanResultBlock)block;
+ (void) loadSingleFriendRequestInBackgroundForObjectId:(NSString *) objectId withBlockOrNil:(CCFriendRequestResultBlock) block;
- (void) acceptInviteInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;

// Getter/Setter methods
- (BOOL) getHasRequestBeenAcceptedByRequestee;
- (void) setHasRequestBeenAcceptedByRequestee:(BOOL) hasAccepted;

- (id<CCUser>) getCCUserThatIsRequestee;

- (id<CCUser>) getCCUserThatRequested;

@end
