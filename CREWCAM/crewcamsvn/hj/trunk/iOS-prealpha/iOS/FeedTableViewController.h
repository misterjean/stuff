//
//  FeedTableViewController.h
//  iOS
//
//  Created by Desmond McNamee on 12-04-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import "ServerApi.h"
#import "Video.h"
#import "CustomCell.h"
#import <CoreLocation/CoreLocation.h> 


@interface FeedTableViewController : UITableViewController <UIGestureRecognizerDelegate, CustomCellDelegate>
@property (strong, nonatomic) NSArray *videoArray;
@property (strong, nonatomic) NSArray *videoImageArray;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) AVURLAsset *videoAsset;
@property BOOL videosLoading;

@end
