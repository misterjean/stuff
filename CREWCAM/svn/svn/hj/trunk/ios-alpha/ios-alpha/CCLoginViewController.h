//
//  CCLoginViewControllerViewController.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCServerLoginDelegate.h"
#import "CCCoreManager.h"

@interface CCLoginViewController : UIViewController <CCServerLoginDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *facebookLoadingIndicator;
@property Boolean didLaunchWelcomeView;

@end
