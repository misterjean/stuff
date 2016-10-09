//
//  CCServerStoredObject.h
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <libkern/OSAtomic.h>
#import <Foundation/Foundation.h>
#import "CCConstants.h"

@protocol CCServerStoredObjectDelegate; // Forward decleration

@protocol CCServerStoredObject

@optional
// Data sanatization for objects that have related data
- (void) purgeRelatedDataInBackgroundWithBlockOrNil:(CCBooleanResultBlock) block;

// Required methods
@required

// Default contructor simply gets this object's data, given the object's ID in the database
- (id) initWithServerData:(id) serverData;                                      // It is assumed that "serverData" includes all data relevant to this 
                                                                                // object, but related data is loaded through "loadInBackground..." methods
+ (BOOL) isObjectInArray:(id<CCServerStoredObject>) ccServerStoredObject arrayOfCCServerStoredObjects:(NSArray *) objects;
+ (int) indexForCCServerStoredObject:(id<CCServerStoredObject>) ccServerStoredObject inArrayOfCCServerStoredObjects:(NSArray *) objects;
+ (id<CCServerStoredObject>) getCCServerStoredObjectFromArray:(NSArray *)objects forObjectID:(NSString *)objectID;

// Basic function to be called to allow child objects to do any needed initialization
- (void)initialize;

- (void) handleExceptionThrown:(NSException *) exception withBlockOrNil:(CCBooleanResultBlock) block andMessage:(NSString *) message;

// Push/Pull/Delete object methods.  
// NOTE: It is assumed that these methods are called on the main thread, and they will take care of creating the needed threads for server communication
- (void)pushObjectWithBlockOrNil:(CCBooleanResultBlock)block;                   // Pushes this object to the server
- (BOOL)pushObjectWithError:(NSError *) error;                                  // Pushes this object to the server
- (void)deleteObjectWithBlockOrNil:(CCBooleanResultBlock)block;                 // Deletes this object from the server on a background thread
- (void)deleteObject; // Blocks the thread
- (void)pullObjectWithBlockOrNil:(CCBooleanResultBlock)block;                   // Pulls new data about this object from the server on a background thread.  Also initializes local properties.

- (void)addListener:(id<CCServerStoredObjectDelegate>) listener;   
- (void)removeListener:(id<CCServerStoredObjectDelegate>) listener;

// Optional getters/setters
@optional
- (NSString *)  getName;
- (NSString *)  setName;

// Required getters
@required
- (BOOL)        isBusy;
- (NSString *)  getObjectID;
- (id)          getServerData;
- (void) setServerData: (id) serverData;
- (NSDate *)    getObjectCreatedDate;
- (NSDate *)    getObjectModifiedDate;

// Required Properties
@property (strong, nonatomic)   NSMutableArray    *updateListeners;               // An array of CCServerStoredObjectListener(s) that are called when 
                                                                                  // various object changes occour.  All     
                                                                                  // access should be synchronized

@property                       uint32_t          isPulling;                      // Access via OSAtomic... methods
@property                       uint32_t          isDeleting;                     // Access via OSAtomic... methods

@optional

@end