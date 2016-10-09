//
//  CCSelectablePersonTableViewCell.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-26.
//
//

#import <UIKit/UIKit.h>
#import "CCPersonIconView.h"



@interface CCPeopleTableViewCell : UITableViewCell
{
    NSMutableArray *peopleSubViews;
}

- (void) setForPeople:(NSArray *) people areIconsSelectable:(BOOL) isSelectable andArePeopleSelectedBools:(NSArray *) isSelectedBools arePeopleRequestable:(BOOL) arePeopleInvitable;
- (void) setDelegate:(id<CCPersonSelectedDelegate>) delegate;

@end
