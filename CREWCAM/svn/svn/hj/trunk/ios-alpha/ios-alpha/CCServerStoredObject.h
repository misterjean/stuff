//
//  CCServerStoredObject.h
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCConstants.h"

@protocol CCServerStoredObjectDelegate; // Forward decleration

typedef enum CCObjectType {
    ccVideo = 0,
    ccCrew,
    ccUser
} CCObjectType;

@protocol CCServerStoredObject

// Required methods
@required

// Push/Pull/Delete object methods.  
// NOTE: It is assumed that these methods are called on the main thread, and they will take care of creating the needed threads for server communication
- (void)pushObjectWithBlockOrNil:(CCBooleanResultBlock)block;                   // Pushes this object to the server on a background thread
- (void)deleteObjectWithBlockOrNil:(CCBooleanResultBlock)block;                 // Deletes this object from the server on a background thread
- (void)pullObjectWithBlockOrNil:(CCBooleanResultBlock)block;                   // Pulls new data about this object from the server on a background thread
- (void)addListener:(id<CCServerStoredObjectDelegate>) listener;   
- (void)removeListener:(id<CCServerStoredObjectDelegate>) listener;

// Required properties
@property (strong, nonatomic) NSString          *name;
@property (strong, nonatomic) NSString          *objectID;
@property (strong, nonatomic) NSMutableArray    *updateListeners;               // An array of CCServerStoredObjectListener(s) that are called when various object changes occour 

@optional

@end