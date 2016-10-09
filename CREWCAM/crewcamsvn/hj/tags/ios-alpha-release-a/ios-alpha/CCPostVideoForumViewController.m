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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setCrewsTableViewOutlet:nil];
    [self setVideoTitleField:nil];
    [self setVideoPath:nil];
    [self setUploadingIndicator:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onSubmitPressWithSender:(id)sender 
{    
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
    return [[[[CCCoreManager sharedInstance] currentUser] crews] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"postToCrewsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    [label setText:[[[[[CCCoreManager sharedInstance] currentUser] crews] objectAtIndex:[indexPath row]] name]]; 
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Add the checmark for the cell
    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (thisCell.accessoryType == UITableViewCellAccessoryNone)
    {
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else 
    {
        thisCell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)saveVideoToSelectedCrews
{
    NSArray *usersCrews = [[[CCCoreManager sharedInstance] currentUser] crews];
    NSMutableArray *crewsForVideo = [[NSMutableArray alloc] init];
    
    for(int currentCrew = 0; currentCrew < [usersCrews count]; currentCrew++)
    {
        UITableViewCell *cellForCrew = [crewsTableViewOutlet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentCrew inSection:0]];
        
        if ([cellForCrew accessoryType] == UITableViewCellAccessoryCheckmark)
        {              
            [crewsForVideo addObject:[usersCrews objectAtIndex:currentCrew]];
        }            
    }
    
    [[[CCCoreManager sharedInstance] server] addNewVideoWithName:[videoTitleField text] currentVideoLocation:videoPath useNewThread:YES addToCrews:crewsForVideo delegate:self];
}

// CCServerPostObjectDelegate Methods
-(void) videoUploadSuccessToGUI
{
    [uploadingIndicator setHidden:YES];
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelDebug message:@"Video succesfully uploaded"];
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
