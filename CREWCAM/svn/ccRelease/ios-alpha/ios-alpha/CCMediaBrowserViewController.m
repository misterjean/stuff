//
//  CCMediaBrowserViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-27.
//
//

#import "CCMediaBrowserViewController.h"

@interface CCMediaBrowserViewController ()

@end

@implementation CCMediaBrowserViewController
@synthesize mediaTableView;

NSMutableArray *videosInLibrary;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addCrewcamTitleToViewController:@"Your Media"];
    
    if ([self navigationController])
        [self.view addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(didPressBackButton)];
    
    videosInLibrary = [[NSMutableArray alloc] init];
        
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    void (^assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if(group != nil)
        {
            [assetGroups addObject:group];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if ([result valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo)
                {
                    [videosInLibrary addObject:result];
                }
            }];            
        }
        else
        {
            [mediaTableView reloadData];
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    photoLibrary = [[ALAssetsLibrary alloc] init];
    
    [photoLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:assetGroupEnumerator     
                         failureBlock:^(NSError *error)
    {
        NSLog(@"A problem occurred");
    }];
    
    [mediaTableView setDataSource:self];
    [mediaTableView setDelegate:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidUnload
{
    [self setMediaTableView:nil];
    
    [super viewDidUnload];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) didPressBackButton
{
    if ([self navigationController])
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videosInLibrary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    ALAsset *videoForCell = [videosInLibrary objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [mediaTableView dequeueReusableCellWithIdentifier:nil];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    UIImageView *testView = [[UIImageView alloc] init];
    testView.clipsToBounds = YES;
    [testView setContentMode:UIViewContentModeScaleAspectFill];
    [testView setImage:[UIImage imageWithCGImage:videoForCell.thumbnail]];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@",[videoForCell valueForProperty:ALAssetPropertyDate]]];
    [testView setFrame:CGRectMake(0, 0, 50, 50)];
    [cell addSubview:testView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *video = [videosInLibrary objectAtIndex:[indexPath row]];
    NSURL *tempURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"converted.mov"]];
    NSLog(@"%@", [video valueForProperty:ALAssetPropertyURLs]);
    NSLog(@"%@", [video valueForProperty:ALAssetPropertyRepresentations]);

    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[[video defaultRepresentation] url] options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = tempURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[tempURL path]])
        {
            NSError *error;
            if ([fileManager removeItemAtPath:[tempURL path] error:&error] == NO)
            {
                
            }
        }

    
    // MAKE THE EXPORT SYNCHRONOUS
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_release(semaphore);

    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[tempURL path] error:nil];
    if(fileAttributes != nil)
    {
        NSString *fileSize = [fileAttributes objectForKey:NSFileSize];
        NSLog(@"%@",fileSize);
    }
        
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];

    CCPostVideoForumViewController *forumVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PostVideoForumView"];

    [forumVC setVideoPath:[tempURL path]];
    [forumVC setMediaSource:ccVideoLibrary];
    [forumVC setStoredNavigationController:self];   

    [self presentViewController:forumVC animated:YES completion:nil];
}

@end
