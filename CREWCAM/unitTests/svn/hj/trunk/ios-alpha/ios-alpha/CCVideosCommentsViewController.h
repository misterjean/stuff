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
#import <MediaPlayer/MediaPlayer.h>

@interface CCVideosCommentsViewController : UIViewController <CCVideoUpdatesDelegate, UITableViewDataSource>
{
    UITextField *commentTextField;
}
@property (weak, nonatomic)     IBOutlet    UILabel                     *loadingLabel;
@property (weak, nonatomic)     IBOutlet    UIActivityIndicatorView     *loadingActivityIndicator;
@property (weak, nonatomic)     IBOutlet    UITableView                 *commentsTableView;
@property (weak, nonatomic)     IBOutlet    UIView                      *videoInfoView;
@property (weak, nonatomic)     IBOutlet    UIImageView                 *videoThumbnail;
@property (weak, nonatomic)     IBOutlet    UILabel                     *videoTitleLabel;
@property (strong, nonatomic)               id<CCVideo>                 videoForView;
@property (strong, nonatomic)               MPMoviePlayerViewController *videoPlayer;
@property BOOL                                                          wasPlayingMedia;

- (void) setVideoForView:(id<CCVideo>) video;
- (IBAction)onAddCommentPressed:(id)sender;
- (IBAction)videoThumbnailPressed:(id)sender;
@end
