//
//  CCVideosViewsViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCVideosViewsViewController.h"

@interface CCVideosViewsViewController ()

@end

@implementation CCVideosViewsViewController
@synthesize viewTableView;
@synthesize loadingLabel;
@synthesize videoForView;
@synthesize loadingActivity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setVideoForView:(id<CCVideo>) video
{
    videoForView = video;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)]];
    
    [viewTableView setDataSource:self];

    if (videoForView == nil)
        [NSException raise:@"Loaded views table without calling setVideoForView!" format:@"Loaded views table without calling setVideoForView!"];
    
    [videoForView addVideoUpdateListener:self];
    
    [videoForView loadViewsInBackgroundWithBlockOrNil:nil];        
    
    if ([[videoForView ccUsersThatViewed] count] > 0)
    {
        [viewTableView setHidden:NO];
        [loadingActivity setHidden:YES];
        [loadingLabel setHidden:YES];
        [viewTableView reloadData];
    }
    else if ([videoForView getNumberOfViews] == 0) 
    {
        [loadingActivity setHidden:YES];
        [loadingLabel setText:@"No views yet..."];
    }
}


- (void) onBackButtonPressed:(id) sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void) addedNewViewsAtIndexes:(NSArray *) addedViewsIndexes andRemovedViewsAtIndexes:(NSArray *)removedViewsIndexes
{
    [viewTableView setHidden:NO];
    [loadingLabel setHidden:YES];
    [loadingActivity setHidden:YES];
    
    [viewTableView beginUpdates];
    
    [viewTableView insertRowsAtIndexPaths:addedViewsIndexes withRowAnimation:UITableViewRowAnimationLeft];            
    [viewTableView deleteRowsAtIndexPaths:removedViewsIndexes withRowAnimation:UITableViewRowAnimationFade];
    
    [viewTableView endUpdates];  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[videoForView ccUsersThatViewed] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"videoTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    id<CCUser> userForCell = [[videoForView ccUsersThatViewed] objectAtIndex:[indexPath row]];
    
    UILabel *viewerNameLabel = (UILabel *)[cell viewWithTag:10];
    
    [viewerNameLabel setText:[userForCell getName]];
    
    return cell;
}

- (void)viewDidUnload
{
    [videoForView removeVideoUpdateListener:self];
    
    [self setViewTableView:nil];
    [self setLoadingLabel:nil];
    [self setLoadingActivity:nil];
    [self setVideoForView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
