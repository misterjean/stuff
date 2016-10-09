//
//  CCVideoViewController.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CCCrew.h"
#import "CCCoreManager.h"
#import "CCVideo.h"
#import "CCNewCrewViewController.h"

#define VIDEO_OWNER_PICTURE_TAG     0
#define VIDEO_OWNER_NAME_TAG        1
#define VIDEO_TIME_POSTED_TAG       2
#define VIDEO_PREVIEW_PICTURE_TAG   3
#define VIDEO_NUMBER_OF_LIKES_TAG   4
#define VIDEO_DISTANCE_AWAY_TAG     5
#define VIDEO_TITLE_TAG             10

@interface CCCrewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *videoTableView;
@property (weak, nonatomic) id<CCCrew> crewForView;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@property (strong, nonatomic) NSArray *sortedVideoList;
@property (weak, nonatomic) IBOutlet UILabel *noVideosLabel;
- (IBAction)onLeaveButtonPressed:(id)sender;


@end
