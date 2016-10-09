//
//  CCParseUser.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "CCUser.h"
#import "CCParseObject.h"
#import "CCParseCrew.h"
#import "CCCoreManager.h"
#import "CCParseInvite.h"

@interface CCParseUser : CCParseObject <CCUser>

- (id) initWithData:(PFUser *) userData;

@end
