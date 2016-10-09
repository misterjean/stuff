//
//  CustomCell.h
//  iOS
//
//  Created by Desmond McNamee on 12-04-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "video.h"

@protocol CustomCellDelegate <NSObject>
@required
- (void)reloadMyTable;
@property (strong, nonatomic) NSArray *videoArray;
@end

@interface CustomCell : UITableViewCell{
    
    UILabel *titleLabel;
    UILabel *ownerLabel;
    UILabel *locationLabel;    
    UIImageView *thumbNail;
    UIButton *tag1;
    UIButton *tag2;
    UIButton *tag3;
    
    id<CustomCellDelegate> delegate;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *ownerLabel;
@property (nonatomic, retain) UILabel *locationLabel;
@property (nonatomic, retain) UIImageView *thumbNail;
@property (nonatomic, retain) UIButton *tag1;
@property (nonatomic, retain) UIButton *tag2;
@property (nonatomic, retain) UIButton *tag3;

@property (nonatomic, retain) id<CustomCellDelegate> delegate;



@end
