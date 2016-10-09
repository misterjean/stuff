//
//  CCParseLike.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLike.h"
#import <Parse/Parse.h>
#import "CCParseObject.h"

@interface CCParseLike : CCParseObject <CCLike>

- (id) initWithData:(PFObject *) likeData;

@end
