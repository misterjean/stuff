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

@interface CCCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel                    *commentersNameLabel;
<<<<<<< .mine
@property (weak, nonatomic) IBOutlet UILabel                    *commentTimeSinceLabel;
=======
@property (weak, nonatomic) IBOutlet UILabel                    *commenterTimeSinceLabel;
>>>>>>> .r397
@property (weak, nonatomic) IBOutlet UITextView                 *commentTextView;

@property (weak, nonatomic)          id<CCComment>              commentForView;

- (void) initializeWithComment:(id<CCComment>) comment;

@end
