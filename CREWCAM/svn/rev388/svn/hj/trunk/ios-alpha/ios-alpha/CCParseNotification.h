//
//  CCParseNotification.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseObject.h"
#import "CCNotification.h"
#import "CCParseUser.h"

@interface CCParseNotification : CCParseObject <CCNotification>
{
    id<CCUser>  sourceUser;
    id<CCUser>  targetUser;    
}

@end
