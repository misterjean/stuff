//
//  CCParseLike.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseLike.h"

@implementation CCParseLike

// CCServerStoredObject properties
@synthesize name;
@synthesize objectID;

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

// CCServerStoredObject methods
- (void)pushObjectWithNewThread:(Boolean)useNewThread delegateOrNil:(id<CCConnectorPostObjectCompleteDelegate>)delegateOrNil
{
    
}

- (void)pullObjectWithNewThread:(Boolean)useNewThread
{
    
}

// CCLike methods
- (void)unlike
{
    
}

@end
