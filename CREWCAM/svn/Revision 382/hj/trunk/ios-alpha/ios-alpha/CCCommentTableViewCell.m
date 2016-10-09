//
//  CCCommentTableViewCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCommentTableViewCell.h"

@implementation CCCommentTableViewCell
@synthesize commentersNameLabel;
@synthesize commentTimeSinceLabel;
@synthesize commentTextView;

@synthesize  commentForView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) initializeWithComment:(id<CCComment>) comment
{
    commentForView = comment;
    [commentTimeSinceLabel setText:[NSDate getTimeSinceStringFromDate:[comment getObjectCreatedDate]]];
    [commentersNameLabel setText:[[commentForView  getCommenter] getName]];
    [commentTextView setText:[commentForView getCommentText]];
}

@end
