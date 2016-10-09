//
//  CCFriendCrewTableViewCell.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCrew.h"
#import "CCCrewMembersViewController.h"
#import "UIFont+CrewcamFonts.h"

@interface CCFriendCrewTableViewCell : UITableViewCell
{
    id<CCCrew>          crewForView;
    UIViewController    *parentViewController;
}

@property (weak, nonatomic) IBOutlet UILabel        *crewNameLabel;
@property (weak, nonatomic) IBOutlet UIView         *crewThumbnailSubview;
@property (weak, nonatomic) IBOutlet UIImageView    *crewThumbnail;
@property (weak, nonatomic) IBOutlet UIImageView    *crewSelectedOverlay;

- (IBAction)onViewMembersPressed:(id)sender;
- (void) setCrewForCell:(id<CCCrew>) crew andViewController:(UIViewController *) viewController;
- (void) setCrewSelected:(BOOL)selected;

@end
