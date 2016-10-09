//
//  CCCommentTableViewCell.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCComment.h"
#import "NSDate+Utility.h"
#import "UIFont+CrewcamFonts.h"
#import <QuartzCore/QuartzCore.h>
#import "CCLongTextCustomTextView.h"

@interface CCCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel                    *commenterTimeSinceLabel;
@property (weak, nonatomic) IBOutlet UITextView                 *commentTextView;
@property (weak, nonatomic) IBOutlet UIImageView                *commentersImageView;

@property (weak, nonatomic)          id<CCComment>              commentForView;

- (void) initializeWithComment:(id<CCComment>) comment;

@end
