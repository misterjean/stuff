//
//  CCServerStoredObject.h
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCConnectorPostObjectCompleteDelegate.h"

typedef enum CCObjectType {
    ccVideo = 0,
    ccCrew,
    ccUser
} CCObjectType;

@protocol CCServerStoredObject

@required
// Required methods
- (void)pushObjectWithNewThread:(Boolean)useNewThread delegateOrNil:(id<CCConnectorPostObjectCompleteDelegate>)delegateOrNil;      // Pushes this object to the server
- (void)deleteObjectWithNewThread:(Boolean)useNewThread;    // Deletes this object from the server
- (void)pullObjectWithNewThread:(Boolean)useNewThread;      // Pulls new data about this object from the server

// Required properties
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *objectID;

@optional

@end