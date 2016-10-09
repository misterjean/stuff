//
//  CCLoginViewControllerViewController.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLoginViewController.h"

@interface CCLoginViewController ()

@end

@implementation CCLoginViewController
@synthesize facebookLoadingIndicator;
@synthesize didLaunchWelcomeView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        didLaunchWelcomeView = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (didLaunchWelcomeView)
        [self loadMainTabView];
}

- (void)viewDidUnload
{
    [self setFacebookLoadingIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onFacebookButtonPressWithSender:(id)sender 
{
    // Show the loading indicator
    
    BOOL nflag = ([NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.co.in/"] encoding:NSASCIIStringEncoding error:nil]!=NULL)?YES:NO; 
    if (!nflag) 
        
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You are not connected to an active network. Please connect and try agian. " 
                                                       delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
        
    }    
    else 
    {

        [facebookLoadingIndicator setAlpha:1];
        
        [[[CCCoreManager sharedInstance] server] startFacebookAuthenticationWithDelegate:self];
        
    }
}

// Required CCServerLoginDelegate methods

- (void)loginCompleteWithUser: (id<CCUser>) user isNewUser:(Boolean)isNewUser
{
    // Hide the loading indicator
    [facebookLoadingIndicator setAlpha:0];
    
    // Save the user
    [[[CCCoreManager sharedInstance] server] setCurrentUser:user];
    
    if(isNewUser)
    {   
    	didLaunchWelcomeView = true;
        [self loadWelcomeView];
    }
    else 
    {
        [self loadMainTabView];        
    }    
}

- (void)loginFailedWithReason: (NSString *)reason
{
    [facebookLoadingIndicator setAlpha:0];
    
    UIAlertView *alert;  
    alert = [[UIAlertView alloc] initWithTitle:@"Login Failed!" 
                                       message:reason
                                      delegate:nil 
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil];
    [alert show];
}

- (void)silentLoginCompleteWithUser: (id<CCUser>) user isNewUser:(Boolean)isNewUser
{
    // Ignore
}

- (void)silentLoginFailedWithReason: (NSString *)reason 
{
    // Ignore
}

- (void)loadMainTabView
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainTabView"];
    mainTabView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mainTabView.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:mainTabView animated:NO completion:nil];
}

- (void)loadWelcomeView
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    UIViewController *welcomeNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"welcomeNavigationController"];
    [self presentViewController:welcomeNavigationController animated:YES completion:nil];    
}




@end
