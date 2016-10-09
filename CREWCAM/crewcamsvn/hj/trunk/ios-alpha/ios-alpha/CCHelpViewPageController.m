//
//  CCHelpViewPageController.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-08-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCHelpViewPageController.h"

@interface CCHelpViewPageController ()

@end

@implementation CCHelpViewPageController
@synthesize tutorialImage;

- (void)viewDidUnload
{
    [self setTutorialImage:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (id)initWithPageNumber:(int)page
{
    if ((self = [[UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"helpViewPage"]))
    {
        //pageNumber = page;
    }
    return self;
}


@end
