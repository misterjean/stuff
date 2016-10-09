//
//  FeedTableViewController.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedTableViewController.h"

@interface FeedTableViewController ()

@end


@implementation FeedTableViewController 
@synthesize videoArray;
@synthesize moviePlayer;
@synthesize videoAsset;
@synthesize videoImageArray;
@synthesize videosLoading;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

  
    UILongPressGestureRecognizer *lpgr =[[UILongPressGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0;
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    self.videosLoading = YES;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        videoArray = [ServerApi getRecentVideos];
        self.generateVideoImages;
        
        dispatch_async( dispatch_get_main_queue(), ^{
            self.videosLoading = NO;
            [self.tableView reloadData];
            
        });
    });
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (self.videosLoading == NO)
    {
        return videoArray.count;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    //our custom cell
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    
    if (self.videosLoading == NO)
    {
        @try {
            cell.thumbNail.image = [[videoArray objectAtIndex:indexPath.row] getVideoImage]; 
        }
        @catch (NSException *exception) {
        }
        
        if (nil != [[videoArray objectAtIndex:indexPath.row] getVideoLocation] && nil != [LocationManager getCurrentLocation])
        {
            CLLocationDistance distance = [[[videoArray objectAtIndex:indexPath.row] getVideoLocation] distanceFromLocation:[LocationManager getCurrentLocation]];            
            NSString *distanceString = [NSString stringWithFormat:@"%.2f km away", distance/1000];
            cell.locationLabel.text = distanceString;
        }
        
        cell.ownerLabel.text = [[videoArray objectAtIndex:indexPath.row] getCreator];
        cell.titleLabel.text = [[videoArray objectAtIndex:indexPath.row] getTitle];
        
        if([[videoArray objectAtIndex:indexPath.row]getTags].count >= 1)
        {
            NSString* tag1String = (NSString*)[[[videoArray objectAtIndex:indexPath.row]getTags]objectAtIndex:0];
            [cell.tag1 setTitle:tag1String forState:UIControlStateNormal];
        }
        else {
            cell.tag1 = nil;
        }
        
        if([[videoArray objectAtIndex:indexPath.row]getTags].count > 1)
        {
            NSString* tag2String = (NSString*)[[[videoArray objectAtIndex:indexPath.row]getTags]objectAtIndex:1];
            [cell.tag2 setTitle:tag2String forState:UIControlStateNormal];
        }
        else {
            cell.tag2 = nil;
        }

        if([[videoArray objectAtIndex:indexPath.row]getTags].count > 2)
        {
            NSString* tag3String = (NSString*)[[[videoArray objectAtIndex:indexPath.row]getTags]objectAtIndex:2];
            [cell.tag3 setTitle:tag3String forState:UIControlStateNormal];
        }
        else {
            cell.tag3 = nil;
        }                
    }
    else {
        cell.titleLabel.text = @"";
        cell.ownerLabel.text = @"Loading Videos...";
    }
    
    return cell;
}

-(void)playMovieFinished:(NSNotification*)theNotification{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:self.moviePlayer];
    
    [self.moviePlayer.view removeFromSuperview];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [[NSURL alloc]initWithString:[[videoArray objectAtIndex:indexPath.row] getUrl]];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    self.moviePlayer.allowsAirPlay=YES;
    
    printf("PLAYING\n");
    [self.view addSubview:self.moviePlayer.view];
    [[NSNotificationCenter defaultCenter] 
    addObserver:self 
    selector:@selector(playMovieFinished:) 
    name:MPMoviePlayerPlaybackDidFinishNotification 
    object:self.moviePlayer];
        
    [self.moviePlayer setFullscreen:YES animated:YES];  
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self.moviePlayer.view setFrame:CGRectMake(5.0, 20.0, 310, 200)];
    //[self.moviePlayer pause];
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) generateVideoImages
{
    for(int i=0; i<[videoArray count]; i++)
    {
        UIImage *imageForView = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[videoArray objectAtIndex:i] getImageUrl]]]];
        [[videoArray objectAtIndex:i] setVideoImage:imageForView];
    }
}


- (void) handleLongPress:(UILongPressGestureRecognizer *) gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    if (indexPath){
     
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
            
            if ([ServerApi checkVideoPermission:[[videoArray objectAtIndex:indexPath.row] getCreator]] != 0)
                return;
            
            NSLog(@"cell held was %d",indexPath.row);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Options" 
                                                            message:@"Delete?" 
                                                           delegate:self 
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes",nil];
            alert.tag = indexPath.row;
            [alert show];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// NO = 0, YES = 1
	if(buttonIndex == 0) {
    
    
    } else {

        [ServerApi deleteVideo:[videoArray objectAtIndex:alertView.tag]];
        videoArray = [ServerApi getRecentVideos];
        self.generateVideoImages;
        
        
        [self.tableView reloadData];
            
    }
}

- (void)reloadMyTable {
    printf("TABLE RELOADING!!!");
    [self.tableView reloadData];
}

@end
