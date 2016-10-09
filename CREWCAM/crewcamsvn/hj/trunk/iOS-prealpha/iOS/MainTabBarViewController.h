//
//  MainTabBarViewController.h
//  iOS
//
//  Created by Desmond McNamee on 12-04-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarViewController : UITabBarController

+ (void) setVideoOrientation:(int)orientation;
+ (int) getVideoOrientation;

@end
