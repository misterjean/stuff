//
//  CCPostVideoForumViewController.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCServerPostObjectDelegate.h"
#import "CCCrewsTableViewController.h"

@interface CCPostVideoForumViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CCServerPostObjectDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *crewsTableViewOutlet;
@property (strong, nonatomic) IBOutlet UITextField *videoTitleField;
@property (strong, nonatomic) NSString *videoPath;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uploadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)onSubmitPressWithSender:(id)sender;
- (IBAction)onHideKeyboardWithSender:(id)sender;
@end
