//
//  CCCustomTextView.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-30.
//
//

#import "CCCrewIconNameTextView.h"

@implementation CCCrewIconNameTextView : CCCustomTextView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setLineHeight:[NSNumber numberWithFloat:0.85]];
    }
    
    return self;    
}

@end
