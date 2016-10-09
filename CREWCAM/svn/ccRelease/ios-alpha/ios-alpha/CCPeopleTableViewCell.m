//
//  CCSelectablePersonTableViewCell.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-26.
//
//

#import "CCPeopleTableViewCell.h"

@implementation CCPeopleTableViewCell

- (void) dealloc
{
    peopleSubViews = nil;
}
- (void) setForPeople:(NSArray *) people areIconsSelectable:(BOOL) isSelectable andArePeopleSelectedBools:(NSArray *) isSelectedBools arePeopleRequestable:(BOOL) arePeopleInvitable
{
    if (!peopleSubViews)
    {
        peopleSubViews = [[NSMutableArray alloc] init];
        
        for(int personIndex = 0; personIndex < 3; personIndex++)
        {
            CCPersonIconView *personIcon = [[[NSBundle mainBundle] loadNibNamed:@"SelectablePersonView" owner:self options:nil] objectAtIndex:0];
            
            [personIcon setFrame:CGRectMake(12 + (102 * personIndex), 0, personIcon.frame.size.width, personIcon.frame.size.height)];
            
            [peopleSubViews addObject:personIcon];
            
            [self addSubview:personIcon];
        }
    }
    
    if ([people count] > 3)
    {
        [NSException raise:@"Stupid!" format:nil];
    }
    
    for(int personIndex = 0; personIndex < 3; personIndex++)
    {
        CCPersonIconView *personSubView = [peopleSubViews objectAtIndex:personIndex];
        
        if (personIndex >= [people count])
        {
            [personSubView setHidden:YES];
            
            continue;
        }
        
        [personSubView setHidden:NO];
        
        [personSubView setupForPerson:[people objectAtIndex:personIndex] andIsSelectable:isSelectable andIsSelected:(isSelectedBools ? (NSNumber *)[isSelectedBools objectAtIndex:personIndex] : [NSNumber numberWithBool:NO]) andIsInvitable:arePeopleInvitable];
    }
}
- (void) setDelegate:(id<CCPersonSelectedDelegate>) delegate
{
    for(CCPersonIconView * view in peopleSubViews)
    {
        [view setDelegate:delegate];
    }
}
@end
