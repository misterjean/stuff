//
//  CCVideosCommentsViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCVideosCommentsViewController.h"

@interface CCVideosCommentsViewController ()

@end

@implementation CCVideosCommentsViewController
@synthesize loadingLabel;
@synthesize loadingActivityIndicator;
@synthesize commentsTableView;

@synthesize videoForView;

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
    
    [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)]];
    
    [[self navigationItem] setRightBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Add" target:self action:@selector(onAddCommentPressed:)]];
    
    [commentsTableView setDataSource:self];
    
    [videoForView addVideoUpdateListener:self];
    
    [videoForView loadCommentsInBackgroundWithBlockOrNil:nil];
    
    if ([[videoForView ccComments] count] > 0)
    {
        [loadingLabel setHidden:YES];
        [commentsTableView setHidden:NO];
        [commentsTableView reloadData];
        [loadingActivityIndicator setHidden:YES];
    }
    else if ([videoForView getNumberOfComments] == 0) 
    {
        [loadingLabel setHidden:YES];
        [loadingActivityIndicator setHidden:YES];
        [loadingLabel setHidden:NO];
        [loadingLabel setText:@"No comments yet."];
    }
    
}

- (void) onBackButtonPressed:(id) sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void) setVideoForView:(id<CCVideo>) video
{
    videoForView = video;
}

- (void) addedNewCommentsAtIndexes:(NSArray *) addedCommentIndexes andRemovedCommentsAtIndexes:(NSArray *)removedCommentIndexes
{
    [loadingActivityIndicator setHidden:YES];
    
    if([[videoForView ccComments] count] == 0)
    {
        [commentsTableView setHidden:YES];
        [loadingLabel setText:@"No comments yet."];
        [loadingLabel setHidden:NO];        
    }
    else
    {
        [commentsTableView setHidden:NO];
        [loadingLabel setHidden:YES];
        
        [commentsTableView beginUpdates];
        
        [commentsTableView deleteRowsAtIndexPaths:removedCommentIndexes withRowAnimation:UITableViewRowAnimationFade];
        [commentsTableView insertRowsAtIndexPaths:addedCommentIndexes withRowAnimation:UITableViewRowAnimationFade];            
        
        [commentsTableView endUpdates]; 
    }
}

- (IBAction)onAddCommentPressed:(id)sender 
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Comment" message:@"  " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    

    commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
    [commentTextField setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:commentTextField];
    
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [loadingActivityIndicator setHidden:NO];
        
        if ([commentTextField text]) {
        
            [[[CCCoreManager sharedInstance] server] addNewCommentToVideo:videoForView withText:[commentTextField text] withBlockOrNil:^(BOOL succeeded, NSError *error) 
            {
                [loadingActivityIndicator setHidden:YES];
                
                if (!succeeded)
                {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"Error adding your comment." delegate:self cancelButtonTitle:@"You suck." otherButtonTitles:nil, nil];
                    
                    [alert show];
                }
            }];        
        }
        else 
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"Don't Put Null Messages." delegate:self cancelButtonTitle:@"You suck." otherButtonTitles:nil, nil];
            
            [loadingActivityIndicator setHidden:YES];
            
            [alert show];
        }
    }
        
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[videoForView ccComments] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<CCComment> commentForCell = [[videoForView ccComments] objectAtIndex:[indexPath row]];
    
    static NSString *CellIdentifier = @"commentTableCell";
    CCCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[CCCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell initializeWithComment:commentForCell];
    
    return cell;    
}

- (void)viewDidUnload
{
    [videoForView removeVideoUpdateListener:self];
    [self setLoadingLabel:nil];
    [self setLoadingActivityIndicator:nil];
    [self setCommentsTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
