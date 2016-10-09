//
//  CCCustomTextView.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-30.
//
//

#import <UIKit/UIKit.h>

@interface UITextView ()
- (id)styleString;
@end

@interface CCCustomTextView : UITextView
@property (strong, nonatomic) NSNumber *lineHeight;

@end
