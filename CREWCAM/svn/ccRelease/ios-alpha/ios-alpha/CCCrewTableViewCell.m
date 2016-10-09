//
//  CCCrewTableCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewTableViewCell.h"

@implementation CCCrewTableViewCell

- (void) setCrews:(NSArray *) crews andNavigationController:(UINavigationController *) navigationController andIsFirstRow:(BOOL)isFirstRow andIsShaking:(BOOL) isShaking
{
    if (!crewSubViews)
    {
        crewSubViews = [[NSMutableArray alloc] init];
            
        for(int crewIndex = 0; crewIndex < 3; crewIndex++)
        {
            CCCrewIconView *crewIcon = [[[NSBundle mainBundle] loadNibNamed:@"CrewIconView" owner:self options:nil] objectAtIndex:0];
            
            [crewIcon setFrame:CGRectMake(12 + (102 * crewIndex), 0, crewIcon.frame.size.width, crewIcon.frame.size.height)];
            
            [crewSubViews addObject:crewIcon];
            
            [self addSubview:crewIcon];
        } 
    }

    if ([crews count] > 3 || (isFirstRow && ([crews count] > 2)))
    {
        [NSException raise:@"Stupid!" format:nil];
    }
    
    if (isFirstRow)
    {
        CCCrewIconView *crewSubView = [crewSubViews objectAtIndex:0];
        
        [crewSubView setUpForAddCrewWithNavigationController:navigationController];
        
        [crewSubView setHidden:NO];
    }
    
    for(int crewIndex = 0; crewIndex < (isFirstRow ? 2 : 3); crewIndex++)
    {
        CCCrewIconView *crewSubView = [crewSubViews objectAtIndex:(isFirstRow ? crewIndex + 1 : crewIndex)];
        
        if (crewIndex >= [crews count])
        {
            [crewSubView setHidden:YES];
            
            continue;
        }
        
        [crewSubView setHidden:NO];
        
        id<CCCrew> crew = [crews objectAtIndex:crewIndex];
                        
        [crewSubView setCrew:crew andNavigationController:navigationController andIsShaking:isShaking];
    }
}



@end
