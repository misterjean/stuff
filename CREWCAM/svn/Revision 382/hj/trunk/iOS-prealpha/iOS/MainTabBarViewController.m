//
//  MainTabBarViewController.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end


@implementation MainTabBarViewController

static int videoOrientation;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    printf("Orientation Being Called %d", interfaceOrientation);
    
    [MainTabBarViewController setVideoOrientation:interfaceOrientation];
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


+ (void) setVideoOrientation:(int)orientation {
    videoOrientation = orientation;
}


+ (int) getVideoOrientation {
    return videoOrientation;
}

@end
