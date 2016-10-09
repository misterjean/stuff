//
//  CCVideoViewController.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCrew.h"
#import "CCCoreManager.h"
#import "CCVideo.h"
#import "CCInviteViewController.h"
#import "CCCrewMembersViewController.h"
#import "CCRefreshTableView.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"

@interface CCCrewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CCRefreshTableDelegate, CCCrewUpdatesDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet CCRefreshTableView *videoTableView;
@property (strong, nonatomic) id<CCCrew> crewForView;
@property (strong, nonatomic) NSArray *sortedVideoList;
@property (weak, nonatomic) IBOutlet UILabel *noVideosLabel;
@property (weak, nonatomic) IBOutlet UIButton *publicPrivateCrewLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIView *crewBusyView;
-(void) initWithCrew:(id<CCCrew>)crew;

@end
