//
//  CCGlobalConfigurations.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-21.
//
//

#import <Foundation/Foundation.h>

@interface CCGlobalConfigurations : NSObject
@property                      BOOL            isInLockdown;
@property                      BOOL            isOpenAccess;
@property                      BOOL            isPostableToFacebook;
@property (strong, nonatomic)  NSString        *currentAppStoreRevisionString;

@end
