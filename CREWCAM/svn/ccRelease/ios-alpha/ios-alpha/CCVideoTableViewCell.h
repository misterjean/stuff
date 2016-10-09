//
//  CCVideoTableViewCell.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCVideo.h"
#import <MapKit/MapKit.h>
#import "CCCoreManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CCVideosViewsViewController.h"
#import "CCVideosCommentsViewController.h"
#import "CCCrewViewController.h"
#import "CCVideoIconView.h"




@interface CCVideoTableViewCell : UITableViewCell
{
    CCVideoIconView *videoIconView;
}

- (void)initializeWithVideo:(id<CCVideo>) videoForCell andNavigationController:(CCCrewViewController *) navigationController;
@end
