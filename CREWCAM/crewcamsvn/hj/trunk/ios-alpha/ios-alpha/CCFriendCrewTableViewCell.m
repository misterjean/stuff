//
//  CCFriendCrewTableViewCell.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCFriendCrewTableViewCell.h"

@implementation CCFriendCrewTableViewCell
@synthesize crewThumbnailSubview;
@synthesize crewThumbnail;
@synthesize crewSelectedOverlay;
@synthesize crewNameLabel;


- (void) dealloc
{
    [self setCrewNameLabel:nil];
    [self setCrewThumbnail:nil];
    [self setCrewThumbnailSubview:nil];
    [self setCrewSelectedOverlay:nil];
    
    crewForView = nil;
    parentViewController = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setCrewForCell:(id<CCCrew>) crew andViewController:(UIViewController *) viewController
{
    if (crew == crewForView)
        return;
    
    crewForView = crew;
    
    [crewSelectedOverlay setHidden:YES];
    
    [crewThumbnail setImage:[crew getCrewIcon]];
    
    switch ([crewForView getCrewtype])
    {
        case CCFBLocation:
            [crewThumbnail setFrame:CGRectMake(0.5, 0, 73.5, 73.5)];
            break;
            
        case CCFBSchool:
            [crewThumbnail setFrame:CGRectMake(1, 0, 73, 73)];
            break;
            
        case CCFBWork:
            [crewThumbnail setFrame:CGRectMake(0.5, 0, 73.5, 73.5)];
            break;
            
        default:
            break;
    }
    [crewThumbnail setContentMode:UIViewContentModeScaleAspectFit];
    
    [crewNameLabel setText:[[crew getName] uppercaseString]];
    [crewNameLabel setFont:[UIFont getSteelfishFontForSize:30]];
    
    parentViewController = viewController;
}

- (IBAction)onViewMembersPressed:(id)sender {
    CCCrewMembersViewController *crewsMembersView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewMembersView"];
    
    [crewsMembersView setCrewForView:crewForView];
    
    [parentViewController.navigationController pushViewController:crewsMembersView animated:YES];
}

- (void) setCrewSelected:(BOOL)selected
{
    [crewSelectedOverlay setHidden:!selected];
}

@end
