//
//  CCPostVideoForumViewController.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCCrewForSharingCell.h"

typedef enum {
    standardTag,
    askToSaveTag,
} alertViewTag;

@interface CCPostVideoForumViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CCVideoFilesUpdatesDelegate, UIAlertViewDelegate>
{
    NSMutableArray    *crewsForVideo;
}
@property (strong, nonatomic) IBOutlet UITableView *crewsTableViewOutlet;
@property (strong, nonatomic) NSString *videoPath;
@property ccMediaSources mediaSource;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uploadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressIndicator;
@property (strong, nonatomic) NSMutableSet *checkedIndexPaths;
@property (strong, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)onSubmitPressWithSender:(id)sender;
- (IBAction)onHidePressWithSender:(id)sender;
- (IBAction)onCancelPressWithSender:(id)sender;

@end
