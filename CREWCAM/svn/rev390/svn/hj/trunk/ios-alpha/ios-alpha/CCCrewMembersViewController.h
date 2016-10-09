//
//  CCCrewMembersViewController.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCrew.h"
#import "CCUser.h"
#import "CCCrewMemberTableCell.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"

@interface CCCrewMembersViewController : UIViewController <CCCrewUpdatesDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) IBOutlet UITableView *viewTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (weak, nonatomic)          id<CCCrew> crewForView;

@end
