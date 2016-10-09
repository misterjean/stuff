//
//  CCRefreshTableView.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCRefreshTableView.h"

@interface CCRefreshTableView ()

@end

#define REFRESH_FOOTER_HEIGHT 30.0f

@implementation CCRefreshTableView
@synthesize refreshFooterView;
@synthesize refreshLabel;
@synthesize textLoading;
@synthesize textPull;
@synthesize textRelease;
@synthesize tableDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) dealloc
{
    refreshFooterView = nil;
    refreshLabel = nil;
    textPull = nil;
    textRelease = nil;
    textLoading = nil;
    tableDelegate = nil;
}

- (NSInteger) getTableHeight
{
    return [self numberOfRowsInSection:sectionForPull] * [self rowHeight] + offset;
}

- (void) addPullToRefreshFooterToSection:(NSInteger) section withOffset:(NSInteger) customOffset
{
    offset = customOffset;
    sectionForPull = section;
    if (!refreshFooterView)
    {        
        refreshFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, [self getTableHeight], 320, REFRESH_FOOTER_HEIGHT)];
    }
    else {
        [refreshFooterView setFrame:CGRectMake(0, [self getTableHeight], 320, REFRESH_FOOTER_HEIGHT)];
    }
    
    if (!refreshLabel)
    {
        refreshLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_FOOTER_HEIGHT)];
    }
    [refreshLabel setTextAlignment:UITextAlignmentCenter];
    [refreshLabel setBackgroundColor:[UIColor clearColor]];
    [refreshLabel setTextColor:[UIColor crewcamOrangeTextColor]];
    [refreshLabel setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13]];
    [refreshLabel setText:@"PULL TO LOAD MORE VIDEOS"];

    [refreshFooterView addSubview:refreshLabel];
    [self addSubview:refreshFooterView];
    
    self.delegate = self;
}

- (void) removePullToRefreshFooter
{
    self.contentInset = UIEdgeInsetsMake(67, 0, 0, 0);
    [refreshFooterView removeFromSuperview];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (isLoading)
        return;
    isDragging = YES;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isLoading)
    {
    if (scrollView.contentOffset.y + [self frame].size.height < ([self getTableHeight]))
        self.contentInset = UIEdgeInsetsZero;
    else if (scrollView.contentOffset.y + [self frame].size.height >= [self getTableHeight] + REFRESH_FOOTER_HEIGHT)
        self.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_FOOTER_HEIGHT, 0);
    }
    else if (isDragging && scrollView.contentOffset.y + [self frame].size.height > [self getTableHeight])
    {
        [UIView beginAnimations:nil context:nil];
        if (scrollView.contentOffset.y + [self frame].size.height > [self getTableHeight] + REFRESH_FOOTER_HEIGHT)
        {
            [refreshLabel setText:@"RELEASE TO LOAD MORE VIDEOS"];
            //Arrow flip goes here
        }
        else 
        {
            [refreshLabel setText:@"PULL TO LOAD MORE VIDEOS"];
            //Arrow flip goes here
        }
        [UIView commitAnimations];
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (isLoading)
        return;
    isDragging = NO;
    if (scrollView.contentOffset.y + [self frame].size.height >= [self getTableHeight] + REFRESH_FOOTER_HEIGHT)
        [self startLoading];
}

- (void) startLoading
{
    isLoading = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_FOOTER_HEIGHT, 0);
    [refreshLabel setText:@"LOADING..."];
    
    [UIView commitAnimations];
    
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    // Hide the header
    [refreshFooterView removeFromSuperview];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.contentInset = UIEdgeInsetsMake(67, 0, 0, 0);
    
    //[refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel.text = self.textPull;
}

- (void) pushViewDown
{
    [self setContentOffset:CGPointMake(0, [self contentOffset].y + [self rowHeight]/2) animated:YES];
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    
    [tableDelegate refreshTableOnPullUp];    
}



@end
