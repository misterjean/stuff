//
//  PostVideoForumViewController.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostVideoForumViewController.h"

@interface PostVideoForumViewController ()

@end

@implementation PostVideoForumViewController
@synthesize moviePath;
@synthesize tagsField;
@synthesize titleField;
@synthesize orientation;

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
    [self setOrientation:nil];
    [self setTitleField:nil];
    [self setTagsField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    printf("Orientation Being Called %d\n", interfaceOrientation);
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)hideKeyboard:(id)sender {
    
    [self.titleField resignFirstResponder];
    [self.tagsField resignFirstResponder];
    
}

- (IBAction)postVideo:(id)sender {
    
    NSData *videoData = [NSData dataWithContentsOfFile: moviePath];
    NSLog(@"Size: %d", [videoData length]);
    
    
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:moviePath] options:nil];
    
    NSError *error = nil;
    CMTime capturePoint = CMTimeMakeWithSeconds(0.1, 600);
    CMTime actualTime;        
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];    
    CGImageRef capturedImage = [imageGenerator copyCGImageAtTime:capturePoint actualTime:&actualTime error:&error];
    UIImage *imageForView;
    
    if (orientation == 1) {
        imageForView = [[UIImage alloc] initWithCGImage:capturedImage scale:(CGFloat)1.0 orientation:(UIImageOrientation)UIImageOrientationRight];
    }  else  if (orientation == 2){
        imageForView = [[UIImage alloc] initWithCGImage:capturedImage scale:(CGFloat)1.0 orientation:(UIImageOrientation)UIImageOrientationLeft];
    }  else  if (orientation == 3){    
        imageForView = [[UIImage alloc] initWithCGImage:capturedImage scale:(CGFloat)1.0 orientation:(UIImageOrientation)UIImageOrientationUp];
    }  else  if (orientation == 4){    
        imageForView = [[UIImage alloc] initWithCGImage:capturedImage scale:(CGFloat)1.0 orientation:(UIImageOrientation)UIImageOrientationDown];
    }
    //NSData *videoImageData = UIImagePNGRepresentation(imageForView);

    NSData *videoImageData = UIImageJPEGRepresentation(imageForView, 0.1);
    
    if([ServerApi uploadVideo:self.tagsField.text: self.titleField.text: videoData: videoImageData: self.orientation] < 0)
    {
        printf("Failed to upload video");
    }
    else {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        FeedTableViewController *feedVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"feedView"];
        feedVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        feedVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:feedVC animated:NO completion:nil];
    }
    
}




@end
