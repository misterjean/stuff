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
@synthesize isLoadingIndicator;

@synthesize didLaunchWelcomeView;
@synthesize versionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setDidLaunchWelcomeView:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [versionLabel setText:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
      
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // If this is our view appearing after completing the welcome view navigaction, load the main view
    if (didLaunchWelcomeView)
        [self loadMainTabView];
    else 
    {
        [[CCCoreManager sharedInstance] checkNetworkConnectivity:^(BOOL succeeded, NSError *error) 
        {
            if (!succeeded) 
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You are not connected to an active network. Please connect and try agian. " 
                                                               delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alert show];
                
                // Load the login page
                UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
                UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
                [self presentViewController:mainTabView animated:YES completion:nil];
            }
            else 
            {
                [[[CCCoreManager sharedInstance] server] startFacebookAuthenticationInBackgroundWithForce:NO andBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) 
                {
                    if (!succeeded || ![user isUserActive])
                    {                        
                        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
                        UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
                        [self presentViewController:mainTabView animated:YES completion:nil];
                    }
                    else 
                    {
                        [self loadMainTabView];
                        
                        // Dismiss this view
                        [self dismissViewControllerAnimated:NO completion:nil];
                    }
                }];
            }
        }];
    }
}

- (void)viewDidUnload
{
    [self setVersionLabel:nil];
    [self setIsLoadingIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Required CCServerLoginDelegate methods

- (void)loadMainTabView
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainTabView"];
    mainTabView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mainTabView.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:mainTabView animated:YES];
}

- (void)unloadingView:(UIViewController *)viewController
{
    // The only view that could call this is the welcome view
    [self loadMainTabView];
}

- (IBAction)sendFeedbackButtonPressed:(id)sender 
{
    [TestFlight openFeedbackView];
}
@end
