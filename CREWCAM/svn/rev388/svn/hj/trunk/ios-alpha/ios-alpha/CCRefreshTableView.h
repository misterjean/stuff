//
//  CCRefreshTableView.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCRefreshTableDelegate <NSObject>

@required
- (void)refreshTableOnPullUp;

@end

@interface CCRefreshTableView : UITableView <UITableViewDelegate>
{
    UIView *refreshFooterView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
}

@property (nonatomic, strong) UIView *refreshFooterView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UIActivityIndicatorView *refreshIndicator;
@property (nonatomic, strong) UIImageView *refreshArrow;
@property (nonatomic, strong) NSString *textPull;
@property (nonatomic, strong) NSString *textRelease;
@property (nonatomic, strong) NSString *textLoading;
@property id<CCRefreshTableDelegate> tableDelegate;

- (void)addPullToRefreshFooter;
- (void)startLoading;
- (void)stopLoading;
- (void)refresh;
- (void)pushViewDown; 



@end
