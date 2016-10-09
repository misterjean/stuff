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
- (void)succesfullyDeletedObject:   (id<CCServerStoredObject>)     object;
- (void)failedDeletingObject:       (id<CCServerStoredObject>)     object;
- (void)startedDeletingObject:      (id<CCServerStoredObject>)     object;

- (void)successfullyUpdatedObject:  (id<CCServerStoredObject>)     object;
- (void)failedUpdatingObject:       (id<CCServerStoredObject>)     object;
- (void)startedUpdatingObject:      (id<CCServerStoredObject>)     object;

- (void)successfullyLoadedObject:   (id<CCServerStoredObject>)     object;
- (void)failedLoadingObject:        (id<CCServerStoredObject>)     object;
- (void)startedLoadingObject:       (id<CCServerStoredObject>)     object;

@end
