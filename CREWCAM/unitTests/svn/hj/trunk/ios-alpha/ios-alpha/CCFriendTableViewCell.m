//
//  CCFriendTableViewCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCFriendTableViewCell.h"

@implementation CCFriendTableViewCell
@synthesize profilePictureView;
@synthesize usersNameLabel;

- (void)dealloc
{
    [self setProfilePictureView:nil];
    [self setUsersNameLabel:nil];
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
