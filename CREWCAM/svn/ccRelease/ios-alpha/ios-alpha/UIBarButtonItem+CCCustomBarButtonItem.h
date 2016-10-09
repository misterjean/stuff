//
//  UIBarButtonItem+CCCustomBarButtonItem.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (CCCustomBarButtonItem)
+ (UIBarButtonItem*)barItemWithImageName:(NSString *) imageName target:(id)target action:(SEL)action;
@end
