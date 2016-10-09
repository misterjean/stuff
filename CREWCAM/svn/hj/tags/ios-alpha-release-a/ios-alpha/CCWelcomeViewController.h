//
//  CCJoinCrewsViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCServerLoadFriendsCrewsDelegate.h"
#import "CCCoreManager.h"
#import "CCTempViewController.h"

@interface CCWelcomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CCServerLoadFriendsCrewsDelegate>
@property (strong, nonatomic) NSArray *crewsArray;
@property (weak, nonatomic) IBOutlet UITableView *crewsTable;
@property (weak, nonatomic) IBOutlet UILabel *nextStepDescription;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)onNextButtonPressed:(id)sender;

@end
