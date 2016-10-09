//
//  CCSplashPageViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCSplashPageViewController.h"

@interface CCSplashPageViewController ()

@end

@implementation CCSplashPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    didStartFacebookAuthentication = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReturnFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [[CCCoreManager sharedInstance] checkNetworkConnectivity:^(BOOL succeeded, NSError *error)
     {
         if (!succeeded)
         {
             [self loadLoginViewController];
         }
         else
         {
             didStartFacebookAuthentication = YES;
             [[[CCCoreManager sharedInstance] server] startFacebookAuthenticationInBackgroundWithForce:NO andBlock:^(id<CCUser> user, BOOL succeeded, NSError *error)
              {
                  didStartFacebookAuthentication = NO;
                  
                  if (!succeeded)
                  {
                      [self loadLoginViewController];
                  }
                  else if (![user isUserActive])
                  {
                      [self loadUsersDetailsView];
                  }
                  else
                  {
                      [self loadMainTabView];
                  }
              }];
         }
     }];
}

- (void) loadLoginViewController
{
    CCLoginViewController *loginVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"authenticateView"];
    [[self navigationController] pushViewController:loginVC animated:YES];
}

- (void) loadUsersDetailsView
{
    CCUsersDetailsFormViewController *userDetailsVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"usersDetailsViewController"];
    
    [[self navigationController] pushViewController:userDetailsVC animated:YES];
}

- (void) loadMainTabView
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainTabView"];
    [self presentViewController:mainTabView animated:YES completion:^{        
        CCLoginViewController *loginVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"authenticateView"];
        [[self navigationController] pushViewController:loginVC animated:NO];
    }];
}

- (void) handleReturnFromBackground
{
    // Handles somebody switching to our App before finishing the Facebook stuf
    if (didStartFacebookAuthentication)
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Give Facebook 5 seconds to finish...
            sleep(15);
            
            // Check if we've finished
            if (!didStartFacebookAuthentication)
                return;
            
            // Hide some stuff on the UI thread
            dispatch_async( dispatch_get_main_queue(), ^{
                didStartFacebookAuthentication = NO;
                
                [self loadLoginViewController];
            });
        });
    }
}

@end
