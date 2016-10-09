//
//  CCNotificationsViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"
#import "UIView+Utilities.h"

@interface CCNotificationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CCUserUpdatesDelegate>

@property (weak, nonatomic) IBOutlet UIView         *globalActivityView;
@property (weak, nonatomic) IBOutlet UITableView    *notificationsTableView;
@property (weak, nonatomic) IBOutlet UILabel        *noNotificationsLabel;

@end
