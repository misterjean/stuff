//
//  FeedCell.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedCell.h"

@implementation FeedCell
@synthesize videoView;

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
