//
//  CCLongTextCustomTextView.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-30.
//
//

#import "CCLongTextCustomTextView.h"

@implementation CCLongTextCustomTextView : CCCustomTextView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    [self setLineHeight:[NSNumber numberWithFloat:1.2]];

    self = [super initWithCoder:aDecoder];
    
    return self;
}

- (id) init
{
    self = [super init];
    
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    return self;
}

@end
