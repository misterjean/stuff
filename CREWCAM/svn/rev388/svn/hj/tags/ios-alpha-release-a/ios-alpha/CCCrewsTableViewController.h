//
//  CCCrewViewController.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCCrew.h"
#import "CCCrewViewController.h"

@interface CCCrewsTableViewController : UITableViewController

- (IBAction)onRefreshButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *reloadingCrewsIndicator;

@end
