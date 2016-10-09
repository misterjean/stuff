//
//  CCNewCrewViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"


@interface CCNewCrewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingFriendsIndicator;
@property (strong, nonatomic) NSArray *friendsArray;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
- (IBAction)onCancelButtonPressed:(id)sender;
- (IBAction)onDoneButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *crewNameField;
@property (strong, nonatomic) IBOutlet UINavigationItem *crewNavigationBar;
@property id<CCCrew> passedCrew;
- (IBAction)hideKeyboad:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *noFriendsLabel;
@property (strong, nonatomic) NSMutableSet *checkedIndexPaths;
@property (weak, nonatomic) IBOutlet UISegmentedControl *publicPrivateSelecor;

@end
