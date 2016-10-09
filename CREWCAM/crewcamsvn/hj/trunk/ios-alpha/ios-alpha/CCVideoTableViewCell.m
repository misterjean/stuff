//
//  CCVideoTableViewCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCVideoTableViewCell.h"

@implementation CCVideoTableViewCell
- (void) dealloc
{
    videoIconView = nil;
}

- (void)initializeWithVideo:(id<CCVideo>) videoForCell andNavigationController:(CCCrewViewController *) navigationController
{
    if (!videoIconView)
    {
        videoIconView = [[[NSBundle mainBundle] loadNibNamed:@"VideoIconView" owner:self options:nil] objectAtIndex:0];
        
        [videoIconView setFrame:CGRectMake(12, 12, videoIconView.frame.size.width, videoIconView.frame.size.height)];
        
        [self addSubview:videoIconView];
    
    }
    
    [videoIconView initializeWithVideo:videoForCell andNavigationController:navigationController];
}

@end
