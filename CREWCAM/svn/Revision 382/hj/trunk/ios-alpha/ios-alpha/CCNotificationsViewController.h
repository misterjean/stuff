//
//  CCNotificationsViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCNotificationTableViewCell.h"

@interface CCNotificationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CCUserUpdatesDelegate>

@property (weak, nonatomic) IBOutlet UITableView *notificationsTableView;

- (IBAction)clearAllButtonPressed:(id)sender;

@end
