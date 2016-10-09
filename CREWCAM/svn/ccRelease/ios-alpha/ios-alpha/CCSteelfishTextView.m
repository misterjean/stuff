//
//  CCSteelfishTextView.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-13.
//
//

#import "CCSteelfishTextView.h"

@implementation CCSteelfishTextView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setFont:[UIFont getSteelfishFontForSize:30]];
    }
    
    return self;
}

@end
