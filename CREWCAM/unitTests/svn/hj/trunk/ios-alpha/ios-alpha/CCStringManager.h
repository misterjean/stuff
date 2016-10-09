//
//  CCStringManager.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-25.
//
//

#import <Foundation/Foundation.h>
#import "CCStringKeys.h"
#import "CCConstants.h"
#import "CCCoreManager.h"

@protocol CCStringManager <NSObject>

- (void) loadStringsInBackgroundWithBlock:(CCBooleanResultBlock) block;

-(NSString *)getStringForKey:(NSString *)key withDefault:(NSString *) defaultString;

@end
