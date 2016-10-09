//
//  CCConstants.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCUser;   // Forward decleration to avoid circular references
@protocol CCCrew;   // Forward decleration to avoid circular references

#define LOG_KISSMETRICS !DEBUG

typedef void (^CCBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^CCArrayResultBlock)(NSArray *array, NSError *error);
typedef void (^CCUserResultBlock)(BOOL succeeded, NSError *error, id<CCUser> user, Boolean isNewUser);
typedef void (^CCCrewResultBlock)(id<CCCrew> objectId, BOOL succeeded, NSError *error);