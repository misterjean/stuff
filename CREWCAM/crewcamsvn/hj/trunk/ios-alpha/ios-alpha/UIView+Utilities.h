//
//  UIView+Utilities.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-25.
//
//

#import <UIKit/UIKit.h>
#import "UIFont+CrewcamFonts.h"
#import "UIColor+CrewcamColors.h"

@interface UIView (Utilities)
- (void) addCrewcamTitleToViewController:(NSString *) title;
- (void) addLeftNavigationButtonFromFileNamed:(NSString *) imageName target:(id)target action:(SEL)action;

@end
