//
//  CCVideoCommentsViewController.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-05-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCVideo.h"
@interface CCVideoCommentsViewController : UITableViewController

@property (strong, nonatomic) id<CCVideo> video;
- (IBAction)addCommentButton:(id)sender;

@end
