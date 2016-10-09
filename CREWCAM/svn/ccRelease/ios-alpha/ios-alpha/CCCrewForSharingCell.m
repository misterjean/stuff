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
@synthesize crewIconSubview;
@synthesize selectedOverlay;
@synthesize crewThumbnailView;
@synthesize outlineImageView;

- (void) dealloc
{
    crewForCell = nil;
    parentViewController = nil;
    
    [self setCrewNameLabel:nil];
    [self setPublicPrivateLabel:nil];
    [self setCrewIconSubview:nil];
    [self setSelectedOverlay:nil];
    [self setCrewThumbnailView:nil];    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
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
    isRowSelected = NO;
    
    [selectedOverlay setHidden:YES];
    
    parentViewController = viewController;

    crewForCell = crew;
    
    [crewThumbnailView setImage:[crew getCrewIcon]];
    [crewThumbnailView setContentMode:UIViewContentModeScaleAspectFit];
    
    [crewForCell getCrewThumbnailInBackgroundWithBlock:^(UIImage *image, NSError *error) {
        if (image != nil)
        {
            [crewThumbnailView setImage:image];
            [crewThumbnailView setContentMode:UIViewContentModeScaleAspectFill];
        }
    }];

    
    [crewNameLabel setText:[[crewForCell getName] uppercaseString]];
    [crewNameLabel setFont:[UIFont getSteelfishFontForSize:30]];
    
    if ([crewForCell getSecuritySetting] == CCPrivate)
    {
        [publicPrivateLabel setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_Private" ofType:@"png"]]];
    }
    else
    {
        [publicPrivateLabel setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_Public" ofType:@"png"]]];
    }     
    
    if ([crewForCell getCrewtype] == CCDeveloper)
    {
        [outlineImageView setHidden:NO];
    }
    else
    {
        [outlineImageView setHidden:YES];
    }
    
    if ( [crewForCell getCrewtype] == CCFBWork ||
         [crewForCell getCrewtype] == CCFBSchool ||
         [crewForCell getCrewtype] == CCFBLocation ||
         [crewForCell getCrewtype] == CCDeveloper)
    {
        [publicPrivateLabel setHidden:YES];
    }
    else 
    {
        [publicPrivateLabel setHidden:NO];
    }
}

- (IBAction)viewCrewsMembersButtonPressed:(id)sender
{
    CCCrewMembersViewController *crewsMembersView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewMembersView"];

    [crewsMembersView setCrewForView:crewForCell];
    
    [parentViewController presentModalViewController:crewsMembersView animated:YES];
}

- (void) setCrewSelected:(BOOL)selected
{
    [selectedOverlay setHidden:!selected];
    isRowSelected = selected;
}
@end
