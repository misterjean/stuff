//
//  UIFont+CrewcamFonts.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-25.
//
//

#import "UIFont+CrewcamFonts.h"

@implementation UIFont (CrewcamFonts)
+ (UIFont *) getSteelfishFontForFont:(UIFont *)font
{
    return [UIFont fontWithName:@"SteelfishRg-Bold" size:font.pointSize];
}

+ (UIFont *) getSteelfishFontForSize:(CGFloat) size
{
    return [UIFont fontWithName:@"SteelfishRg-Bold" size:size];
}

+ (UIFont *) getImpactFontForFont:(UIFont *)font
{
    return [UIFont fontWithName:@"Impact" size:font.pointSize];
    
}

+ (UIFont *) getImpactFontForSize:(CGFloat) size
{
    return [UIFont fontWithName:@"Impact" size:size];
}

@end
