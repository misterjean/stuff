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
@synthesize publicPrivateLabel;

- (void) dealloc
{
    crewForCell = nil;
    parentViewController = nil;
    
    [self setCrewNameLabel:nil];
    [self setPublicPrivateLabel:nil];
    
}

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
    
    if ([crewForCell getSecuritySetting] == CCPrivate)
    {
        [publicPrivateLabel setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Public_ACT" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else
    {
        [publicPrivateLabel setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTN_Private_ACT" ofType:@"png"]] forState:UIControlStateNormal];
    }
         
}

- (IBAction)viewCrewsMembersButtonPressed:(id)sender
{
    CCCrewMembersViewController *crewsMembersView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewMembersView"];

    [crewsMembersView setCrewForView:crewForCell];
    
    [parentViewController presentModalViewController:crewsMembersView animated:YES];
}

@end
