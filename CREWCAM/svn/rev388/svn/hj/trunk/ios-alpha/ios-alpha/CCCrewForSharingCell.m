//
//  CCCrewForSharingCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-12.
//
//

#import "CCCrewForSharingCell.h"

@implementation CCCrewForSharingCell
@synthesize crewNameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setCrewForCell:(id<CCCrew>) crew withViewController:(UIViewController *) viewController
{
    parentViewController = viewController;
    crewForCell = crew;
    [crewNameLabel setText:[crewForCell getName]];
}

- (IBAction)viewCrewsMembersButtonPressed:(id)sender
{
    CCCrewMembersViewController *crewsMembersView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewMembersView"];

    [crewsMembersView setCrewForView:crewForCell];
    
    [parentViewController presentModalViewController:crewsMembersView animated:YES];
}

@end
