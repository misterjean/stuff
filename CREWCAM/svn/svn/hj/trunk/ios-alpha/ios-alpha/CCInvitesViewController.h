//
//  CCInvitesViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"

@interface CCInvitesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *invitesTable;
@property (weak, nonatomic) IBOutlet UITabBarItem *invitesTabItem;
- (IBAction)onRefreshButtonPressed:(id)sender;
- (void)reloadInvites;
@property (weak, nonatomic) IBOutlet UILabel *noInvitesLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingInvitesIndicator;

@end
