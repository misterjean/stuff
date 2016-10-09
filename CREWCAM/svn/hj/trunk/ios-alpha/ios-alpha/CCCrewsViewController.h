//
//  CCCrewsViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCUser.h"
#import "CCCrewTableViewCell.h"
#import "CCCrewViewController.h"
#import "CCVideosCommentsViewController.h"
#import "CCWelcomeViewController.h"
@interface CCCrewsViewController : UIViewController <CCUserUpdatesDelegate, UITableViewDataSource, UITableViewDelegate>
{
    id<CCVideo> videoForComment;
    id<CCCrew> crewForComment;
}
@property (weak, nonatomic) IBOutlet UITableView *crewsTableView;
@property (weak, nonatomic) IBOutlet UILabel *crewsActivityLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)onLogoutButtonPressed:(id)sender;



@end
