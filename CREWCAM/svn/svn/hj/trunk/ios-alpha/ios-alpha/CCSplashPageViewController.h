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

@interface CCSplashPageViewController : UIViewController <CCServerLoginDelegate>
@property Boolean didLaunchWelcomeView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
- (IBAction)sendFeedbackButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *isLoadingIndicator;

@end
