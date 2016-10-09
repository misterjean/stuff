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

- (void) setVideoForView:(id<CCVideo>) video
{
    videoForView = video;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] addCrewcamTitleToViewController:@"VIEWS"];
    
    [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)];
    
    [viewTableView setDataSource:self];

    if (videoForView == nil)
        [NSException raise:@"Loaded views table without calling setVideoForView!" format:@"Loaded views table without calling setVideoForView!"];
    
    [videoForView addVideoUpdateListener:self];
    
    [videoForView loadViewsInBackgroundWithBlockOrNil:nil];        
    
    if ([[videoForView ccUsersThatViewed] count] > 0)
    {
        [viewTableView setHidden:NO];
        [loadingLabel setHidden:YES];
        [viewTableView reloadData];
    }
    else if ([videoForView getNumberOfViews] == 0) 
    {
        [loadingLabel setText:@"NO VIEWS."];
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
    
    [viewTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([[videoForView ccUsersThatViewed] count] / 3) + (([[videoForView ccUsersThatViewed] count] % 3) > 0 ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"viewerCell";
    CCPeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CCPeopleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSMutableArray *viewersForRow = [[NSMutableArray alloc] init];
    
    int startingViewerIndex = ([indexPath row] * 3);
    for(int viewerIndex = startingViewerIndex; viewerIndex < [[videoForView ccUsersThatViewed] count] && viewerIndex < (startingViewerIndex + 3); viewerIndex++)
    {
        [viewersForRow addObject:[[CCBasePerson alloc] initWithCCUser:[[videoForView ccUsersThatViewed] objectAtIndex:viewerIndex]]];
    }
    
    [cell setForPeople:viewersForRow areIconsSelectable:YES andArePeopleSelectedBools:nil arePeopleRequestable:YES];
    
    return cell;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (id<CCUser> user in [videoForView ccUsersThatViewed])
    {
        [user clearProfilePicture];
    }
}

- (void)viewDidUnload
{
    [videoForView removeVideoUpdateListener:self];
    
    [self setViewTableView:nil];
    [self setLoadingLabel:nil];
    [self setVideoForView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
