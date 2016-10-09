//
//  CCCrewTableCell.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCrew.h"
#import "CCServerStoredObjectDelegate.h"
#import "CCUser.h"
#import "CCCoreManager.h"
#import "CCCrewIconView.h"

@interface CCCrewTableViewCell : UITableViewCell
{
    NSMutableArray *crewSubViews;
}
- (void) setCrews:(NSArray *) crews andNavigationController:(UINavigationController *) navigationController andIsFirstRow:(BOOL)isFirstRow andIsShaking:(BOOL) isShaking;

@end
