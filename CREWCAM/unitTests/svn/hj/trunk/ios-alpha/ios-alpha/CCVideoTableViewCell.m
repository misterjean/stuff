//
//  CCVideoTableViewCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCVideoTableViewCell.h"

@implementation CCVideoTableViewCell
@synthesize videoThumbnailButton;
@synthesize videoThumbnailImage;
@synthesize creatorProfilePicView;
@synthesize creatorNameLabel;
@synthesize numberOfCommentsLabel;
@synthesize viewCommentsButton;
@synthesize replyButton;
@synthesize numberOfViewsLabel;
@synthesize viewViewsButton;
@synthesize mapPaneButton;
@synthesize detailsView;
@synthesize timeSinceVideoPostLabel;
@synthesize videoLengthLabel;
@synthesize videoLocationMapView;
@synthesize videoPlayer;
@synthesize activityIndicator;
@synthesize uploadProgressIndicator;
@synthesize loadingThumbnailIndicator;
@synthesize loadingText;
@synthesize unwatchedVideoImageView;
@synthesize mapGlassOverlay;
@synthesize mapLayer;
@synthesize wasPlayingMedia;

@synthesize parentNavigationViewController;
@synthesize video;

- (void)dealloc
{
    [video removeVideoUpdateListener:self];
    
    cameraUI = nil;
    crewsForVideo = nil;
    videoPath = nil;
    
    [self setVideoThumbnailButton:nil];
    [self setActivityIndicator:nil];
    [self setVideoThumbnailImage:nil];
    [self setCreatorProfilePicView:nil];
    [self setCreatorNameLabel:nil];
    [self setNumberOfCommentsLabel:nil];
    [self setViewCommentsButton:nil];
    [self setReplyButton:nil];
    [self setNumberOfViewsLabel:nil];
    [self setViewViewsButton:nil];
    [self setMapPaneButton:nil];
    [self setDetailsView:nil];
    [self setTimeSinceVideoPostLabel:nil];
    [self setVideoLengthLabel:nil];
    [self setVideoLocationMapView:nil];
    [self setVideoPlayer:nil];
    [self setUploadProgressIndicator:nil];
    [self setLoadingThumbnailIndicator:nil];
    [self setLoadingText:nil];
    [self setUnwatchedVideoImageView:nil];
    [self setMapGlassOverlay:nil];
    [self setMapLayer:nil];
    [self setParentNavigationViewController:nil];
    [self setVideo:nil];
}

- (void)configureGestureRecognition
{
    // Handle both swipe directions on this view
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];    
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
}

- (void)setNumberOfViews
{
    NSString *numberOfViewsString;    
    if ([video getNumberOfViews] == 1)
    {
        numberOfViewsString = [[NSString alloc] initWithFormat:@"1 viewer"];
    }
    else 
    {
        numberOfViewsString = [[NSString alloc] initWithFormat:@"%d viewers", [video getNumberOfViews]];        
    }
    [numberOfViewsLabel setText:numberOfViewsString];
}

- (void)setNumberOfComments
{
    NSString *numberOfCommentsString;    
    if ([video getNumberOfComments] == 1)
    {
        numberOfCommentsString = [[NSString alloc] initWithFormat:@"1 comment"];                
    }
    else 
    {
        numberOfCommentsString = [[NSString alloc] initWithFormat:@"%d comments", [video getNumberOfComments]];                
    }        
    [numberOfCommentsLabel setText:numberOfCommentsString];
}

- (void)initializeWithVideo:(id<CCVideo>) videoForCell andNavigationController:(CCCrewViewController *) navigationController
{
    // Have we already initialized?
    if (video == videoForCell)
        return;
    
    parentNavigationViewController = navigationController;
    video = videoForCell;    
    
    [self configureGestureRecognition];
    
    [video addVideoUpdateListener:self];
    
    [[self unwatchedVideoImageView] setHidden:YES];
    
    if ([videoForCell isUploading])
    {
        [uploadProgressIndicator setProgress:((float)[video getUploadPercentComplete]/100)];
        [videoThumbnailImage setImage:nil];
        [videoLengthLabel setText:nil];
        [loadingThumbnailIndicator setHidden:YES];
        [uploadProgressIndicator setHidden:NO];
        [loadingText setText:@"Uploading video..."];
        [timeSinceVideoPostLabel setText:@""];
        [viewCommentsButton setHidden:YES];
        [numberOfCommentsLabel setHidden:YES];
        [viewViewsButton setHidden:YES];
        [numberOfViewsLabel setHidden:YES];
    }
    else 
    {
        [loadingThumbnailIndicator setHidden:NO];
        [loadingText setText:@"Loading thumbnail..."];
        [uploadProgressIndicator setHidden:YES];
        [timeSinceVideoPostLabel setText:[NSDate getTimeSinceStringFromDate:[videoForCell getObjectCreatedDate]]];
        [viewCommentsButton setHidden:NO];
        [numberOfCommentsLabel setHidden:NO];
        [viewViewsButton setHidden:NO];
        [numberOfViewsLabel setHidden:NO];
        
        if ([video getThumbnail] == nil)
        {
            [video loadThumbnailInBackground];
            [videoThumbnailImage setImage:nil];
        }
        else 
        {
            [videoThumbnailImage setImage:[video getThumbnail]];
        }

        if ([video isNewVideo] == CCStatusUnknown)
        {
            [video isVideoNewWithBlockOrNil:^(int CCWatchedStatus, BOOL succeded, NSError *error) {
                if (succeded)
                {
                    if (CCWatchedStatus == CCStatusUnwatched)
                    {
                        [[self unwatchedVideoImageView] setHidden:NO];
                        [[self replyButton] setHidden:YES];
                    }
                    else 
                    {
                        [[self unwatchedVideoImageView] setHidden:YES];
                        [[self replyButton] setHidden:NO];
                    }
                }
            }];
        }
        else if ([video isNewVideo] == CCStatusUnwatched)
        {
            [[self unwatchedVideoImageView] setHidden:NO];
            [[self replyButton] setHidden:YES];
            
        }
        else if ([video isNewVideo] == CCStatusWatched)
        {
            [[self unwatchedVideoImageView] setHidden:YES];
            [[self replyButton] setHidden:NO];
        }
                
        [self setVideoLength];
    }
    
    [creatorProfilePicView setHidden:YES];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {        
        UIImage *usersProfilePic = [[video getTheOwner] getProfilePicture];        
        dispatch_async( dispatch_get_main_queue(), ^
        {
            [creatorProfilePicView setImage:usersProfilePic];
            [creatorProfilePicView setHidden:NO];
        });
    });        
    
    [creatorNameLabel setText:[[video getTheOwner] getName]];
    
    [self setNumberOfViews];
    
    [self setNumberOfComments];    
    
    [detailsView setFrame:CGRectMake(290, 0, VIDEO_DETAILS_PANE_WIDTH, 192)];    
    
    // We only want the device to draw the map when needed, due to it causing slow downs for each cell it needs to be drawn on.
    // Therefore we stop the map from being drawn if the cell is currently showing the video thumbnail.
    if (detailsView.center.x > 458.5)
    {
        [videoLocationMapView removeFromSuperview];
    }
    else 
    {
        [self drawMap];
    }            
}

- (void) setVideoLength
{
    if ([video getVideoDuration] > 2 && [video getVideoDuration] < 0)
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
    [viewViewsButton setHighlighted:NO];
    CCVideosViewsViewController *videosViewsView = [[parentNavigationViewController storyboard] instantiateViewControllerWithIdentifier:@"videosViewsView"];
    
    [videosViewsView setVideoForView:video];
    
    [[parentNavigationViewController navigationController] pushViewController:videosViewsView animated:YES];
}
- (IBAction)onViewCommentsButtonPress:(id)sender
{
    [viewCommentsButton setHighlighted:NO];
    CCVideosCommentsViewController *videosViewsView = [[parentNavigationViewController storyboard] instantiateViewControllerWithIdentifier:@"videosCommentsView"];
    
    [videosViewsView setVideoForView:video];
    
    [[parentNavigationViewController navigationController] pushViewController:videosViewsView animated:YES];
}

- (IBAction)onVideoThumbnailPressed:(id)sender
{
    if (![video isUploading])
        [self playVideo];
}

//Called when Play button is pressed in cell
- (void)playVideo
{  
    [[self activityIndicator] setHidden:NO];
    
    /*This code may look stupid, and maybe it is. Essentially we spawn a new thread and do nothing.
     The reason we do this is because the button press action call needs complete and return for the gui 
     to update. The GUI needs to update to display an activity indicator while the video loads.
     Dispatching a new thread was the only way I could think of doing it. If you have a better solution
     feel free to implement it.*/
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
       {        
           dispatch_async( dispatch_get_main_queue(), ^
              {
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
                  
                  [video addViewInBackground:[[[CCCoreManager sharedInstance] server] currentUser] withBlockOrNil:nil];
                  [[self activityIndicator] setHidden:YES];
                  
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
                  
                  [self.videoPlayer.moviePlayer setFullscreen:YES animated:YES];
                  [self.parentNavigationViewController presentMoviePlayerViewControllerAnimated:self.videoPlayer];
                  [[CCCoreManager sharedInstance] recordMetricEvent:CC_VIEWED_VIDEO withProperties:nil];
              });
       });  
}

- (void) handlePlaybackCompletion
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.videoPlayer.moviePlayer stop];    
    self.videoPlayer = nil;        
    
    [[self unwatchedVideoImageView] setHidden:YES];
    [[self replyButton] setHidden:NO];
    
    if (wasPlayingMedia)
    {
        [[MPMusicPlayerController iPodMusicPlayer] play];
        wasPlayingMedia = NO;
    }
}

- (void)playMovieFinished:(NSNotification*)theNotification
{   
    NSError *error = [[theNotification userInfo] objectForKey:@"error"];
    
    if (error)
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed Loading Video: %@", [error localizedDescription]];  
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Video Playback Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
        
        [alert show];
    }
    
    [self handlePlaybackCompletion];
    
    
}

- (void)MPMoviePlayerDidExitFullscreen:(NSNotification *)notification
{
    [self handlePlaybackCompletion];
}

- (IBAction)handleSwipe:(UIPanGestureRecognizer *)recognizer
{                    
    CGPoint translation = [recognizer translationInView:detailsView];
    detailsView.center = CGPointMake(detailsView.center.x + translation.x, 
                                         detailsView.center.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:detailsView];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) 
    {  
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Video's details view is at %f", detailsView.center.x];
        
        // Set up the animation
        CGAffineTransform moveTransform;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        // Find out where we need to move to
        if (detailsView.center.x > (290 + (VIDEO_DETAILS_PANE_WIDTH/2)))   // Left-most "pane"
        {
            moveTransform = CGAffineTransformMakeTranslation((290 + (VIDEO_DETAILS_PANE_WIDTH/2) - detailsView.center.x), 0);
            
            // Removes the map when it is no longer needed. 
            [videoLocationMapView removeFromSuperview];
        }
        else if (detailsView.center.x > (VIDEO_DETAILS_PANE_WIDTH/2))  // Second "pane"
        {            
            moveTransform = CGAffineTransformMakeTranslation((VIDEO_DETAILS_PANE_WIDTH/2) - detailsView.center.x, 0);
            
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [self drawMap];
                
            });
        }   
        else    // Last "pane"
        {            
            moveTransform = CGAffineTransformMakeTranslation(-290 + (VIDEO_DETAILS_PANE_WIDTH/2) - detailsView.center.x, 0);
        } 
        
        detailsView.transform = moveTransform;
        [UIView commitAnimations];
    }    
}


- (IBAction)onDetailsPanePressed:(id)sender
{
    // Set up the animation
    CGAffineTransform moveTransform;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    // Adjust the center
    if (detailsView.center.x == (VIDEO_DETAILS_PANE_WIDTH/2))
    {
        detailsView.center = CGPointMake(290 + (VIDEO_DETAILS_PANE_WIDTH/2), detailsView.center.y);
        moveTransform = CGAffineTransformMakeTranslation(290 + (VIDEO_DETAILS_PANE_WIDTH/2) - detailsView.center.x, 0);
    }
    else 
    {
        detailsView.center = CGPointMake((VIDEO_DETAILS_PANE_WIDTH/2), detailsView.center.y);
        moveTransform = CGAffineTransformMakeTranslation((VIDEO_DETAILS_PANE_WIDTH/2) - detailsView.center.x, 0);
    }    
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{                        
        [self drawMap];
        
    });
    
    detailsView.transform = moveTransform;
    [UIView commitAnimations];
    
}
- (IBAction)onLocationPanePressed:(id)sender
{
    // Set up the animation
    CGAffineTransform moveTransform;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    // Adjust the center
    if (detailsView.center.x == (VIDEO_DETAILS_PANE_WIDTH/2))
    {
        detailsView.center = CGPointMake(-290 + (VIDEO_DETAILS_PANE_WIDTH/2), detailsView.center.y);
        moveTransform = CGAffineTransformMakeTranslation(-290 + (VIDEO_DETAILS_PANE_WIDTH/2) - detailsView.center.x, 0);        
    }
    else 
    {
        detailsView.center = CGPointMake((VIDEO_DETAILS_PANE_WIDTH/2), detailsView.center.y);
        moveTransform = CGAffineTransformMakeTranslation((VIDEO_DETAILS_PANE_WIDTH/2) - detailsView.center.x, 0);
    }            
    
    detailsView.transform = moveTransform;
    [UIView commitAnimations];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer 
{
    UIView *cell = [panGestureRecognizer view];
    if (![panGestureRecognizer respondsToSelector:@selector(translationInView:)])
        return YES;
    
    CGPoint translation = [panGestureRecognizer translationInView:[cell superview]];
    
    // Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y))
    {
        return YES;
    }
    
    return NO;
}

- (IBAction)onReplyButtonPress:(id)sender
{
    if ([[[CCCoreManager sharedInstance] server] uploaderIsBusy])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait..." 
                                                        message:@"A video is currently uploading... Please wait for it to finish before recording another video!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    cameraUI = nil;
    cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
    {
        mediaSource = ccCamera;

        [cameraUI setCCPropertiesForMediaSource:mediaSource];
        
    }
    else 
    {
        mediaSource = ccVideoLibrary;
        
        [cameraUI setCCPropertiesForMediaSource:mediaSource];

    }
    
    [cameraUI setDelegate:self];
    
    [[parentNavigationViewController navigationController] presentModalViewController: cameraUI animated: YES]; 
}


- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info 
{
    // Handle a movie capture
    videoPath = [[info objectForKey:
                            UIImagePickerControllerMediaURL] path];  
    
    [[parentNavigationViewController navigationController] dismissModalViewControllerAnimated: NO];
    
    [self saveVideoToCrew];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[parentNavigationViewController navigationController] dismissViewControllerAnimated:YES completion:nil];
}




- (void)saveVideoToCrew
{
    crewsForVideo = [[NSMutableArray alloc] initWithObjects:[parentNavigationViewController crewForView], nil];
    
    [[[CCCoreManager sharedInstance] server] addNewVideoWithName:@"" currentVideoLocation:videoPath addToCrews:crewsForVideo delegate:self mediaSource:mediaSource];

}


// CCVideoUpdatesDelegate Methods

- (void) finishedUploadingVideoFilesWithSucces:(BOOL)successful error:(NSError *)error andVideoFilesReference:(id<CCVideoFiles>)videoFiles
{
    if(!successful)
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error uploading video: %@", [error description]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"UPLOAD_ERROR_ALERT_TITLE", @"Localizable", nil)
                                                        message:NSLocalizedStringFromTable(@"UPLOAD_ERROR_ALERT_TEXT", @"Localizable", nil) 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Retry", nil];
        alert.tag = standardTag;
        [alert show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case standardTag:
            if (buttonIndex == 1)
            {
                // Try again
                
                [self saveVideoToCrew];
            }
            else 
            {
                // Save the video
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (videoPath) && mediaSource != ccVideoLibrary) 
                {
                    UISaveVideoAtPathToSavedPhotosAlbum (videoPath, nil, nil, nil);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"VIDEO_SAVED_LOCALLY", @"Localizable", nil)
                                                                    message:nil
                                                                   delegate:nil 
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                    alert.tag = standardTag;
                    [alert show];
                }
            }
            break;
            
        case askToSaveTag:
            if (buttonIndex == 1)
            {
                // Save the video
                UISaveVideoAtPathToSavedPhotosAlbum (videoPath, nil, nil, nil);
            }
            break;
        default:
            break;
    }
    
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Only allow details panning, or table scrolling
    if ([otherGestureRecognizer class] == [UITapGestureRecognizer class])
        return YES;
    
    return NO;
}

- (void) finishedLoadingThumbnailWithSucess:(BOOL) successful andError:(NSError *) error
{
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
        [loadingThumbnailIndicator setHidden:NO];
        [video loadThumbnailInBackground];
        
        [timeSinceVideoPostLabel setText:[NSDate getTimeSinceStringFromDate:[video getObjectCreatedDate]]];
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

- (void) drawMap
{
    [mapLayer addSubview:videoLocationMapView];
    [mapLayer bringSubviewToFront:mapGlassOverlay];
    
    CLLocationDistance distanceInMeters = [[video getVideoLocation] distanceFromLocation:[[[CCCoreManager sharedInstance]locationManager] getCurrentLocation]];
    
    // If we're really close, we still want some context, not just * 2, this also acts as a null check, of sorts, as the above call to get the distance should return -1 if location services is turned off.
    if (distanceInMeters < 10)
        distanceInMeters = 50;
    
    MKPointAnnotation *pinAnnotation = [[MKPointAnnotation alloc] init];
    pinAnnotation.coordinate = [video getVideoLocation].coordinate;
    [videoLocationMapView setRegion:MKCoordinateRegionMakeWithDistance([video getVideoLocation].coordinate, distanceInMeters * 2, distanceInMeters * 2)]; 
    
    // Remove any old annotactions from the last time this cell was used
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
    for (id annotation in videoLocationMapView.annotations)
        [toRemove addObject:annotation];
    [videoLocationMapView removeAnnotations:toRemove];    
    [videoLocationMapView addAnnotation:pinAnnotation];  
}

@end