//
//  CCParseLike.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseLike.h"

@implementation CCParseLike

// CCLike properties
@synthesize user;

- (id) initWithData:(PFObject *) likeData
{
    self = [super initWithData:likeData];
    
    if (self != nil)    
    {
        [self setObjectID:[likeData objectForKey:@"objectId"]];
    }    
    
    return self;
}

// CCLike methods
- (void)unlike
{
    
}

@end
