//
//  CCCustomTextView.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-30.
//
//

#import "CCCustomTextView.h"

@implementation CCCustomTextView
@synthesize lineHeight;

- (id)styleString {
    return [[super styleString] stringByAppendingString:[NSString stringWithFormat:@"; line-height: %@em", lineHeight]];
}

@end
