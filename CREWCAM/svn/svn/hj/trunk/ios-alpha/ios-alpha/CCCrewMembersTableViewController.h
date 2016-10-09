//
//  CCCrewMembersTableViewController.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-05-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"

@interface CCCrewMembersTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *totalMembersLabel;

@property (strong, nonatomic)   NSArray     *members;
@property (strong, nonatomic)   NSString    *viewHeaderText;
@property (strong, nonatomic)   NSString    *totalText;
@property (strong, nonatomic) IBOutlet UINavigationItem *viewNavigationHeader;

@end
