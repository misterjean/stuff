//
//  CCCustomActivityIndicator.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-31.
//
//

#import "CCCustomActivityIndicator.h"

@implementation CCCustomActivityIndicator
@synthesize crewcamOutsideImageView;
- (void) awakeFromNib
{
    [super awakeFromNib];
    
    crewcamOutsideImageView.animationImages = [NSArray arrayWithObjects:
                                               [UIImage imageNamed:@"logo_outside_01.png"],
                                               [UIImage imageNamed:@"logo_outside_02.png"],
                                               [UIImage imageNamed:@"logo_outside_03.png"],
                                               [UIImage imageNamed:@"logo_outside_04.png"],
                                               [UIImage imageNamed:@"logo_outside_05.png"],
                                               [UIImage imageNamed:@"logo_outside_06.png"],
                                               [UIImage imageNamed:@"logo_outside_07.png"],
                                               [UIImage imageNamed:@"logo_outside_08.png"],
                                               [UIImage imageNamed:@"logo_outside_09.png"],
                                               [UIImage imageNamed:@"logo_outside_10.png"],
                                               [UIImage imageNamed:@"logo_outside_11.png"],
                                               [UIImage imageNamed:@"logo_outside_12.png"],
                                               [UIImage imageNamed:@"logo_outside_13.png"],
                                               [UIImage imageNamed:@"logo_outside_14.png"],
                                               nil];    
    
    crewcamOutsideImageView.animationDuration = 0.8;
    
    [crewcamOutsideImageView startAnimating];
}

@end
