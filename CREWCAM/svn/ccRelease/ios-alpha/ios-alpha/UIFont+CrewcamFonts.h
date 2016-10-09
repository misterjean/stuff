//
//  UIFont+CrewcamFonts.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-25.
//
//

#import <UIKit/UIKit.h>

@interface UIFont (CrewcamFonts)
+ (UIFont *) getSteelfishFontForFont:(UIFont *)font;
+ (UIFont *) getSteelfishFontForSize:(CGFloat) size;
+ (UIFont *) getImpactFontForFont:(UIFont *)font;
+ (UIFont *) getImpactFontForSize:(CGFloat) size;

@end
