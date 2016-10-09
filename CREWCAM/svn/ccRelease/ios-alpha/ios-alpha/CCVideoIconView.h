//
//  CCVideoIconView.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-25.
//
//

#import <UIKit/UIKit.h>
#import "CCVideo.h"
#import "CCVideoFiles.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CCCrewViewController.h"
#import "UIImagePickerController+CCCameraProperties.h"
#import "NSDate+Utility.h"
#import "CCVideosViewController.h"
#import "CCVideosViewsViewController.h"
#import "CCVideosCommentsViewController.h"

typedef enum {
    standardTag = 1,
    askToSaveTag,
    confirmDeleteTag,
    confirmCancelTag,
} alertViewTag;

@interface CCVideoIconView : UIView <CCVideoUpdatesDelegate,  CCVideoFilesUpdatesDelegate, CCCrewcamAlertViewDelegate>
{
    NSMutableArray              *crewsForVideo;
    UISwipeGestureRecognizer    *swipeGestureLeft;
    UISwipeGestureRecognizer    *swipeGestureRight;
    int                         tapsInTimeout;
    BOOL                        tapTimerRunning;
    BOOL                        videoIsPaused;
}

/* The Front */
@property (weak, nonatomic) IBOutlet CCVideoIconView            *frontVideoView;

@property (weak, nonatomic) IBOutlet UIButton                   *videoThumbnailButton;
@property (weak, nonatomic) IBOutlet UIImageView                *videoThumbnailImage;
@property (weak, nonatomic) IBOutlet UIProgressView             *uploadProgressIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView    *loadingThumbnailIndicator;

/* The Back */
@property (weak, nonatomic) IBOutlet UIView                     *rearVideoView;

@property (weak, nonatomic) IBOutlet UIImageView                *creatorProfilePicView;
@property (weak, nonatomic) IBOutlet UILabel                    *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *timeSinceVideoPostLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *videoLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *videoLocationLabel;

@property (weak, nonatomic) IBOutlet UIView                     *videoDeleteOverlay;

@property (weak, nonatomic) IBOutlet UILabel                    *numberOfViewsLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *numberOfCommentsLabel;

@property (weak, nonatomic) IBOutlet UIButton                   *viewViewsButton;
@property (weak, nonatomic) IBOutlet UIButton                   *viewCommentsButton;

@property (strong, nonatomic) MPMoviePlayerViewController       *videoPlayer;
@property (strong, nonatomic) IBOutlet UIView                   *doubleTapView;

@property (weak, nonatomic) IBOutlet UIView                     *unwatchedVideoImageView;

@property (weak, nonatomic)          CCCrewViewController       *parentNavigationViewController;

@property BOOL                                                  wasPlayingMedia;
@property BOOL                                                  isVideoPlaying;

@property (weak, nonatomic) IBOutlet UIButton                   *deleteVideoButton;
@property (weak, nonatomic) IBOutlet UIButton                   *cancelUploadButton;
@property (weak, nonatomic) IBOutlet UIView                     *uploadingImageOverlay;

@property (weak, nonatomic) IBOutlet UIButton                   *flipToRearButton;

@property (weak, nonatomic) id<CCVideo>                         video;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer     *singleTapGesture;

@property BOOL                                                  videoIsFullScreen;

- (void)initializeWithVideo:(id<CCVideo>) videoForCell andNavigationController:(CCCrewViewController *) navigationController;
- (void) stopVideoInCell;
- (IBAction)onSingleTap:(id)sender;
- (IBAction)onViewViewsButtonPress:(id)sender;
- (IBAction)onViewCommentsButtonPress:(id)sender;
- (IBAction)onDeleteButtonPress:(id)sender;
- (IBAction)onFlipFromRearButtonPressed:(id)sender;
- (IBAction)onFlipFromFrontButtonPressed:(id)sender;

@end
