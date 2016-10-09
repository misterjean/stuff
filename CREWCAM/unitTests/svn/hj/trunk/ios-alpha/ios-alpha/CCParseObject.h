//
//  CCParseObject.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CCConstants.h"
#import "CCServerStoredObjectDelegate.h"

@interface CCParseObject : NSObject <CCServerStoredObject>
{
    BOOL isObjectBusy;
}

// Default constructor.  Simply saves the given parseData, which is what should be accessed by all getter/setter methods in
// child objects
- (id) initWithServerData:(PFObject *) parseData;

// Helper functions
- (NSArray *)getArrayOfPFObjectsFromObjects:(NSArray *)object;
- (void) logDataMissingError;
- (void) checkForParseDataAndThrowExceptionIfNil;
- (void) handleNewCCObjects:(NSArray *)ccObjects removedObjectIndexes:(out NSArray *)removedObjectIndexes addedObjectIndexes:(out NSArray *)addedObjectIndexes finalArrayOfObjects:(NSMutableArray *)finalArrayOfObjects;

// ParseObject properties
@property (strong, atomic)      NSString *className;
@property (strong, atomic)      PFObject *parseObject;

@end
