//
//  CCHelpViewController.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-08-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCHelpViewController.h"

static NSInteger numberOfTutorialPages = 3;

@interface CCHelpViewController ()

@end

@implementation CCHelpViewController
@synthesize scrollView;
@synthesize pageControl;
@synthesize viewControllers;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSMutableArray *tempControllerArray = [[NSMutableArray alloc] initWithCapacity:numberOfTutorialPages];
    for (int index = 0; index < numberOfTutorialPages; index++)
    {
        [tempControllerArray addObject:[NSNull null]];
    }
    
    viewControllers = tempControllerArray;
        
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numberOfTutorialPages, scrollView.frame.size.height);
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    pageControl.numberOfPages = numberOfTutorialPages;
    pageControl.currentPage = 0;
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setViewControllers:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    
    if (page >= numberOfTutorialPages)
        return;
    
    // replace the placeholder if necessary
    CCHelpViewPageController *helpPageController = [viewControllers objectAtIndex:page];
    if ((NSNull *)helpPageController == [NSNull null])
    {
        helpPageController = [[CCHelpViewPageController alloc] initWithPageNumber:page];
        [viewControllers replaceObjectAtIndex:page withObject:helpPageController];
    }
    
    // add the controller's view to the scroll view
    if (helpPageController.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        helpPageController.view.frame = frame;
        [scrollView addSubview:helpPageController.view];
        [[helpPageController tutorialImage] setContentMode:UIViewContentModeScaleAspectFit];
        
        switch (page) {
            case 0:
            {
                [[helpPageController tutorialImage] setImage:[UIImage imageNamed:@"CC_tutorial-01"]];
                break;
            }
            case 1:
            {
                [[helpPageController tutorialImage] setImage:[UIImage imageNamed:@"CC_tutorial-02"]];
                break;                
            }
            case 2:
            {
                [[helpPageController tutorialImage] setImage:[UIImage imageNamed:@"CC_tutorial-03"]];
                break;
            }
            default:
                break;
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (pageControlUsed)
    {
        return;
    }
	
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

- (IBAction)doneButtonPressed:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (IBAction)onNextButtonPressed:(id)sender {
    if (pageControl.currentPage == numberOfTutorialPages - 1)
    {
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    
    pageControl.currentPage++;
    [self changePage:nil];
}
@end
