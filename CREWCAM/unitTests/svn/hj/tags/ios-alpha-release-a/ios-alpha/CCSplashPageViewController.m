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
        [[[CCCoreManager sharedInstance] server] startSilentAuthenticationWithDelegate:self];
    }
}

- (void)viewDidUnload
{
    [self setVersionLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    [[CCCoreManager sharedInstance] setCurrentUser:user];
    
    if (isNewUser)
    {
        // Load welcome page
        [self setDidLaunchWelcomeView:YES];
        
        PFQuery *crewQuery = [PFQuery queryWithClassName:@"Crew"];
        PFObject *pfCrew = [crewQuery getObjectWithId:@"CBsmpQn0LI"];        
        CCParseCrew *ccPCrew = [[CCParseCrew alloc] initWithData:pfCrew];        
        [ccPCrew addMember:user useNewThread:NO];        
        [ccPCrew pushObjectWithNewThread:NO delegateOrNil:nil];
    
        
                
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
