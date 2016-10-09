//
//  UIBarButtonItem+CCCustomBarButtonItem.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIBarButtonItem+CCCustomBarButtonItem.h"

@implementation UIBarButtonItem (CCCustomBarButtonItem)

+ (UIBarButtonItem *)barItemWithImageName:(NSString *) imageName target:(id)target action:(SEL)action
{
    UIImage *inactiveButton = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"%@.png", imageName]];
    UIImage *activeButton = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"%@_ACT.png", imageName]]; 
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,0,inactiveButton.size.width,inactiveButton.size.height)];
    [button setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    [button setBackgroundImage:inactiveButton forState:UIControlStateNormal];
    [button setBackgroundImage:activeButton forState:UIControlStateHighlighted];
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, inactiveButton.size.width, inactiveButton.size.height)];
    [v addSubview:button];    
    
    return [[UIBarButtonItem alloc] initWithCustomView:v];    
}
@end
