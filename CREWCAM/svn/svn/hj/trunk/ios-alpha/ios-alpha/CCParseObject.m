//
//  CCParseObject.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseObject.h"

@implementation CCParseObject

// Required CCServerStoredObject properties
@synthesize name;
@synthesize objectID;
@synthesize updateListeners;

// CCParseObject properties
@synthesize     parseObject;

// Required CCServerStoredObject default method implementations
- (void)pushObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    
}

- (void)deleteObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    [self notifyListenersThatDeleteIsBeginning];
    [parseObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
    {
        if (error)
        {
            if (block)            
                block(NO, error);
        }
        else 
        {            
            if (block)
                block(YES, nil);
            
            [self notifyListenersThatDeletedHasCompleted];
        }
    }];
}

- (void)pullObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    
}

- (void)addListener:(id<CCServerStoredObjectDelegate>) listener
{
    if ([updateListeners containsObject:listener])
        return;
    
    [updateListeners addObject:listener];
}

- (void)removeListener:(id<CCServerStoredObjectDelegate>) listener
{
    if ([updateListeners containsObject:listener])
        [updateListeners removeObject:listener];
}

// CCParseObject functions
- (id) initWithData:(PFObject *) parseData
{
    self = [super init];
    
    if (self != nil)
    {
        parseObject = parseData;
    }
    
    return self;
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

- (void)notifyListenersThatDeleteIsBeginning
{
    for(id<CCServerStoredObjectDelegate> listner in updateListeners)
    {
        [listner startedDeletingObject:self];
    }
}

- (void)notifyListenersThatDeletedHasCompleted
{
    for(id<CCServerStoredObjectDelegate> listner in updateListeners)
    {
        [listner succesfullyDeletedObject:self];
    }
}

- (void)notifyListenersThatUpdateHasSuccessfullyCompleted
{
    for(id<CCServerStoredObjectDelegate> listner in updateListeners)
    {
        [listner successfullyUpdatedObject:self];
    }
}

- (void)notifyListenersThatUpdateIsBeginning
{
    for(id<CCServerStoredObjectDelegate> listner in updateListeners)
    {
        [listner startedUpdatingObject:self];
    }
}

- (void)notifyListenersThatLoadHasSuccessfullyCompleted
{
    for(id<CCServerStoredObjectDelegate> listner in updateListeners)
    {
        [listner successfullyLoadedObject:self];
    }
}

- (void)notifyListenersThatLoadIsBeginning
{
    for(id<CCServerStoredObjectDelegate> listner in updateListeners)
    {
        [listner startedLoadingObject:self];
    }
}

@end
