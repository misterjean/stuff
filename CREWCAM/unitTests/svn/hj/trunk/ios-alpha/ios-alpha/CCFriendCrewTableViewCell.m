//
//  CCFriendCrewTableViewCell.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCFriendCrewTableViewCell.h"

@implementation CCFriendCrewTableViewCell
@synthesize crewNameLabel;
@synthesize crewMembersLabel;
@synthesize crewVideosLabel;
@synthesize crewActivityIndicator;


- (void) dealloc
{
    [self setCrewNameLabel:nil];
    [self setCrewMembersLabel:nil];
    [self setCrewVideosLabel:nil];
    [self setCrewActivityIndicator:nil];
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

@end
