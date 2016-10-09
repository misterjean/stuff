//
//  CCServerStoredObjectListner.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCServerStoredObject.h"

@protocol CCServerStoredObjectDelegate <NSObject>

// It is assumed that these methods will be called on the main thread, which allows UIViewControllers to easily update things
@optional
- (void)startedDeletingObject:      (id<CCServerStoredObject>)     object;
- (void)finishedDeletingObject:     (id<CCServerStoredObject>)     object withSuccess:(BOOL)succes andError:(NSError *)error;

- (void)startedPushingObject:       (id<CCServerStoredObject>)     object;
- (void)finishedPushingObject:      (id<CCServerStoredObject>)     object withSuccess:(BOOL)succes andError:(NSError *)error;

- (void)startedPullingObject:       (id<CCServerStoredObject>)     object;
- (void)finishedPullingObject:      (id<CCServerStoredObject>)     object withSuccess:(BOOL)succes andError:(NSError *)error;
@end
