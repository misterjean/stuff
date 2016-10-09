//
//  CCParseObject.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseObject.h"

@implementation CCParseObject

@synthesize     parseObject;

- (id) initWithData:(PFObject *) parseData
{
    self = [super init];
    
    if (self != nil)
    {
        parseObject = parseData;
    }
    
    return self;
}

- (void)deleteObjectWithNewThread:(Boolean)useNewThread
{
    if (useNewThread)
    {
        [parseObject deleteInBackground];
    }
    else 
    {
        [parseObject delete];
    }
}

- (NSArray *)getArrayOfPFObjectsFromObjects:(NSArray *)object
{
    NSMutableArray *parseObjects = [[NSMutableArray alloc] init];
    
    for (int currentObject = 0; currentObject < [object count]; currentObject++)
    {                                     
        [parseObjects addObject:[[object objectAtIndex:currentObject] parseObject]];
    }
    
    return [[NSArray alloc] initWithArray:parseObjects];
}

@end
