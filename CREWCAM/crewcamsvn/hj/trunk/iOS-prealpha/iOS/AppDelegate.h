//
//  AppDelegate.h
//  iOS
//
//  Created by Ryan Brink on 12-04-09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerApi.h"
#import "LocationManager.h"
#import "Parse/Parse.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PF_FBSessionDelegate> {
}

@property (strong, nonatomic) UIWindow *window;

@end
