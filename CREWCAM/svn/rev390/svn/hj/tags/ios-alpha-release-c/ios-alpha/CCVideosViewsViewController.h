//
//  CCVideosViewsViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCVideo.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"

@interface CCVideosViewsViewController : UIViewController <CCVideoUpdatesDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *viewTableView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic)          id<CCVideo> videoForView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;

- (void) setVideoForView:(id<CCVideo>) video;

@end
