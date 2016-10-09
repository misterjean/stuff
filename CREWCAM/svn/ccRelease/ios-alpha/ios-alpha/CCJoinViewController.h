//
//  CCJoinCrewsViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCFriendCrewTableViewCell.h"
#import "UIView+Utilities.h"

@interface CCJoinViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray    *crewsForJoining;
}
@property (strong, nonatomic)                         NSArray                       *crewsArray;
@property (weak, nonatomic)         IBOutlet          UITableView                   *crewsTable;
@property (weak, nonatomic) IBOutlet UILabel                                        *nextStepDescription;
@property                           BOOL                                             isNewUser;

@end
