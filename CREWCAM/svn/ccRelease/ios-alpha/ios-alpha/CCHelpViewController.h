//
//  CCHelpViewController.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-08-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCHelpViewPageController.h"
#import "CCCoreManager.h"

@interface CCHelpViewController : UIViewController <UIScrollViewDelegate>
{
    BOOL pageControlUsed;
}

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl      *pageControl;
@property (strong, nonatomic) NSMutableArray            *viewControllers;

- (IBAction)changePage:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)onNextButtonPressed:(id)sender;


@end
