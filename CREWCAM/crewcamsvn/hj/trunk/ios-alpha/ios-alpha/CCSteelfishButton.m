//
//  CCSteelfishButton.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-13.
//
//

#import "CCSteelfishButton.h"

@implementation CCSteelfishButton

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setFont:[UIFont getSteelfishFontForSize:25]];
    }
    
    return self;
}

@end
