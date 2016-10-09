//
//  CCCrewMembersViewController.m
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewMembersViewController.h"

@interface CCCrewMembersViewController ()

@end

@implementation CCCrewMembersViewController
@synthesize loadingLabel;
@synthesize viewTableView;
@synthesize activityIndicator;
@synthesize navigationItem;
@synthesize navigationBar;
@synthesize crewForView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setCrewForView:(id<CCCrew>) crew
{
    crewForView = crew;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [viewTableView setDataSource:self];
    
    if (crewForView == nil)
        [NSException raise:@"Loaded crew memebers table without calling setCrewForView!" format:@"Loaded crew memebers table without calling setCrewForView!"];
    
    [crewForView addCrewUpdateListener:self];
    
    [crewForView loadMembersInBackgroundWithBlock:nil];
    
    if ([[crewForView ccUsersThatAreMembers] count] > 0)
    {
        [viewTableView setHidden:NO];
        [activityIndicator setHidden:YES];
        [loadingLabel setHidden:YES];
        [viewTableView reloadData];
    }
    else if ([crewForView getNumberOfMembers] == 0) 
    {
        [loadingLabel setHidden:NO];
        [activityIndicator setHidden:YES];
        [loadingLabel setText:@"No members, how are you here?"];
    }
    
    [[[self navigationController] navigationBar] setOpaque:YES];
    [[[self navigationController] navigationBar] setClipsToBounds:NO];    
    if ([[UIScreen mainScreen] scale] == 0x40000000)
    {
        [[self navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
        [[self navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    else 
    {
        [[self navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }   
    
    [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)]];
}

- (IBAction)onBackButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) addedNewMembersAtIndexes:(NSArray *) newMemberIndexes andRemovedMembersAtIndexes:(NSArray *) deletedMemberIndexes
{
    [viewTableView setHidden:NO];
    [loadingLabel setHidden:YES];
    [activityIndicator setHidden:YES];
    
    [viewTableView beginUpdates];
    
    [viewTableView deleteRowsAtIndexPaths:deletedMemberIndexes withRowAnimation:UITableViewRowAnimationFade];
    [viewTableView insertRowsAtIndexPaths:newMemberIndexes withRowAnimation:UITableViewRowAnimationFade];            
    
    [viewTableView endUpdates];      
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[crewForView ccUsersThatAreMembers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"crewMemberCell";
    CCCrewMemberTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CCCrewMemberTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    id<CCUser> userForCell = [[crewForView ccUsersThatAreMembers] objectAtIndex:[indexPath row]];
    
    [[cell memberNameLabel] setText:[userForCell getName]];
    
    [[cell memberImage] setHidden:YES];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{        
        UIImage *usersProfilePic = [userForCell getProfilePicture];        
        dispatch_async( dispatch_get_main_queue(), ^{
            [[cell memberImage] setImage:usersProfilePic];
            [[cell memberImage] setHidden:NO];
        });
    });  
    return cell;
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (id<CCUser> user in [crewForView ccUsersThatAreMembers])
    {
        [user setLocalUIImage:nil];
    }
}

- (void)viewDidUnload
{
    [crewForView removeCrewUpdateListener:self];
    
    [self setLoadingLabel:nil];
    [self setViewTableView:nil];
    [self setActivityIndicator:nil];
    [self setNavigationItem:nil];
    [self setNavigationBar:nil];
    [self setCrewForView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
