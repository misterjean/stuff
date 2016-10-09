//
//  CCVideoViewController.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCrew.h"
#import "CCCoreManager.h"
#import "CCVideo.h"
#import "CCInviteAndAddCrewViewController.h"
#import "CCCrewMembersViewController.h"
#import "CCRefreshTableView.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"

@interface CCCrewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CCRefreshTableDelegate, CCCrewUpdatesDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImagePickerController *cameraUI;
    ccMediaSources          mediaSource;
    NSString                *videoPath;
}

@property (weak, nonatomic) IBOutlet CCRefreshTableView     *videoTableView;
@property (strong, nonatomic) id<CCCrew>                    crewForView;
@property (strong, nonatomic) NSArray                       *sortedVideoList;
@property (weak, nonatomic) IBOutlet UILabel                *loadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView            *securitySettingImage;
@property (weak, nonatomic) IBOutlet UIButton               *replyButton;
@property (weak, nonatomic) IBOutlet UIButton               *viewMembersButton;
@property (weak, nonatomic) IBOutlet UIButton               *inviteButton;
@property BOOL                                               isLoadingForNotification;

-(void) initWithCrew:(id<CCCrew>)crew;
- (IBAction)onReplyButtonPress:(id)sender;

@end
