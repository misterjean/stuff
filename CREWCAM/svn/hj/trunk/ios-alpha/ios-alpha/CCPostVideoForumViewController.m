//
//  CCPostVideoForumViewController.m
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCPostVideoForumViewController.h"

@interface CCPostVideoForumViewController ()

@end

@implementation CCPostVideoForumViewController
@synthesize crewsTableViewOutlet;
@synthesize videoPath;
@synthesize uploadingIndicator;
@synthesize shareButton;
@synthesize uploadProgressIndicator;
@synthesize checkedIndexPaths;
@synthesize hideButton;
@synthesize cancelButton;
@synthesize mediaSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    checkedIndexPaths = [[NSMutableSet alloc] init];
}

- (void)viewDidUnload
{
    [self setCrewsTableViewOutlet:nil];
    [self setVideoPath:nil];
    [self setUploadingIndicator:nil];
    [self setShareButton:nil];
    [self setUploadProgressIndicator:nil];
    [self setCheckedIndexPaths:nil];
    [self setHideButton:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onSubmitPressWithSender:(id)sender 
{    
    Boolean isACrewSelected = NO;
    
    NSArray *usersCrews = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews];
    
    for(int currentCrew = 0; currentCrew < [usersCrews count]; currentCrew++)
    {
        UITableViewCell *cellForCrew = [crewsTableViewOutlet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentCrew inSection:0]];
        
        if ([cellForCrew accessoryType] == UITableViewCellAccessoryCheckmark)
        {              
            isACrewSelected = YES;
            break;
        }            
    }
    if (!isACrewSelected)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"That's useless..." 
                                                        message:@"You have to select a crew!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"My bad"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }        
    [crewsTableViewOutlet setHidden:YES];
    
    [shareButton setEnabled:NO];
    
    [uploadingIndicator setHidden:NO];
    
    [shareButton setHidden:YES];
    [cancelButton setHidden:YES];
    [hideButton setHidden:NO];
    
    [self saveVideoToSelectedCrews];
}

- (IBAction)onHidePressWithSender:(id)sender 
{    
    [uploadingIndicator setHidden:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCancelPressWithSender:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

// Required UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"postToCrewsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    [label setText:[[[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] objectAtIndex:[indexPath row]] getName]]; 
    
    if([[self checkedIndexPaths] containsObject:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Add the checmark indicator for the cell
    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([[self checkedIndexPaths] containsObject:indexPath])
    {
        [[self checkedIndexPaths] removeObject:indexPath];
        thisCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        [[self checkedIndexPaths] addObject:indexPath];
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)saveVideoToSelectedCrews
{
    NSArray *usersCrews = [[[[CCCoreManager sharedInstance] server] currentUser] ccCrews];
    crewsForVideo = [[NSMutableArray alloc] init];
    
    for(int currentCrew = 0; currentCrew < [usersCrews count]; currentCrew++)
    {
        NSIndexPath *indexPathForCrew = [NSIndexPath indexPathForRow:currentCrew inSection:0];
        
        if ([[self checkedIndexPaths] containsObject:indexPathForCrew])
        {              
            [crewsForVideo addObject:[usersCrews objectAtIndex:currentCrew]];
        }            
    }
    
    [uploadProgressIndicator setHidden:NO];
    
    [[CCCoreManager sharedInstance]checkNetworkConnectivity:^(BOOL succeeded, NSError *error){
        if (succeeded)
        {
            [[[CCCoreManager sharedInstance] server] addNewVideoWithName:@"" currentVideoLocation:videoPath addToCrews:crewsForVideo delegate:self mediaSource:[self mediaSource]];
        }
        else
        {
            [uploadingIndicator setHidden:YES];
            
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (videoPath)) {
                UISaveVideoAtPathToSavedPhotosAlbum (videoPath, nil, nil, nil);
            }
            
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"No active network connection: %@", [error description]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh...No active network connection" 
                                                            message:@"Video will be saved locally." 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}


// CCVideoUpdatesDelegate Methods
-(void) videoUploadProgressIsAtPercent:(int)percent
{
    //This function gets called for each percent of the video upload.
    [uploadProgressIndicator setProgress:(float)percent/100];
}

- (void) finishedUploadingVideoWithSuccess:(BOOL) successful error:(NSError *) error andVideoReference:(id<CCVideo>)video
{
    if(!successful)
    {
        [uploadingIndicator setHidden:YES];
        videoToRetryUploading = video;
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error uploading video: %@", [error description]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh..." 
                                                        message:@"Error uploading the video.  Video will be saved locally." 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel Upload"
                                              otherButtonTitles:@"Try again", nil];
        [alert show];
    }
    else 
    {
        videoToRetryUploading = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        // Try again
        [uploadingIndicator setHidden:NO];
        
        [[[CCCoreManager sharedInstance] server] retryVideoUpload:videoToRetryUploading forCrews:crewsForVideo];
    }
    else 
    {
        // Cancel
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (videoPath) && [videoToRetryUploading videoMediaSource] != ccVideoLibrary) 
        {
            UISaveVideoAtPathToSavedPhotosAlbum (videoPath, nil, nil, nil);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
