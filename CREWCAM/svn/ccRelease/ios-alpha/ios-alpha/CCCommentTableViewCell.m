//
//  CCCommentTableViewCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCommentTableViewCell.h"

@implementation CCCommentTableViewCell
@synthesize commentTextView;
@synthesize commentersImageView;
@synthesize commenterTimeSinceLabel;
@synthesize  commentForView;

- (void) dealloc
{
    [self setCommenterTimeSinceLabel:nil];
    [self setCommentTextView:nil];
    [self setCommentForView:nil];
    commentForView = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) initializeWithComment:(id<CCComment>) comment
{
    commentForView = comment;
    
    [[commentForView getCommenter] getProfilePictureInBackgroundWithBlock:^(UIImage *image, NSError *error) {
        [commentersImageView setImage:image];
    }];
    
    [commenterTimeSinceLabel setText:[NSDate getTimeSinceStringFromDate:[comment getObjectCreatedDate]]];

    [commentTextView setText:[NSString stringWithFormat:@"%@ \"%@\"", [[commentForView getCommenter] getName], [commentForView getCommentText]]];
    
    CGFloat topCorrect = ([commentTextView contentSize].height - [commentTextView bounds].size.height);
    
    if (topCorrect != 0)
    {
        // Only adjust the cell size to be bigger
        if (topCorrect > 0)
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + topCorrect)];
        
        [commentTextView setFrame:CGRectMake(commentTextView.frame.origin.x, commentTextView.frame.origin.y, commentTextView.frame.size.width, commentTextView.frame.size.height + topCorrect)];
        [commenterTimeSinceLabel setFrame:CGRectMake(commenterTimeSinceLabel.frame.origin.x, commenterTimeSinceLabel.frame.origin.y + topCorrect, commenterTimeSinceLabel.frame.size.width, commenterTimeSinceLabel.frame.size.height)];
    }
}

@end
