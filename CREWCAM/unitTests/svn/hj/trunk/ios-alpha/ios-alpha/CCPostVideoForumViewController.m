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
    crewsForVideo = nil;
    
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
    if ([checkedIndexPaths count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"CREW_SELECT_TITLE", @"Localizable", nil) 
                                                        message:NSLocalizedStringFromTable(@"CREW_SELECT_TEXT", @"Localizable", nil) 
                                                       delegate:nil 
                                              cancelButtonTitle:@"My bad"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }        
    else
    {
        [crewsTableViewOutlet setHidden:YES];
        
        [shareButton setEnabled:NO];
        
        [uploadingIndicator setHidden:NO];
        
        [shareButton setHidden:YES];
        [cancelButton setHidden:YES];
        [hideButton setHidden:NO];
        
        [self saveVideoToSelectedCrews];
    }
}

- (IBAction)onHidePressWithSender:(id)sender 
{    
    [uploadingIndicator setHidden:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCancelPressWithSender:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    
    if (mediaSource != ccVideoLibrary && UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (videoPath))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedStringFromTable(@"ASK_TO_SAVE_LOCALLY", @"Localizable", nil) 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Save", nil];
        alert.tag = askToSaveTag;
        [alert show];
    }
}

// Required UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"postToCrewsCell";
    CCCrewForSharingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CCCrewForSharingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setCrewForCell:[[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] objectAtIndex:[indexPath row]] withViewController:self
     ];
    
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
    
    [[[CCCoreManager sharedInstance] server] addNewVideoWithName:@"" currentVideoLocation:videoPath addToCrews:crewsForVideo delegate:self mediaSource:[self mediaSource]];
}


// CCVideoUpdatesDelegate Methods
-(void) videoFilesUploadProgressIsAtPercent:(int)percent
{
    //This function gets called for each percent of the video upload.
    [uploadProgressIndicator setProgress:(float)percent/100];
}

- (void) finishedUploadingVideoFilesWithSucces:(BOOL)successful error:(NSError *)error andVideoFilesReference:(id<CCVideoFiles>)videoFiles
{
    if(!successful)
    {
        [uploadingIndicator setHidden:YES];
        [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error uploading video: %@", [error description]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"UPLOAD_ERROR_ALERT_TITLE", @"Localizable", nil)
                                                        message:NSLocalizedStringFromTable(@"UPLOAD_ERROR_ALERT_TEXT", @"Localizable", nil) 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Retry", nil];
        alert.tag = standardTag;
        [alert show];
    }
    else 
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case standardTag:
            if (buttonIndex == 1)
            {
                // Try again
                [uploadingIndicator setHidden:NO];
                
                [self saveVideoToSelectedCrews];
            }
            else 
            {
                // Save the video
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (videoPath) && [self mediaSource] != ccVideoLibrary) 
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
                [self dismissViewControllerAnimated:YES completion:nil];
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

@end
