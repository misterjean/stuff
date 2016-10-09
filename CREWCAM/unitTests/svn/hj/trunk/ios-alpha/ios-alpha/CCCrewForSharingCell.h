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

@interface CCCrewForSharingCell : UITableViewCell
{
    id<CCCrew>      crewForCell;
    UIViewController *parentViewController;
}

@property (weak, nonatomic) IBOutlet UILabel        *crewNameLabel;
@property (weak, nonatomic) IBOutlet UIButton       *publicPrivateLabel;

- (void) setCrewForCell:(id<CCCrew>) crew withViewController:(UIViewController *) viewController;
- (IBAction)viewCrewsMembersButtonPressed:(id)sender;

@end
