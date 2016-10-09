//
//  CCJoinCrewsViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCTempViewController.h"

@interface CCWelcomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *crewsArray;
@property (weak, nonatomic) IBOutlet UITableView *crewsTable;
@property (weak, nonatomic) IBOutlet UILabel *nextStepDescription;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) NSMutableSet *checkedIndexPaths;

- (IBAction)onNextButtonPressed:(id)sender;

@end
