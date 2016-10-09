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

- (void)deleteObjectWithBlockOrNil:(CCBooleanResultBlock)block;
- (id) initWithData:(PFObject *) parseData;
- (NSArray *)getArrayOfPFObjectsFromObjects:(NSArray *)object;

// Notification helpers
- (void)notifyListenersThatDeleteIsBeginning;
- (void)notifyListenersThatDeletedHasCompleted;
- (void)notifyListenersThatUpdateHasSuccessfullyCompleted;
- (void)notifyListenersThatUpdateIsBeginning;
- (void)notifyListenersThatLoadHasSuccessfullyCompleted;
- (void)notifyListenersThatLoadIsBeginning;

@property (strong, nonatomic) PFObject *parseObject;

@end
