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
#import "CCNewCrewViewController.h"
#import "CCCrewMembersViewController.h"
#import "CCVideoTableViewCell.h"

<<<<<<< .mine
#define VIDEO_OWNER_NAME_TAG        1
#define VIDEO_TIME_POSTED_TAG       2
#define VIDEO_PREVIEW_PICTURE_TAG   3
#define VIDEO_NUMBER_OF_LIKES_TAG   4
#define VIDEO_DISTANCE_AWAY_TAG     5
#define VIDEO_PLAY_BUTTON           6
#define VIDEO_VIEWS_BUTTON          7
#define VIDEO_TITLE_TAG             10
#define VIDEO_OWNER_PICTURE_TAG     11
#define VIDEO_LENGTH                12

@interface CCCrewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
=======
@interface CCCrewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CCCrewUpdatesDelegate>
>>>>>>> .r260
{
@private id<CCVideo> selectedVideo;
}

- (IBAction)doSomething:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *videoTableView;
@property (strong, nonatomic) id<CCCrew> crewForView;
@property (strong, nonatomic) NSArray *sortedVideoList;
@property (weak, nonatomic) IBOutlet UILabel *noVideosLabel;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
- (IBAction)onLeaveButtonPressed:(id)sender;


@end
