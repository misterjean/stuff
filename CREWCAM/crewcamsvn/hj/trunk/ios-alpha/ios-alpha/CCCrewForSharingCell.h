//
//  CCCrewForSharingCell.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-12.
//
//

#import <UIKit/UIKit.h>
#import "CCCrew.h"
#import "CCCrewMembersViewController.h"
#import "UIView+Utilities.h"

@interface CCCrewForSharingCell : UITableViewCell
{
    id<CCCrew>          crewForCell;
    UIViewController    *parentViewController;
    BOOL                isRowSelected;
}

@property (weak, nonatomic) IBOutlet UILabel                *crewNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView            *publicPrivateLabel;
@property (weak, nonatomic) IBOutlet UIView                 *crewIconSubview;
@property (weak, nonatomic) IBOutlet UIImageView            *selectedOverlay;
@property (weak, nonatomic) IBOutlet UIImageView            *crewThumbnailView;

- (void) setCrewForCell:(id<CCCrew>) crew withViewController:(UIViewController *) viewController;
- (IBAction)viewCrewsMembersButtonPressed:(id)sender;
- (void) setCrewSelected:(BOOL)selected;

@end
