//
//  UIViewController+Utilities.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-25.
//
//

#import "UIView+Utilities.h"

@implementation UIView (Utilities)
- (void) addCrewcamTitleToViewController:(NSString *) title
{
    UILabel *crewcamTitleLabel = [[UILabel alloc] init];
    
    [crewcamTitleLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    [crewcamTitleLabel setTextAlignment:UITextAlignmentRight];
    [crewcamTitleLabel setText:[title uppercaseString]];
    [crewcamTitleLabel setTextColor:[UIColor crewcamOrangeTextColor]];
    [crewcamTitleLabel setFont:[UIFont getSteelfishFontForSize:35]];
    [crewcamTitleLabel setFrame:CGRectMake(86, 3, ([self frame].size.width - 97), 35)];
    [crewcamTitleLabel setAdjustsFontSizeToFitWidth:FALSE];
    [crewcamTitleLabel setLineBreakMode:UILineBreakModeTailTruncation];
    
    [self addSubview:crewcamTitleLabel];
    [self bringSubviewToFront:crewcamTitleLabel];
}

- (void) addLeftNavigationButtonFromFileNamed:(NSString *) imageName target:(id)target action:(SEL)action
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

    [self addSubview:v];
}


@end
