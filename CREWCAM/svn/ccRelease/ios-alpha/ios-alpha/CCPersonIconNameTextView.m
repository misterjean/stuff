//
//  CCPersonIconNameTextView.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-08.
//
//

#import "CCPersonIconNameTextView.h"

@implementation CCPersonIconNameTextView

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
