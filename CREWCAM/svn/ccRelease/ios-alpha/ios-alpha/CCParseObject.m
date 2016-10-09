//
//  CCParseObject.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseObject.h"
#import "CCCoreManager.h"

@implementation CCParseObject

// Required CCServerStoredObject properties
@synthesize updateListeners;
@synthesize isPulling;
@synthesize isDeleting;

// CCParseObject properties
@synthesize     className;  
@synthesize     parseObject;            // Access to the parseObject should definitely be synchronized

// Required CCServerStoredObject default method implementations
- (void)initialize
{
    [NSException raise:@"Called [CCParseObject initialize], when the method should be overridden." format:@""];
}

- (void) handleExceptionThrown:(NSException *) exception withBlockOrNil:(CCBooleanResultBlock) block andMessage:(NSString *) message
{
    NSString *descriptiveErrorString = [[NSString alloc] initWithFormat:@"%@: %@", message, [exception reason]];
    NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedDescriptionKey,  descriptiveErrorString, nil];
    NSError *error = [[NSError alloc] initWithDomain:NSUnderlyingErrorKey code:0 userInfo:errorDictionary];
    
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:descriptiveErrorString];
    
    if (block)
        block(NO, error);
}

- (id)initWithServerData:(id) serverData
{
    self = [super init];
    
    if (self != nil)
    {
        [self setParseObject:serverData];
        isObjectBusy = NO;
        [self initialize];
    }
    
    return self;
}

- (void)pushObjectWithBlockOrNil:(CCBooleanResultBlock)block
{   
    [self notifyListenersThatPushIsBeginning];

    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    @synchronized([self parseObject])
    {
        if (!parseObject)
        {  
            // Log this error
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Tried to push object without initializing parseObject."];
            
            NSMutableDictionary* errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Tried to push object without initializing parseObject." forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"CCParseObject" code:0 userInfo:errorDetails];
            
            if (block)
                block(NO, error);
            
            [self notifyListenersThatPullHasCompleted:NO withError:error];
        }
        else 
        {
            [parseObject saveEventually:^(BOOL succeeded, NSError *error) 
            {
                if (error)
                {
                    // Log this error
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error pushing Parse object: %@", [error localizedDescription]];
                }
                OSAtomicTestAndClear(YES, &isObjectBusy);
                
                if (block)
                    block(succeeded, error);
                
                [self notifyListenersThatPushHasCompleted:succeeded withError:error];           
            }];
            
        }
        
    }
}

- (BOOL)pushObjectWithError:(NSError *) error
{
    __block NSCondition *isCompleteCondition = [[NSCondition alloc] init];
    __block BOOL wasSuccessful;
    __block NSError *retainedError;
    
    [self pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *pushError) {
        retainedError = pushError;
        wasSuccessful = succeeded;
        [isCompleteCondition signal];
    }];
    
    [isCompleteCondition lock];
    [isCompleteCondition wait];
    [isCompleteCondition unlock];
    
    error = retainedError;
    
    return wasSuccessful;    
}

- (void)deleteObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    if (OSAtomicTestAndSetBarrier(1, &isDeleting))        
        return;
    
    [self notifyListenersThatDeleteIsBeginning];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    @synchronized([self parseObject])
    {        
        if (!parseObject)
        {
            // Log this error
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Tried to delete object without initializing parseObject."];
            
            // Pass the error up the stack
            NSMutableDictionary* errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Tried to delete object without initializing parseObject." forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"CCParseObject" code:0 userInfo:errorDetails];
            
            if (block)
                block(NO, error);
            
            [self notifyListenersThatPullHasCompleted:NO withError:error];
            
            OSAtomicTestAndClearBarrier(1, &isDeleting);
        }
        else 
        {
            // Start by asking the object to purge any related data
            [self purgeRelatedDataInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) 
             {      
                 if (error)
                 {
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error purging related data during delete: %@", [error localizedDescription]];
                     
                     OSAtomicTestAndClear(YES, &isObjectBusy);
                     
                     if (block)            
                         block(succeeded, error);
                     
                     [self notifyListenersThatDeletedHasCompleted:succeeded withError:error];
                     
                     OSAtomicTestAndClearBarrier(1, &isDeleting);
                 }
                 else 
                 {
                     // Continue deleting this object
                     [parseObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
                      {                                
                          parseObject = nil;
                          
                          if (error)
                          {
                              // Log this error
                              [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error deleting Parse object: %@", [error localizedDescription]];
                          }
                          
                          OSAtomicTestAndClear(YES, &isObjectBusy);                        
                          
                          if (block)            
                              block(succeeded, error);
                          
                          [self notifyListenersThatDeletedHasCompleted:succeeded withError:error];
                          
                          OSAtomicTestAndClearBarrier(1, &isDeleting);
                      }]; 
                 }
                 
             }];           
        }
               
    }
}

// Simple blocking wrapper around the above method
- (void)deleteObject
{
    NSCondition *deleteFinishedCondition = [[NSCondition alloc] init];
    
    [deleteFinishedCondition lock];
    
    [self deleteObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        [deleteFinishedCondition signal];
    }];
    
    [deleteFinishedCondition wait];
    [deleteFinishedCondition unlock];
}

- (void)pullObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    if (OSAtomicTestAndSetBarrier(1, &isPulling))
        return;
    
    [self notifyListenersThatPullIsBeginning];
    
    OSAtomicTestAndSet(YES, &isObjectBusy);
    
    @synchronized([self parseObject])
    {
        if (!parseObject)
        {      
            // Log this error
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Tried to pull object without initializing parseObject."];
            
            NSMutableDictionary* errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Tried to pull object without initializing parseObject." forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"CCParseObject" code:0 userInfo:errorDetails];
            
            OSAtomicTestAndClear(YES, &isObjectBusy);
            
            if (block)
                block(NO, error);
            
            [self notifyListenersThatPullHasCompleted:NO withError:error];
            
            OSAtomicTestAndClearBarrier(1, &isPulling);
        }
        else 
        {
            [parseObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error)
             {                 
                 parseObject = object;              
                 
                 if (error)
                 {
                     // Log this error
                     [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error pulling Parse object: %@", [error localizedDescription]];
                 }
                 
                 OSAtomicTestAndClear(YES, &isObjectBusy);
                                  
                 if (block)
                     block(((error == nil) ? YES : NO), error);
                 
                 [self notifyListenersThatPullHasCompleted:((error == nil) ? YES : NO) withError:error];
                                  
                 OSAtomicTestAndClearBarrier(1, &isPulling);                
             }];
        }
    }
}

- (void)addListener:(id<CCServerStoredObjectDelegate>) listener
{
    @synchronized(updateListeners)
    {
        if ([updateListeners containsObject:listener])
            return;
        
        [updateListeners addObject:listener];
    }
}

- (void)removeListener:(id<CCServerStoredObjectDelegate>) listener
{
    @synchronized(updateListeners)
    {
        if ([updateListeners containsObject:listener])
            [updateListeners removeObject:listener];
    }
}

// Required CCServerStoredObject getters
- (BOOL) isBusy
{
    return isObjectBusy;
}

- (NSString *) getObjectID
{
    if ([self parseObject] == nil)
    {
        [self logDataMissingError];
        return nil;
    }
    
    return ([parseObject objectId]);
}

- (id) getServerData
{
    if ([self parseObject] == nil)
    {
        [self logDataMissingError];
        return nil;
    }
    
    return parseObject;
}

- (void) setServerData: (id) serverData
{
    @synchronized([self parseObject])
    {
        [self setParseObject:serverData];
    }
}

- (NSDate *) getObjectCreatedDate
{
    if ([self parseObject] == nil)
    {
        [self logDataMissingError];
        return nil;
    }
    
    return ([parseObject createdAt]);
}

- (NSDate *) getObjectModifiedDate
{
    if ([self parseObject] == nil)
    {
        [self logDataMissingError];
        return nil;
    }
    
    return ([parseObject updatedAt]);
}

- (NSArray *) getArrayOfPFObjectsFromObjects:(NSArray *)object
{
    NSMutableArray *parseObjects = [[NSMutableArray alloc] init];
    
    for (int currentObject = 0; currentObject < [object count]; currentObject++)
    {                                     
        [parseObjects addObject:[[object objectAtIndex:currentObject] parseObject]];
    }
    
    return [[NSArray alloc] initWithArray:parseObjects];
}

+ (BOOL) isObjectInArray:(id<CCServerStoredObject>) ccServerStoredObject arrayOfCCServerStoredObjects:(NSArray *) objects
{
    for(id<CCServerStoredObject> thisObject in objects)
    {
        if ([[ccServerStoredObject getObjectID] isEqualToString:[thisObject getObjectID]])
            return YES;
    }
    
    return NO;    
}

+ (int) indexForCCServerStoredObject:(id<CCServerStoredObject>) ccServerStoredObject inArrayOfCCServerStoredObjects:(NSArray *) objects
{
    for(int objectIndex = 0; objectIndex < [objects count]; objectIndex++)
    {
        if ([[ccServerStoredObject getObjectID] isEqualToString:[[objects objectAtIndex:objectIndex] getObjectID]])
            return objectIndex;
    }
    
    return -1;  
}

+ (id<CCServerStoredObject>) getCCServerStoredObjectFromArray:(NSArray *)objects forObjectID:(NSString *)objectID
{
    id<CCServerStoredObject> foundObject = nil;
    
    for (id<CCServerStoredObject> object in objects)
    {
        if ([[object getObjectID] isEqualToString:objectID])
        {
            foundObject = object;
            break;
        }
    }
    
    return foundObject;
}
   
- (void) logDataMissingError
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Attempted to access or set data before calling \"pull\" on the object!"];
}
             
- (void) checkForParseDataAndThrowExceptionIfNil
{
    if ([self parseObject] == nil)
    {
        [self logDataMissingError];
        
#ifdef TESTYO
        [NSException raise:@"Attempted to get or set object data without pulling the data from Parse" format:@"parseObject is nil for this object"];
#endif
    }
}

- (void) handleNewCCObjects:(NSMutableArray *)ccObjects removedObjectIndexes:(out NSMutableArray *)removedObjectIndexes addedObjectIndexes:(out NSMutableArray *)addedObjectIndexes finalArrayOfObjects:(NSMutableArray *)finalArrayOfObjects
{    
    // Check for obsolete objects, and remove them from the final array of objects
    int oldObjectIndex = 0;
    for (int objectIndex = 0; objectIndex < [finalArrayOfObjects count]; objectIndex++)
    {
        int existingObjectIndex = [CCParseObject indexForCCServerStoredObject:[finalArrayOfObjects objectAtIndex:objectIndex] inArrayOfCCServerStoredObjects:ccObjects];
        
        if (existingObjectIndex == -1)
        {
            // This is an obsolete object
            [removedObjectIndexes addObject:[NSIndexPath indexPathForRow:oldObjectIndex inSection:0]];            
            [finalArrayOfObjects removeObjectAtIndex:objectIndex];
            objectIndex--;
        }
        else 
        {
            [(id<CCServerStoredObject>)[finalArrayOfObjects objectAtIndex:objectIndex] setServerData:[[ccObjects objectAtIndex:existingObjectIndex] getServerData]];
        }
        oldObjectIndex++;
    }
    
    // Check for new objects, and add them to the final array of objects
    for (int objectIndex = 0; objectIndex < [ccObjects count]; objectIndex++)
    {        
        if (![CCParseObject isObjectInArray:[ccObjects objectAtIndex:objectIndex] arrayOfCCServerStoredObjects:finalArrayOfObjects])
        {
            // This is a new object, insert it near the beginning
            [finalArrayOfObjects insertObject:[ccObjects objectAtIndex:objectIndex] atIndex:objectIndex];
            [addedObjectIndexes addObject:[NSIndexPath indexPathForRow:objectIndex inSection:0]];
        }
    }        
}

- (void)notifyListenersThatDeleteIsBeginning
{
    @synchronized(updateListeners)
    {
        for(id<CCServerStoredObjectDelegate> listener in updateListeners)
        {
            if ([listener respondsToSelector:@selector(startedDeletingObject:)])
                [listener startedDeletingObject:self];
        }
    }
}

- (void)notifyListenersThatDeletedHasCompleted:(BOOL)succeeded withError:(NSError *)error
{
    @synchronized(updateListeners)
    {
        for(id<CCServerStoredObjectDelegate> listener in updateListeners)
        {
            if ([listener respondsToSelector:@selector(finishedDeletingObject:withSuccess:andError:)])
                [listener finishedDeletingObject:self withSuccess:succeeded andError:error];
        }
    }
}

- (void)notifyListenersThatPushIsBeginning
{
    @synchronized(updateListeners)
    {
        for(id<CCServerStoredObjectDelegate> listener in updateListeners)
        {
            if ([listener respondsToSelector:@selector(startedPushingObject:)])
                [listener startedPushingObject:self];
        }
    }
}

- (void)notifyListenersThatPushHasCompleted:(BOOL)succeeded withError:(NSError *)error
{
    @synchronized(updateListeners)
    {
        for(id<CCServerStoredObjectDelegate> listener in updateListeners)
        {
            if ([listener respondsToSelector:@selector(finishedPushingObject:withSuccess:andError:)])
                [listener finishedPushingObject:self withSuccess:succeeded andError:error];
        }
    }
}

- (void)notifyListenersThatPullIsBeginning
{
    @synchronized(updateListeners)
    {
        for(id<CCServerStoredObjectDelegate> listener in updateListeners)
        {
            if ([listener respondsToSelector:@selector(startedPullingObject:)])
                [listener startedPullingObject:self];
        }
    }
}

- (void)notifyListenersThatPullHasCompleted:(BOOL)succeeded withError:(NSError *)error
{
    @synchronized(updateListeners)
    {
        for(id<CCServerStoredObjectDelegate> listener in updateListeners)
        {
            if ([listener respondsToSelector:@selector(finishedPullingObject:withSuccess:andError:)])
                [listener finishedPullingObject:self withSuccess:succeeded andError:error];
        }
    }
}

//default method that will be used for CCParseObjects that do not have related data to purge.
- (void) purgeRelatedDataInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block
{
    block(YES, nil);
}

@end
