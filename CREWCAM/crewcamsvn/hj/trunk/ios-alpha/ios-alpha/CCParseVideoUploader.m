//
//  CCParseVideoUploader.m
//  Crewcam
//
//  Created by Ryan Brink on 12-07-19.
//
//

#import "CCParseVideoUploader.h"

@implementation CCParseVideoUploader
@synthesize videoFiles;
@synthesize crewsForVideo;
@synthesize videoObjectsForCrews;
@synthesize  videoName;
@synthesize mediaSource;
@synthesize postToFacebook;

- (id) initWithVideoName:(NSString *)name andCurrentVideoPath:(NSString *)currentVideoLocation forCrews:(NSArray *)crews andMediaSource:(ccMediaSources)videoMediaSource andAddToFacebook:(BOOL)addToFacebook
{
    self = [super init];
    
    if (self)
    {
        isFirstAttempt = YES;
        
        videoFiles = [CCParseVideoFiles createNewVideoFilesWithName:name mediaSource:videoMediaSource
                                                                               andVideoPath:currentVideoLocation];        
        
        [self setCrewsForVideo:[[NSMutableArray alloc] initWithArray:crews]];
        
        [self setVideoName:name];
        
        [self setMediaSource:mediaSource];
        
        [self setPostToFacebook:addToFacebook];
        
        [self setVideoObjectsForCrews:[[NSMutableArray alloc] initWithCapacity:[crews count]]];
        
        // Add videos to the crews locally
        for (id<CCCrew> crew in crewsForVideo)
        {
            id<CCVideo> newVideo = [CCParseVideo createNewVideoObjectWithName:[self videoName]
                                                                      creator:[[[CCCoreManager sharedInstance] server] currentUser]
                                                                    videoPath:[videoFiles localVideoLocation]
                                                                  mediaSource:[self mediaSource]
                                                                   videoFiles:[self videoFiles]
                                                             andVideoUploader:self];
            
            [videoObjectsForCrews addObject:newVideo];
        }
    }
    
    return self;
}

- (void) showUploadFailedAlert
{
    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"UPLOAD_ERROR_ALERT_TITLE", @"Localizable", nil)
                                                                  message:NSLocalizedStringFromTable(@"UPLOAD_ERROR_ALERT_TEXT", @"Localizable", nil)
                                                            withTextField:NO
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:@"Retry", nil];
    
    [alert show];
}

- (void) showUploadFailedAlertNoInternetConnection
{
    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"NETWORK_UPLOAD_ERROR_ALERT_TITLE", @"Localizable", nil)
                                                                  message:NSLocalizedStringFromTable(@"NETWORK_UPLOAD_ERROR_ALERT_TEXT", @"Localizable", nil)
                                                            withTextField:NO
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:@"Retry", nil];
    
    [alert show];
}

- (void) startUploadInBackgroundWithBlock:(CCBooleanResultBlock) block
{
    videoUploadCompletionBlock = [block copy];
    
    if (!isFirstAttempt)
    {
        [[[CCCoreManager sharedInstance] server] retryVideoUploadWithUploader:self];
    }
    else
    {
        isFirstAttempt = NO;
    }
    
    [[CCCoreManager sharedInstance]checkNetworkConnectivity:^(BOOL succeeded, NSError *error)
     {
         if (!succeeded)
         {
             [self showUploadFailedAlertNoInternetConnection];
             
             NSError *crewcamError = [NSError errorWithDomain:@"CCParseServer" code:ccNoNetworkConnection userInfo:nil];             
             
             [self handleVideoUploadResultWithSuccess:NO andError:crewcamError];
             return;
         }
         else
         {
             // Start uploading things:
             [videoFiles uploadAndSaveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {                 
                 if (!succeeded)
                 {
                     [self showUploadFailedAlert];
                     
                     // Notify of failure
                     for (id<CCVideo> video in videoObjectsForCrews)
                     {
                         [video finishedUploadingVideoFilesWithSucces:succeeded error:error forUploader:self];
                     }
                     
                     [self handleVideoUploadResultWithSuccess:succeeded andError:error];
                     return;
                 }
                 else
                 {
                     // Save and pull all the video objects on a background thread
                     dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                         for (id<CCVideo> video in videoObjectsForCrews)
                         {
#warning We are ignore the failure case here...
                             [video completeNewVideoUpload];
                         }
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             // Notify all the video listeners of success
                             for (id<CCVideo> video in videoObjectsForCrews)
                             {
                                 [video finishedUploadingVideoFilesWithSucces:succeeded error:error forUploader:self];
                             }
                             
                             // Handle success
                             [self handleVideoUploadResultWithSuccess:succeeded andError:error];
                         });
                     });
                     
                     
                 }
             }];
             
             // Add all the video objects "locally"
             for (int crewIndex = 0; crewIndex < [crewsForVideo count]; crewIndex++)
             {
                 [[crewsForVideo objectAtIndex:crewIndex] addVideoLocally:[videoObjectsForCrews objectAtIndex:crewIndex]];
             }
         }
     }];
}
     
- (void) handleVideoUploadResultWithSuccess:(BOOL) succeeded andError:(NSError *) error
{
    if (succeeded)
    {
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[videoFiles localVideoLocation]] options:nil];
        Float64 durationSeconds = CMTimeGetSeconds([videoAsset duration]);
        
        NSDictionary *kissMetricDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInteger:[crewsForVideo count]],   CC_NUMBER_OF_CREWS_POSTED_TO,
                                              [NSNumber numberWithFloat:durationSeconds],           CC_LENGTH_OF_VIDEO_KEY,
                                              nil];
        
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_SUCCESSFULLY_ADDED_VIDEO withProperties:kissMetricDictionary];
        
        // Post to Facebook if needed
        if ([self postToFacebook])
        {
            id<CCVideo> dummyVideo = [CCParseVideo createNewVideoObjectWithName:[self videoName]
                                                                        creator:[[[CCCoreManager sharedInstance] server] currentUser]
                                                                      videoPath:[videoFiles localVideoLocation]
                                                                    mediaSource:[self mediaSource]
                                                                     videoFiles:[self videoFiles]
                                                               andVideoUploader:self];
            
            [self postVideoInfoToFacebookWithVideoFiles:videoFiles andVideoObject:dummyVideo];
        }
        
        // Notify people of the video!
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSMutableArray *usersThatHaveBeenNotified = [[NSMutableArray alloc] init];
            for (int crewIndex = 0; crewIndex < [crewsForVideo count]; crewIndex++)
            {
                [self sendNotificationsInBackgroundForVideo:[videoObjectsForCrews objectAtIndex:crewIndex] toCrew:[crewsForVideo objectAtIndex:crewIndex] forUsersNotInlist:usersThatHaveBeenNotified];
            }
        });
    }
    else
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error uploading video: %@", [error localizedDescription]];
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ADDING_VIDEO withProperties:nil];
    }
    
    if (videoUploadCompletionBlock)
        videoUploadCompletionBlock(succeeded, error);
}

- (void) sendNotificationsInBackgroundForVideo:(id<CCVideo>) video toCrew:(id<CCCrew>) crew forUsersNotInlist:(NSMutableArray *)usersThatHaveBeenNotified
{
    // Blocking load
    [crew loadMembers];
    
    NSString *newVideoMessage = [[NSString alloc] initWithFormat:@"%@ added a new video to the crew \"%@\"!",
                                 [[[[CCCoreManager sharedInstance] server] currentUser ] getName], [crew getName]];
    
    NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:newVideoMessage, @"alert",
                                 [NSNumber numberWithInt:1], @"badge",
                                 [[[[CCCoreManager sharedInstance] server] currentUser ] getObjectID], @"src_User",
                                 [NSNumber numberWithInt:ccVideoPushNotification], @"type",
                                 [crew getObjectID], @"ID",
                                 nil];
    
    NSDictionary *messageDataForSecondaryCrew = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [[[[CCCoreManager sharedInstance] server] currentUser ] getObjectID], @"src_User",
                                                 [NSNumber numberWithInt:ccVideoPushNotification], @"type",
                                                 [crew getObjectID], @"ID",
                                                 nil];
    
    for (id<CCUser> user in [crew ccUsersThatAreMembers])
    {
        // Is the user this user?
        if ([[user getObjectID] isEqualToString:[[[[CCCoreManager sharedInstance] server] currentUser] getObjectID]])
            continue;
        
        // Has the user been notified by another crew?
        if ([CCParseObject isObjectInArray:user arrayOfCCServerStoredObjects:usersThatHaveBeenNotified])
        {
            [user sendNotificationWithData:messageDataForSecondaryCrew];
            continue;
        }
        
        [usersThatHaveBeenNotified addObject:user];
        
        // Send the "Crewcam" notification
        [CCParseNotification createNewNotificationInBackgroundWithType:ccNewVideoNotification
                                                         andTargetUser:user andSourceUser:[video getTheOwner]
                                                       andTargetObject:video
                                                    andTargetCrewOrNil:crew
                                                            andMessage:newVideoMessage];
        
        // Send the push notification
        [user sendNotificationWithData:messageData];
    }
}

- (void) cancelUpload
{
    // If the video was shot with the camera, save it
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum ([[self videoFiles] localVideoLocation]) && [self mediaSource] != ccVideoLibrary)
    {
        UISaveVideoAtPathToSavedPhotosAlbum ([[self videoFiles] localVideoLocation], nil, nil, nil);
    }
    
    [videoFiles cancelUpload];
    
    // Notify all the video objects of the status:
    for (id<CCVideo> video in videoObjectsForCrews)
    {
        [video finishedUploadingVideoFilesWithSucces:NO error:nil forUploader:self];
    }
    
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"User canceled video upload"];
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_CANCELED_ADDING_VIDEO withProperties:nil];
    
    if (videoUploadCompletionBlock)
        videoUploadCompletionBlock(NO, nil);
}

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self startUploadInBackgroundWithBlock:videoUploadCompletionBlock];
    }
    else
    {
        // Save the video
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum ([[self videoFiles] localVideoLocation]) && [self mediaSource] != ccVideoLibrary)
        {
            UISaveVideoAtPathToSavedPhotosAlbum ([[self videoFiles] localVideoLocation], nil, nil, nil);
            CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"VIDEO_SAVED_LOCALLY", @"Localizable", nil)
                                                                          message:nil
                                                                    withTextField:NO
                                                                         delegate:nil
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles:nil];
            
            [alert show];
        }
    }
}

- (void)postVideoInfoToFacebookWithVideoFiles:(id<CCVideoFiles>) newVideoFiles andVideoObject:(id<CCVideo>) savedVideo
{
    NSString *videoLinkTemplate = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_EMBEDDED_VIDEO_URL_KEY withDefault:NSLocalizedStringFromTable(@"FACEBOOK_VIDEO_LINK", @"Localizable", nil)];
    
    NSString *crewCamLink = [[[CCCoreManager sharedInstance] stringManager] formatStringForTemplate:videoLinkTemplate withVideoFiles:newVideoFiles videoObject:savedVideo user:[[[CCCoreManager sharedInstance] server] currentUser]];
    
    
    NSString *imageLinkTemplate = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_EMBEDDED_VIDEO_IMAGE_URL_KEY withDefault:NSLocalizedStringFromTable(@"FACEBOOK_IMAGE_LINK", @"Localizable", nil)];
    
    NSString * crewCamImageLink = [[[CCCoreManager sharedInstance] stringManager] formatStringForTemplate:imageLinkTemplate withVideoFiles:newVideoFiles videoObject:savedVideo user:[[[CCCoreManager sharedInstance] server] currentUser]];
    
    
    NSString *messageTemplate = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_EMBEDDED_VIDEO_MESSAGE_KEY withDefault:NSLocalizedStringFromTable(@"FACEBOOK_VIDEO_MESSAGE", @"Localizable", nil)];
    
    NSString *crewCamMessage = [[[CCCoreManager sharedInstance] stringManager] formatStringForTemplate:messageTemplate withVideoFiles:newVideoFiles videoObject:savedVideo user:[[[CCCoreManager sharedInstance] server] currentUser]];
    
    
    NSString *descriptionTemplate = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_EMBEDDED_VIDEO_DESCRIPTION_KEY withDefault:NSLocalizedStringFromTable(@"FACEBOOK_VIDEO_DESCRIPTION", @"Localizable", nil)];
    
    NSString *crewCamDescription = [[[CCCoreManager sharedInstance] stringManager] formatStringForTemplate:descriptionTemplate withVideoFiles:newVideoFiles videoObject:savedVideo user:[[[CCCoreManager sharedInstance] server] currentUser]];
    
    
    NSMutableDictionary* params = [NSMutableDictionary
                                   dictionaryWithObjectsAndKeys:
                                   CREWCAM_FACEBOOK_ID_STRING, @"app_id",
                                   crewCamLink, @"link",
                                   crewCamImageLink, @"picture",
                                   crewCamDescription, @"description",
                                   crewCamMessage,  @"message",
                                   nil];
    
#warning look at this and see if move to success path
    [[newVideoFiles getServerData] setObject:[NSNumber numberWithBool:TRUE] forKey:@"linkedToFacebook"];
    
    [[newVideoFiles getServerData] saveEventually];
    
    [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"me/feed"]
                                           andParams:params
                                       andHttpMethod:@"POST"
                                         andDelegate:self];
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result
{
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    
    if ([requestType isEqualToString:@"me/feed"])
    {
        
        if ([result isKindOfClass:[NSArray class]]) {
            result = [(NSArray *)result objectAtIndex:0];
        }
        
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Result of Video API call: %@", result];
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_SUCCESSFULLY_ADDED_VIDEO_TO_FACEBOOK withProperties:nil];
    }
}


- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error
{
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    
    if ([requestType isEqualToString:@"me/feed"])
    {
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed with error: %@", [error localizedDescription]];
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_FAILED_ADDING_VIDEO_TO_FACEBOOK withProperties:nil];
    }
}

@end
