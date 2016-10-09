//
//  CCSplashPageViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "CCWelcomeViewController.h"
#import "TestFlight.h" 

@interface CCSplashPageViewController : UIViewController

@property Boolean didLaunchWelcomeView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *isLoadingIndicator;

- (IBAction)sendFeedbackButtonPressed:(id)sender;

@end
