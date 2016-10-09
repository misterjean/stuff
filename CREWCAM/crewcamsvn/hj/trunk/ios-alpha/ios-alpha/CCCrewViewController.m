//
//  CCVideoViewController.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewViewController.h"
#import "CCVideoTableViewCell.h"

@interface CCCrewViewController ()

@end

@implementation CCCrewViewController
@synthesize videoTableView;
@synthesize crewForView;
@synthesize sortedVideoList;
@synthesize loadingLabel;
@synthesize securitySettingImage;
@synthesize replyButton;
@synthesize viewMembersButton;
@synthesize inviteButton;
@synthesize isLoadingForCommentNotification;


- (void) awakeFromNib
{
    [super awakeFromNib];

    [self setIsLoadingForCommentNotification:NO];
}

- (IBAction) onBackButtonPressed:(id)sender 
{
    if (self == [[[self navigationController] viewControllers] objectAtIndex:0])
    {
        [[self navigationController] dismissModalViewControllerAnimated:YES];
    }
    else 
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void) cleanUpResources
{
    [crewForView removeCrewUpdateListener:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([crewForView oldVideosLoaded])
    {
        NSDictionary *kissMetricDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInt:[crewForView numberOfOldVideos]],  CC_NUMBER_OF_OLD_VIDEOS_LOADED,
                                              nil];
        
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_LOADED_OLD_VIDEOS withProperties:kissMetricDictionary];
        
        [crewForView setOldVideosLoaded:NO];
        [crewForView setNumberOfOldVideos:0];
    }
    
    if (![crewForView isUploadInProgress])
        [[crewForView ccVideos] removeAllObjects];
    
    [videoTableView reloadData];
}

- (void) didReceiveMemoryWarning
{
    [self cleanUpResources];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] addCrewcamTitleToViewController:[crewForView getName]];
    
    [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)];
    
    if ([crewForView getSecuritySetting] == CCPublic)
    {
        [securitySettingImage setImage:[UIImage imageNamed:@"icon_Public.png"]];
    }
    else
    {
        [securitySettingImage setImage:[UIImage imageNamed:@"icon_Private.png"]];
    }
    
    [videoTableView setDataSource:self];
    [videoTableView setDelegate:self];
    [videoTableView setTableDelegate:self];  
    
    if (!isLoadingForCommentNotification)
        [crewForView addCrewUpdateListener:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanUpResources) name:@"cleanupOldCrewViewControllers" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLowMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [loadingLabel setText:@"LOADING..."];
    
    if (!isLoadingForCommentNotification)
        [self reloadVideosOnBackgroundThread];   
    
    if ([[crewForView ccVideos] count] > 0)
    {
        [loadingLabel setHidden:YES];
    }
    
    [[self navigationItem] setRightBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Leave" target:self action:@selector(onLeaveButtonPressed:)]];
    
    [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)];
    
    if ([crewForView getCrewtype] == CCDeveloper && ![[[[CCCoreManager sharedInstance] server] currentUser] isUserDeveloper])
    {
        [[self replyButton] setHidden:YES];
        [[self viewMembersButton] setHidden:YES];
        [[self inviteButton] setHidden:YES];
        [[self securitySettingImage] setHidden:YES];
    }
    
    if ( [crewForView getCrewtype] == CCFBWork || [crewForView getCrewtype] == CCFBSchool || [crewForView getCrewtype] == CCFBLocation)
    {
        [[self securitySettingImage] setHidden:YES];
    }
    
    [videoTableView reloadData];
}

- (void) handleLowMemoryWarning
{
    for(id<CCVideo> video in [crewForView ccVideos])
    {
        [video clearThumbnail];
    }
}

-(void) initWithCrew:(id<CCCrew>)crew
{
    [self setCrewForView:crew];
    [self setTitle:[crew getName]];
}

- (void) reloadVideosOnBackgroundThread
{
    [crewForView reloadVideosInBackgroundWithBlockOrNil:nil];
}

- (void) loadOldVideosOnBackgroundThread
{
    [crewForView loadVideosInBackgroundWithBlockOrNil:nil startingAtIndex:[videoTableView numberOfRowsInSection:0] forVideoCount:10];
}

- (void) startingToLoadVideos
{
    if ([videoTableView numberOfRowsInSection:0] == 0)
    {
        [loadingLabel setText:@"LOADING..."];
    }
}

- (void) finishedLoadingVideosWithSuccess:(BOOL)successful andError:(NSError *)error
{
    if ([[crewForView ccVideos] count] == 0)
    {
        [loadingLabel setText:@"NO VIDEOS."];
    }
}

- (void) addedNewVideosAtIndexes:(NSArray *) newVideoIndexes andRemovedVideosAtIndexes:(NSArray *) deletedVideoIndexes
{
    [videoTableView removePullToRefreshFooter];
    
    if ([[crewForView ccVideos] count] < 1)
    {
        [loadingLabel setText:@"NO VIDEOS."];
        [loadingLabel setHidden:NO];
    }
    else 
    {
        [loadingLabel setHidden:YES];
    }
    
    [videoTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [videoTableView setScrollEnabled:YES];
    
    if ([videoTableView numberOfRowsInSection:0] == 0)
    {
        [videoTableView reloadData];
    }
    else 
    {
        BOOL uploadingVideos = NO;
        for (NSIndexPath *indexPath in deletedVideoIndexes)
        {
            if ([[crewForView ccVideos] count] &&
                [indexPath row] < [[crewForView ccVideos] count] &&
                [[[crewForView ccVideos] objectAtIndex:[indexPath row]] isUploading])
                {
                    uploadingVideos = YES; 
                    break;
                }
        }
         
        if (uploadingVideos)
                [videoTableView reloadData];
        else 
        {
            [videoTableView beginUpdates];
            
            [videoTableView deleteRowsAtIndexPaths:deletedVideoIndexes withRowAnimation:UITableViewRowAnimationRight];        
            [videoTableView insertRowsAtIndexPaths:newVideoIndexes withRowAnimation:UITableViewRowAnimationLeft];
            
            [videoTableView endUpdates];  
        }
    }
    
    if ([videoTableView numberOfRowsInSection:0] <= 10)
        [crewForView setOldVideosLoaded:NO];
    
    [crewForView getNumberOfVideosWithBlock:^(int numberOfVideos, BOOL succeded, NSError *error) {
        if ([videoTableView numberOfRowsInSection:0] == 0
            && numberOfVideos > 0
            && ![crewForView isUploadInProgress])
        {
            [self reloadVideosOnBackgroundThread];
        }
    } andForced:NO];

}

- (void) addedOldVideosAtIndexes:(NSArray *) oldVideoIndexes
{
    [videoTableView stopLoading];
    
    [crewForView setOldVideosLoaded:YES];
    
    if ([oldVideoIndexes count] > 0)
    {
        [videoTableView reloadData];
        
        [videoTableView performSelector:@selector(pushViewDown) withObject:nil afterDelay:0.5];
    }
}

- (void) viewDidUnload
{    
    [crewForView removeCrewUpdateListener:self];    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setVideoTableView:nil];
    [self setCrewForView:nil];
    [self setLoadingLabel:nil];
    [self setCrewForView:nil];
    [self setSortedVideoList:nil];
    [self setSecuritySettingImage:nil];
    [self setReplyButton:nil];
    [self setViewMembersButton:nil];
    [self setInviteButton:nil];
    cameraUI = nil;
    videoPath = nil;
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[crewForView ccVideos] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath row] >= 5)
    {
        [[[crewForView ccVideos] objectAtIndex:([indexPath row] - 5)] clearThumbnail];
        if (([[crewForView ccVideos] count] - 1) > ([indexPath row] + 5))
        {
            [[[crewForView ccVideos] objectAtIndex:([indexPath row] + 5)] clearThumbnail];
        }
    }
    static NSString *CellIdentifier = @"videoTableCell";
    CCVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id<CCVideo> videoForCell = [[crewForView ccVideos] objectAtIndex:[indexPath row]];
    
    if (cell == nil)
    {
        cell = [[CCVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell initializeWithVideo:videoForCell andNavigationController:self];
    [crewForView getNumberOfVideosWithBlock:^(int numberOfVideos, BOOL succeded, NSError *error) {
        if (indexPath.row + 1 == ([videoTableView numberOfRowsInSection:0])
            && numberOfVideos > ([videoTableView numberOfRowsInSection:0])
            && ![crewForView isUploadInProgress]
            && !isLoadingForCommentNotification)
        {
            [videoTableView addPullToRefreshFooterToSection:0 withOffset:0];
        }
    } andForced:NO];
    
    return cell;
}

- (void) refreshTableOnPullUp
{
    [self loadOldVideosOnBackgroundThread];
    [videoTableView setDelegate:nil];
}

- (IBAction) onReplyButtonPress:(id)sender
{
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_VIDEO_REPLY withProperties:nil];
    
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
    
    [[self navigationController] presentModalViewController: cameraUI animated: YES];
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    // Handle a movie capture
    videoPath = [[info objectForKey:
                  UIImagePickerControllerMediaURL] path];
    
    [[self navigationController] dismissModalViewControllerAnimated: NO];
    
    [self saveVideoToCrew];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}


- (void) saveVideoToCrew
{
    
    [[[CCCoreManager sharedInstance] server] addNewVideoWithName:@"" currentVideoLocation:videoPath addToCrews:[[NSArray alloc] initWithObjects:crewForView, nil] addToFacebook:NO mediaSource:mediaSource];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"addMemberSegue"])
    {
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_INVITE withProperties:nil];
        CCInviteAndAddCrewViewController *vc = [segue destinationViewController];
        [vc setStoredNavigationController:[self navigationController]];
        [vc setPassedCrew:crewForView];
    }
    else if ([[segue identifier] isEqualToString:@"membersListPush"])
    {
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_VIEW_MEMBERS withProperties:nil];
        CCCrewMembersViewController *crewMembersView = [segue destinationViewController];
        [crewMembersView setCrewForView:crewForView];
    }
}
@end
