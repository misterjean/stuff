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

        BOOL nflag = ([NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.co.in/"] encoding:NSASCIIStringEncoding error:nil]!=NULL)?YES:NO; 
        
        if (!nflag) 
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You are not connected to an active network. Please connect and try agian. " 
                                                           delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
            
            [self silentLoginFailedWithReason:@"No connection"];
        }
        else 
        {
            [[[CCCoreManager sharedInstance] server] startSilentAuthenticationWithDelegate:self];
        }
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

- (void)loginCompleteWithUser: (id<CCUser>) user isNewUser:(Boolean)isNewUser
{
    // Ignore
}

- (void)loginFailedWithReason: (NSString *)reason
{
    // Ignore
}

- (void)loadMainTabView
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainTabView"];
    mainTabView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mainTabView.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:mainTabView animated:YES];
}

- (void)silentLoginCompleteWithUser: (id<CCUser>) user isNewUser:(Boolean)isNewUser
{
    // Save the user
    [[[CCCoreManager sharedInstance] server] setCurrentUser:user];
    
    if ([user isLocked])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We're Building Stuff" 
                                                        message:@"The Alpha has been temporarily locked.  Please try again later." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Aw, ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [isLoadingIndicator setHidden:YES];
        
        return;
    }
    
    if (isNewUser)
    {
        // Load welcome page
        [self setDidLaunchWelcomeView:YES];
            
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
        
        CCWelcomeViewController *welcomeNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"welcomeNavigationController"];        
        
        [self presentViewController:welcomeNavigationController animated:YES completion:nil];          
    } 
    else
    {
        // Load main page
        [self loadMainTabView];
    }
    
    // Dismiss this view
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)unloadingView:(UIViewController *)viewController
{
    // The only view that could call this is the welcome view
    [self loadMainTabView];
}

- (void)silentLoginFailedWithReason: (NSString *)reason
{
    // Load login page
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"loginPageView"];
    [self presentViewController:mainTabView animated:YES completion:nil];
}

- (IBAction)sendFeedbackButtonPressed:(id)sender 
{
    [TestFlight openFeedbackView];
}
@end
