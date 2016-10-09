//
//  CCVideoTableViewCell.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCVideo.h"
#import <MapKit/MapKit.h>
#import "CCCoreManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CCVideosViewsViewController.h"
#import "CCVideosCommentsViewController.h"
#import "CCCrewViewController.h"
#import "NSDate+Utility.h"

#import "UIImagePickerController+CCCameraProperties.h"

#define VIDEO_DETAILS_PANE_WIDTH (float)609
#define MAP_PANE_OFFSET          289
#define SCREEN_WIDTH             320

typedef enum {
    standardTag,
    askToSaveTag,
} alertViewTag;

@interface CCVideoTableViewCell : UITableViewCell <CCVideoUpdatesDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CCVideoFilesUpdatesDelegate>
{
    UIImagePickerController *cameraUI;
    ccMediaSources mediaSource;
    NSMutableArray *crewsForVideo;
    NSString *videoPath;
}
@property (weak, nonatomic) IBOutlet UIButton                   *videoThumbnailButton;
@property (strong, nonatomic) IBOutlet UIView                   *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView                *videoThumbnailImage;
@property (weak, nonatomic) IBOutlet UIImageView                *creatorProfilePicView;
@property (weak, nonatomic) IBOutlet UILabel                    *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *numberOfCommentsLabel;
@property (weak, nonatomic) IBOutlet UIButton                   *viewCommentsButton;
@property (weak, nonatomic) IBOutlet UIButton                   *replyButton;
@property (weak, nonatomic) IBOutlet UILabel                    *numberOfViewsLabel;
@property (weak, nonatomic) IBOutlet UIButton                   *viewViewsButton;
@property (weak, nonatomic) IBOutlet UIButton                   *mapPaneButton;
@property (weak, nonatomic) IBOutlet UIView                     *detailsView;
@property (weak, nonatomic) IBOutlet UILabel                    *timeSinceVideoPostLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *videoLengthLabel;
@property (strong, nonatomic) IBOutlet MKMapView                *videoLocationMapView;
@property (strong, nonatomic) MPMoviePlayerViewController           *videoPlayer;
@property (weak, nonatomic) IBOutlet UIProgressView             *uploadProgressIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView    *loadingThumbnailIndicator;
@property (weak, nonatomic) IBOutlet UILabel                    *loadingText;
@property (weak, nonatomic) IBOutlet UIImageView                *unwatchedVideoImageView;
@property (weak, nonatomic) IBOutlet UIView                     *mapGlassOverlay;
@property (weak, nonatomic) IBOutlet UIView                     *mapLayer;
@property (weak, nonatomic)          CCCrewViewController       *parentNavigationViewController;
@property (weak, nonatomic)          id<CCVideo>                video;  
@property BOOL                                                  wasPlayingMedia;

- (void)initializeWithVideo:(id<CCVideo>) videoForCell andNavigationController:(CCCrewViewController *) navigationController;

- (IBAction)onDetailsPanePressed:(id)sender;
- (IBAction)onLocationPanePressed:(id)sender;
- (IBAction)onVideoThumbnailPressed:(id)sender;
- (IBAction)onViewViewsButtonPress:(id)sender;
- (IBAction)onViewCommentsButtonPress:(id)sender;
- (IBAction)onReplyButtonPress:(id)sender;

// This must be "wired" programattically, because the storyboard chokes trying to add connections to cells that haven't/won't be created
- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer;

@end
