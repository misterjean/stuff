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
@synthesize videoTitleField;
@synthesize videoPath;
@synthesize uploadingIndicator;
@synthesize shareButton;
@synthesize uploadProgressIndicator;
@synthesize checkedIndexPaths;

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
    [self setVideoTitleField:nil];
    [self setVideoPath:nil];
    [self setUploadingIndicator:nil];
    [self setShareButton:nil];
    [self setUploadProgressIndicator:nil];
    [self setCheckedIndexPaths:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onSubmitPressWithSender:(id)sender 
{    
    Boolean isACrewSelected = NO;
    
    if ([[videoTitleField text] isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops..." 
                                                    message:@"You forgot to give your video a name!" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"My bad"
                                          otherButtonTitles:nil];
        [alert show];
    
        return;
    }
    
    NSArray *usersCrews = [[[[CCCoreManager sharedInstance] server] currentUser] crews];
    
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
    
    [shareButton setEnabled:NO];
    
    [uploadingIndicator setHidden:NO];
    
    [self saveVideoToSelectedCrews];
}

- (IBAction)onHideKeyboardWithSender:(id)sender 
{
    
}

// Required UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[[CCCoreManager sharedInstance] server] currentUser] crews] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"postToCrewsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    [label setText:[[[[[[CCCoreManager sharedInstance] server] currentUser] crews] objectAtIndex:[indexPath row]] name]]; 
    
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
    NSArray *usersCrews = [[[[CCCoreManager sharedInstance] server] currentUser] crews];
    NSMutableArray *crewsForVideo = [[NSMutableArray alloc] init];
    
    for(int currentCrew = 0; currentCrew < [usersCrews count]; currentCrew++)
    {
        NSIndexPath *indexPathForCrew = [NSIndexPath indexPathForRow:currentCrew inSection:0];
        
        if ([[self checkedIndexPaths] containsObject:indexPathForCrew])
        {              
            [crewsForVideo addObject:[usersCrews objectAtIndex:currentCrew]];
        }            
    }
    
    [uploadProgressIndicator setHidden:NO];
    
    [[[CCCoreManager sharedInstance] server] addNewVideoWithName:[videoTitleField text] currentVideoLocation:videoPath useNewThread:YES addToCrews:crewsForVideo delegate:self];
}

// CCServerPostObjectDelegate Methods

-(void) videoUploadProgressIsAtPercent:(int)percent
{
    [uploadProgressIndicator setProgress:(float)percent/100];
}

-(void) videoUploadSuccessToGUI
{
    [uploadingIndicator setHidden:YES];

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) videoUploadFailedWithReasonToGUI:(NSString *)reason
{    
    [uploadingIndicator setHidden:YES];
    
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Error uploading video: %@", reason];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh..." 
                                                    message:@"Error uploading the video.  Try again later." 
                                                   delegate:self 
                                          cancelButtonTitle:@"You suck"
                                          otherButtonTitles:@"Try again", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        // Try again
        [uploadingIndicator setHidden:NO];
        [self saveVideoToSelectedCrews];
    }
    else 
    {
        // Cancel
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
