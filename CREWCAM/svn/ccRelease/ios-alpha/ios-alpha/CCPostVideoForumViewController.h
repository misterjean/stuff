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
    askToSaveTag = 1,
    askToDeleteTag,
    reauthorizeTag,
} alertViewTag;

@interface CCPostVideoForumViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CCCrewcamAlertViewDelegate>
{
    NSMutableArray    *crewsForVideo;
    NSMutableArray    *crewsForPosting;
}
@property (weak, nonatomic) IBOutlet UITableView    *crewsTableViewOutlet;
@property (strong, nonatomic) NSString              *videoPath;
@property ccMediaSources mediaSource;
@property (weak, nonatomic) IBOutlet UIButton       *shareButton;
@property (strong, nonatomic) NSMutableSet          *checkedIndexPaths;
@property (weak, nonatomic) IBOutlet UIButton       *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton       *postToFacebook;
@property (strong, nonatomic) UIViewController      *storedNavigationController;

- (IBAction)onSubmitPressWithSender:(id)sender;
- (IBAction)onCancelPressWithSender:(id)sender;
- (IBAction)postToFacebookButtonPressed:(id)sender;
- (IBAction)shareWithFacebookHelpPressed:(id)sender;

@end
