//
//  CCVideoIconView.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-25.
//
//

#import "CCVideoIconView.h"

@implementation CCVideoIconView
@synthesize frontVideoView;
@synthesize videoThumbnailButton;
@synthesize videoThumbnailImage;
@synthesize uploadProgressIndicator;
@synthesize loadingThumbnailIndicator;
@synthesize rearVideoView;
@synthesize creatorProfilePicView;
@synthesize creatorNameLabel;
@synthesize timeSinceVideoPostLabel;
@synthesize videoLengthLabel;
@synthesize videoLocationLabel;
@synthesize numberOfViewsLabel;
@synthesize numberOfCommentsLabel;
@synthesize viewViewsButton;
@synthesize viewCommentsButton;
@synthesize videoPlayer;
@synthesize doubleTapView;
@synthesize unwatchedVideoImageView;
@synthesize parentNavigationViewController;
@synthesize wasPlayingMedia;
@synthesize deleteVideoButton;
@synthesize cancelUploadButton;
@synthesize uploadingImageOverlay;
@synthesize flipToRearButton;
@synthesize videoDeleteOverlay;
@synthesize isVideoPlaying;

@synthesize video;
@synthesize singleTapGesture;
@synthesize videoIsFullScreen;

- (void) dealloc
{
    frontVideoView = nil;
    videoThumbnailButton = nil;
    videoThumbnailImage = nil;
    uploadProgressIndicator = nil;
    loadingThumbnailIndicator = nil;
    rearVideoView = nil;
    creatorProfilePicView = nil;
    creatorNameLabel = nil;
    timeSinceVideoPostLabel = nil;
    videoLengthLabel = nil;
    videoLocationLabel = nil;
    videoDeleteOverlay = nil;
    numberOfViewsLabel = nil;
    numberOfCommentsLabel = nil;
    viewViewsButton = nil;
    viewCommentsButton = nil;
    videoPlayer = nil;
    unwatchedVideoImageView = nil;
    parentNavigationViewController = nil;
    deleteVideoButton = nil;
    cancelUploadButton = nil;
    uploadingImageOverlay = nil;
    video = nil;
    
    [self removeGestureRecognizer:swipeGestureLeft];
    swipeGestureLeft = nil;
    
    [self removeGestureRecognizer:swipeGestureRight];
    swipeGestureRight = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) tapTimeout
{
    
    if (tapsInTimeout > 1)
    {
        [self doubleTap];
    }
    else if (tapsInTimeout == 1)
    {
        [self singleTap];
    }
    tapsInTimeout = 0;
}

- (void)singleTap
{
    tapTimerRunning = NO;
    if(isVideoPlaying)
    {
        if (videoIsPaused)
        {
            videoIsPaused = NO;
            [self.videoPlayer.moviePlayer play];
        }
        else
        {
            videoIsPaused = YES;
            [self.videoPlayer.moviePlayer pause];
        }
    }
    else
    {
        if (![video isUploading])
            [self playVideo];
    }
}

- (void)doubleTap
{
    tapTimerRunning = NO;
    if(isVideoPlaying)
    {
        if(videoIsFullScreen)
        {
            videoIsFullScreen = NO;
            
            [UIView animateWithDuration:0.5 animations:^{
                if ([video isLandscape])
                {
                    self.videoPlayer.moviePlayer.view.transform = CGAffineTransformMakeRotation(0);
                }
                [self.videoPlayer.moviePlayer.view setFrame:CGRectMake([frontVideoView convertPoint:frontVideoView.frame.origin toView:[[[UIApplication sharedApplication] delegate] window]].x, [frontVideoView convertPoint:frontVideoView.frame.origin toView:[[[UIApplication sharedApplication] delegate] window]].y, self.frontVideoView.frame.size.width, self.frontVideoView.frame.size.height)];
                
            } completion:^(BOOL finished) {
                if (finished)
                {
                    [self.videoPlayer.moviePlayer.view removeFromSuperview];
                    [self.doubleTapView removeFromSuperview];
                    [frontVideoView addSubview:self.doubleTapView];
                    [frontVideoView addSubview:self.videoPlayer.moviePlayer.view];
                    [self.videoPlayer.moviePlayer.view setFrame:CGRectMake(0, 0, self.frontVideoView.frame.size.width, self.frontVideoView.frame.size.height)];
                    [frontVideoView bringSubviewToFront:doubleTapView];
                    [frontVideoView bringSubviewToFront:flipToRearButton];
                }
            }];
            
            [self.videoPlayer.moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
        }
        else
        {
            videoIsFullScreen = YES;
            
            [self.videoPlayer.moviePlayer.view removeFromSuperview];
            [self.doubleTapView removeFromSuperview];
            
            [[[[UIApplication sharedApplication] delegate] window] addSubview:self.doubleTapView];
            [[[[UIApplication sharedApplication] delegate] window] addSubview:self.videoPlayer.moviePlayer.view];
            
            [self.videoPlayer.moviePlayer.view setFrame:CGRectMake([frontVideoView convertPoint:frontVideoView.frame.origin toView:[[[UIApplication sharedApplication] delegate] window]].x, [frontVideoView convertPoint:frontVideoView.frame.origin toView:[[[UIApplication sharedApplication] delegate] window]].y, self.videoPlayer.moviePlayer.view.frame.size.width, self.videoPlayer.moviePlayer.view.frame.size.height)];
            
            [UIView animateWithDuration:0.5 animations:^{
                if ([video isLandscape])
                {
                    self.videoPlayer.moviePlayer.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                }
                [self.videoPlayer.moviePlayer.view setFrame:[[[UIApplication sharedApplication] delegate] window].frame];
            }];
            
            [doubleTapView setFrame:[[[UIApplication sharedApplication] delegate] window].frame];
            [self.videoPlayer.moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
            [[[[UIApplication sharedApplication] delegate] window] bringSubviewToFront:doubleTapView];
        }
    }
}

//This is a singleTap recognizer but the majority of its code only gets called when a double tap is registered.
- (IBAction)onSingleTap:(id)sender
{
    tapsInTimeout++;
    if (!tapTimerRunning)
    {
        tapTimerRunning = YES;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target: self selector: @selector(tapTimeout) userInfo: nil repeats: NO];
    }
}

- (void)initializeWithVideo:(id<CCVideo>) videoForCell andNavigationController:(CCCrewViewController *) navigationController
{
    [frontVideoView bringSubviewToFront:doubleTapView];
    [frontVideoView bringSubviewToFront:flipToRearButton];
    
    if (video == videoForCell)
        return;
    
    if(isVideoPlaying)
    {
        [self.videoPlayer.moviePlayer stop];
    }
    
    [self configureGestureRecognition];
    
    frontVideoView.layer.cornerRadius = 15;
    rearVideoView.layer.cornerRadius = 15;
    
    creatorProfilePicView.layer.cornerRadius = 9;
    
    self.videoIsFullScreen = NO;
    
    self.clipsToBounds = YES;
    
    if (video)
    {
        [video removeVideoUpdateListener:self];
    }
    
    [self setParentNavigationViewController:navigationController];

    video = videoForCell;
    
    [video addVideoUpdateListener:self];
    
    [[self unwatchedVideoImageView] setHidden:YES];
    
    [[self loadingThumbnailIndicator] setHidden:YES];
    
    [frontVideoView setHidden:YES];
    [rearVideoView setHidden:NO];
    
    [videoThumbnailImage setImage:nil];
    
    if ([videoForCell isUploading])
    {
        [uploadingImageOverlay setHidden:NO];
        [uploadProgressIndicator setProgress:((float)[video getUploadPercentComplete]/100)];
        [video loadThumbnailInBackgroundWithBlockOrNil:nil];
        [videoLengthLabel setText:nil];
        [loadingThumbnailIndicator setHidden:YES];
        [uploadProgressIndicator setHidden:NO];
        [timeSinceVideoPostLabel setText:@""];
        [viewCommentsButton setHidden:YES];
        [numberOfCommentsLabel setHidden:YES];
        [viewViewsButton setHidden:YES];
        [numberOfViewsLabel setHidden:YES];
        [cancelUploadButton setHidden:NO];
        [deleteVideoButton setHidden:NO];
        [flipToRearButton setHidden:YES];
    }
    else
    {
        [flipToRearButton setHidden:NO];
        [uploadingImageOverlay setHidden:YES];
        [cancelUploadButton setHidden:YES];
        if ([[[video getTheOwner] getObjectID] isEqualToString:[[[[CCCoreManager sharedInstance] server] currentUser] getObjectID]])
        {
            [deleteVideoButton setHidden:NO];
        }
        else
        {
            [deleteVideoButton setHidden:YES];
        }
        
        [uploadProgressIndicator setHidden:YES];
        [timeSinceVideoPostLabel setText:[NSDate getTimeSinceStringFromDate:[videoForCell getObjectCreatedDate]]];
        [viewCommentsButton setHidden:NO];
        [numberOfCommentsLabel setHidden:NO];
        [viewViewsButton setHidden:NO];
        [numberOfViewsLabel setHidden:NO];
        
        [video loadLocationPlacemarkInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [videoLocationLabel setText:[video getNameOfLocation]];
        }];
            
        if ([video getThumbnail] == nil)
        {
            [loadingThumbnailIndicator setHidden:NO];
            [video loadThumbnailInBackgroundWithBlockOrNil:nil];
            [videoThumbnailImage setImage:nil];
        }
        else
        {
            [loadingThumbnailIndicator setHidden:YES];
            [videoThumbnailImage setImage:[video getThumbnail]];
            [frontVideoView setHidden:NO];
            [rearVideoView setHidden:YES];
        }
        
        if ([video isNewVideo] == CCStatusUnknown)
        {
            [video isVideoNewWithBlockOrNil:^(int CCWatchedStatus, BOOL succeded, NSError *error) {
                if (succeded)
                {
                    if (CCWatchedStatus == CCStatusUnwatched)
                    {
                        [[self unwatchedVideoImageView] setHidden:NO];
                    }
                    else
                    {
                        [[self unwatchedVideoImageView] setHidden:YES];
                    }
                }
            }];
        }
        else if ([video isNewVideo] == CCStatusUnwatched)
        {
            [[self unwatchedVideoImageView] setHidden:NO];
            
        }
        else if ([video isNewVideo] == CCStatusWatched)
        {
            [[self unwatchedVideoImageView] setHidden:YES];
        }
        
        [self setVideoLength];
    }
    
    [creatorProfilePicView setHidden:YES];
    
    __block id<CCVideo> videoForOwnerPicture = video;
    
    [[video getTheOwner] getProfilePictureInBackgroundWithBlock:^(UIImage *image, NSError *error) {
        if (videoForOwnerPicture == video)
        {
            [creatorProfilePicView setImage:image];
            [creatorProfilePicView setHidden:NO];
        }
    }];
    
    [creatorNameLabel setText:[[video getTheOwner] getName]];
    
    [self setNumberOfViews];
    
    [self setNumberOfComments];
    tapsInTimeout = 0;
    isVideoPlaying = NO;
    videoIsPaused = NO;
}



- (void)configureGestureRecognition
{
    // Handle pan gestures in this view
    swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeGestureRight];
    
    swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;    
    [self addGestureRecognizer:swipeGestureLeft];
}


- (void)setNumberOfViews
{
    NSString *numberOfViewsString;
    if ([video getNumberOfViews] == 1)
    {
        numberOfViewsString = [[NSString alloc] initWithFormat:@"1 VIEWER"];
    }
    else
    {
        numberOfViewsString = [[NSString alloc] initWithFormat:@"%d VIEWERS", [video getNumberOfViews]];
    }
    [numberOfViewsLabel setText:numberOfViewsString];
}

- (void)setNumberOfComments
{
    NSString *numberOfCommentsString;
    if ([video getNumberOfComments] == 1)
    {
        numberOfCommentsString = [[NSString alloc] initWithFormat:@"1 COMMENT"];
    }
    else
    {
        numberOfCommentsString = [[NSString alloc] initWithFormat:@"%d COMMENTS", [video getNumberOfComments]];
    }
    [numberOfCommentsLabel setText:numberOfCommentsString];
}

- (void) setVideoLength
{
    if ([video getVideoDuration] < 2)
    {
        [videoLengthLabel setText:[[NSString alloc] initWithFormat:@"1 second"]];
    }
    else
    {
        [videoLengthLabel setText:[[NSString alloc] initWithFormat:@"%.f seconds", [video getVideoDuration]]];
    }
    
}

- (IBAction)onViewViewsButtonPress:(id)sender
{
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_VIEWS withProperties:nil];
    [viewViewsButton setHighlighted:NO];
    CCVideosViewsViewController *videosViewsView = [[parentNavigationViewController storyboard] instantiateViewControllerWithIdentifier:@"videosViewsView"];
    
    [videosViewsView setVideoForView:video];
    
    [[parentNavigationViewController navigationController] pushViewController:videosViewsView animated:YES];
}
- (IBAction)onViewCommentsButtonPress:(id)sender
{
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_COMMENTS withProperties:nil];
    [viewCommentsButton setHighlighted:NO];
    CCVideosCommentsViewController *videosViewsView = [[parentNavigationViewController storyboard] instantiateViewControllerWithIdentifier:@"videosCommentsView"];
    
    [videosViewsView setVideoForView:video];
    
    [videosViewsView setCrewForView:[parentNavigationViewController crewForView]];
    
    [[parentNavigationViewController navigationController] pushViewController:videosViewsView animated:YES];
}

//Called when Play button is pressed in cell
- (void)playVideo
{
    [[self loadingThumbnailIndicator] setHidden:NO];
    
    /*This code may look stupid, and maybe it is. Essentially we spawn a new thread and do nothing.
     The reason we do this is because the button press action call needs complete and return for the gui
     to update. The GUI needs to update to display an activity indicator while the video loads.
     Dispatching a new thread was the only way I could think of doing it. If you have a better solution
     feel free to implement it.*/
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying)
                wasPlayingMedia = YES;
            
            self.videoPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[[NSURL alloc] initWithString:[video getVideoURL]]];

            self.videoPlayer.moviePlayer.allowsAirPlay=YES;
            self.videoPlayer.moviePlayer.useApplicationAudioSession = NO;
            
            // This forces audio to play even if mute switch is set
            NSError *error;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
            
            if (error)
            {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Audio Session Error: %@, %@", error, [error userInfo]];
            }

// The below commented out code is part of Gamification... saving for a later release.
            [[[[CCCoreManager sharedInstance] server] currentUser] incrementUserRewardPointsByValueInBackground:1 forCrew:[parentNavigationViewController crewForView] block:^(BOOL succeeded, NSError *error)
            {
                if (error)
                {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"An error occured while increasing reward points. So points were not awarded to the current user for viewing the video."];
                }
            }];
            
            
            [video addViewInBackground:[[[CCCoreManager sharedInstance] server] currentUser] withBlockOrNil:nil];                    
            
            [self.frontVideoView addSubview:self.videoPlayer.moviePlayer.view];
            
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(playMovieFinished:)
             name:MPMoviePlayerPlaybackDidFinishNotification
             object:self.videoPlayer.moviePlayer];
            
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(MPMoviePlayerDidExitFullscreen:)
             name:MPMoviePlayerDidExitFullscreenNotification
             object:self.videoPlayer.moviePlayer];
            
            [self.videoPlayer.moviePlayer setControlStyle:MPMovieControlStyleNone];
            [self.videoPlayer.moviePlayer.view setFrame:[self bounds]];
            [self.videoPlayer.moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
            
            isVideoPlaying = YES;
            [self.videoPlayer.moviePlayer play];
            
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_VIEWED_VIDEO withProperties:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoInCell) name:CC_STOP_PLAYING_VIDEOS_IN_CREW object:nil];
            
            [frontVideoView bringSubviewToFront:doubleTapView];
            [frontVideoView bringSubviewToFront:flipToRearButton];
        });
    });
}

- (void) handlePlaybackCompletion
{
    isVideoPlaying = NO;
    videoIsFullScreen = NO;
    [self.videoPlayer.moviePlayer.view removeFromSuperview];
    [[self loadingThumbnailIndicator] setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.videoPlayer.moviePlayer stop];
    self.videoPlayer = nil;
    
    [[self unwatchedVideoImageView] setHidden:YES];
    
    //[frontVideoView sendSubviewToBack:doubleTapView];
    
    if (wasPlayingMedia)
    {
        [[MPMusicPlayerController iPodMusicPlayer] play];
        wasPlayingMedia = NO;
    }
}

- (void)playMovieFinished:(NSNotification*)theNotification
{
    [[self loadingThumbnailIndicator] setHidden:YES];
    
    [self.videoPlayer.moviePlayer.view removeFromSuperview];
    [doubleTapView removeFromSuperview];
    
    [frontVideoView addSubview:doubleTapView];
    [frontVideoView bringSubviewToFront:doubleTapView];
    [frontVideoView bringSubviewToFront:flipToRearButton];
    
    NSError *error = [[theNotification userInfo] objectForKey:@"error"];
    
    if (error)
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed Loading Video: %@", [error localizedDescription]];
        
        CCCrewcamAlertView * alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Video Playback Error" message:[error localizedDescription] withTextField:NO delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
        
        [alert show];
    }
    
    [self handlePlaybackCompletion];
}

- (void)MPMoviePlayerDidExitFullscreen:(NSNotification *)notification
{
    [self handlePlaybackCompletion];
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    // Don't let the user flip the video if we're uploading
    if ([video isUploading])
        return;
    
    [UIView transitionWithView:self duration:0.5 options:(recognizer.direction == UISwipeGestureRecognizerDirectionRight) ?UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight animations:^{
        
        frontVideoView.layer.cornerRadius = 15;
        rearVideoView.layer.cornerRadius = 15;
        self.clipsToBounds = YES;
        
        [frontVideoView setHidden:![frontVideoView isHidden]];
        [rearVideoView setHidden:![rearVideoView isHidden]];
        
    } completion:^(BOOL finished) {
        if ([frontVideoView isHidden]){
            
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_VIEWED_VIDEO_DETAILS withProperties:nil];
        }
    }];
}


- (IBAction)onDeleteButtonPress:(id)sender
{
    if ([video isUploading])
    {
        CCCrewcamAlertView *deleteConfirmDialog = [[CCCrewcamAlertView alloc] initWithTitle:@"You sure?"
                                                                                    message:@"Are you sure you want to cancel this upload?"
                                                                              withTextField:NO
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"No"
                                                                          otherButtonTitles:@"Yes", nil];
        
        deleteConfirmDialog.tag = confirmCancelTag;
        
        [deleteConfirmDialog show];
        
        return;
    }
    
    CCCrewcamAlertView *deleteConfirmDialog = [[CCCrewcamAlertView alloc] initWithTitle:@"You sure?"
                                                                                message:@"Are you sure you want to delete this video forever?"
                                                                          withTextField:NO
                                                                               delegate:self
                                                                      cancelButtonTitle:@"No"
                                                                      otherButtonTitles:@"Yes", nil];
    
    deleteConfirmDialog.tag = confirmDeleteTag;
    
    [deleteConfirmDialog show];
}

- (IBAction)onFlipFromRearButtonPressed:(id)sender {
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        [frontVideoView setHidden:NO];
        [rearVideoView setHidden:YES];
    } completion:nil];
}

- (IBAction)onFlipFromFrontButtonPressed:(id)sender {
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        [frontVideoView setHidden:YES];
        [rearVideoView setHidden:NO];
    } completion:nil];
}

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case confirmDeleteTag:
            if (buttonIndex == 1)
            {
                [videoDeleteOverlay setHidden:NO];    
                [loadingThumbnailIndicator setHidden:NO];
                [video deleteObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                    [videoDeleteOverlay setHidden:YES];
                    if (!succeeded)
                    {
                        [loadingThumbnailIndicator setHidden:YES];
                        [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_DELETING_VIDEO withProperties:nil];
                    }
                    
                    else
                    {
                        [[CCCoreManager sharedInstance] recordMetricEvent:CC_SUCCESSFULLY_DELETED_VIDEO withProperties:nil];
                    }
                }];
            }
            break;
        case confirmCancelTag:
        {
            if (buttonIndex == 1)
            {
                [video cancelUpload];
            }
        }
        default:
            break;
    }   
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer class] == [UITapGestureRecognizer class] || [otherGestureRecognizer class] == [UISwipeGestureRecognizer class])
        return YES;
    
    return NO;
}

- (void) finishedLoadingThumbnailWithSucess:(BOOL) successful andError:(NSError *) error
{
    [loadingThumbnailIndicator setHidden:YES];
    
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [frontVideoView setHidden:NO];
        [rearVideoView setHidden:YES];
    } completion:nil];

    if (successful)
        [videoThumbnailImage setImage:[video getThumbnail]];
}

- (void) addedNewViewsAtIndexes:(NSArray *) addedViewsIndexes andRemovedViewsAtIndexes:(NSArray *)removedViewsIndexes
{
    [self setNumberOfViews];
}

- (void) addedNewCommentsAtIndexes:(NSArray *) addedCommentIndexes andRemovedCommentsAtIndexes:(NSArray *)removedCommentIndexes
{
    [self setNumberOfComments];
}

- (void)finishedLoadingCommentsWithSuccess:(BOOL)successful andError:(NSError *)error
{
    if (successful)
        [self setNumberOfComments];
}

- (void) finishedLoadingViewersWithSuccess:(BOOL)successful andError:(NSError *)error
{
    if (successful)
        [self setNumberOfViews];
}

- (void) finishedUploadingVideoWithSuccess:(BOOL)successful error:(NSError *)error andVideoReference:(id<CCVideo>)videoReference
{
    if (successful)
    {
        [flipToRearButton setHidden:NO];
        [uploadingImageOverlay setHidden:YES];
        [cancelUploadButton setHidden:YES];
        [timeSinceVideoPostLabel setText:[NSDate getTimeSinceStringFromDate:[video getObjectCreatedDate]]];
        [self setVideoLength];
        [viewCommentsButton setHidden:NO];
        [numberOfCommentsLabel setHidden:NO];
        [viewViewsButton setHidden:NO];
        [numberOfViewsLabel setHidden:NO];
        [uploadProgressIndicator setHidden:YES];
    }
}

- (void) videoUploadProgressIsAtPercent:(int)percent
{
    [uploadProgressIndicator setProgress:((float)percent/100)];
}

- (void) stopVideoInCell
{
    if(isVideoPlaying)
    {
        [self.videoPlayer.moviePlayer stop];
    }
}

@end
