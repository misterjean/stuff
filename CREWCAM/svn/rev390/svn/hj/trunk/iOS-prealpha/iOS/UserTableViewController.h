//
//  UserTableViewController.h
//  iOS
//
//  Created by Desmond McNamee on 12-04-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import "ServerApi.h"
#import "Video.h"

@interface UserTableViewController : UITableViewController
@property (strong, nonatomic) NSArray *videoArray;
@property (strong, nonatomic) NSArray *videoImageArray;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) AVURLAsset *videoAsset;
@property BOOL videosLoading;

@end
