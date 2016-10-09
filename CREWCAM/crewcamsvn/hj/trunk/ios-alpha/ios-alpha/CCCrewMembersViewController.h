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
#import "CCPeopleTableViewCell.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"
#import "UIView+Utilities.h"
#import "CCPeopleTableViewCell.h"

@interface CCCrewMembersViewController : UIViewController <CCCrewUpdatesDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel          *loadingLabel;
@property (strong, nonatomic) IBOutlet UITableView      *viewTableView;

@property (weak, nonatomic)          id<CCCrew>         crewForView;

@end
