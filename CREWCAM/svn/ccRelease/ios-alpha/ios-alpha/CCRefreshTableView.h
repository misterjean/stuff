//
//  CCRefreshTableView.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+CrewcamFonts.h"
#import "UIColor+CrewcamColors.h"

@protocol CCRefreshTableDelegate <NSObject>

@required
- (void)refreshTableOnPullUp;

@end

@interface CCRefreshTableView : UITableView <UITableViewDelegate>
{
    BOOL isDragging;
    BOOL isLoading;
    NSInteger sectionForPull;
    NSInteger offset;
}

@property (nonatomic, strong) UIView *refreshFooterView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) NSString *textPull;
@property (nonatomic, strong) NSString *textRelease;
@property (nonatomic, strong) NSString *textLoading;
@property id<CCRefreshTableDelegate> tableDelegate;

- (void) addPullToRefreshFooterToSection:(NSInteger) section withOffset:(NSInteger) customOffset;
- (void) removePullToRefreshFooter;
- (void)startLoading;
- (void)stopLoading;
- (void)refresh;
- (void)pushViewDown; 



@end
