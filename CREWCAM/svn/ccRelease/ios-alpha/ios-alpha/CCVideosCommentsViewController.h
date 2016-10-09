//
//  CCVideosCommentsViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCVideo.h"
#import "CCCommentTableViewCell.h"
#import "CCCoreManager.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"
#import "UIView+Utilities.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CCVideosCommentsViewController : UIViewController <CCVideoUpdatesDelegate, UITableViewDataSource, CCCrewcamAlertViewDelegate>

@property (weak, nonatomic)     IBOutlet    UILabel                     *loadingLabel;
@property (weak, nonatomic)     IBOutlet    UITableView                 *commentsTableView;
@property (strong, nonatomic)               id<CCVideo>                 videoForView;
@property (strong, nonatomic)               MPMoviePlayerViewController *videoPlayer;
@property BOOL                                                          wasPlayingMedia;
@property (strong, nonatomic)               id<CCCrew>                  crewForView;

- (void) setVideoForView:(id<CCVideo>) video;
- (IBAction)onAddCommentPressed:(id)sender;

@end
