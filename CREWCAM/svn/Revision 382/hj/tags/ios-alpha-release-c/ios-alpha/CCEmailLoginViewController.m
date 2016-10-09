//
//  CCEmailLoginViewControllerViewController.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCEmailLoginViewController.h"

@interface CCEmailLoginViewController ()

@end

@implementation CCEmailLoginViewController
@synthesize emailField;
@synthesize passwordField;
@synthesize userSwitch;
@synthesize emailPasswordConfirmationField;
@synthesize loadingView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];          
    
    [[[self navigationController] navigationBar] setClipsToBounds:NO];
    [[[self navigationController] navigationBar] setOpaque:YES];   
    if ([[UIScreen mainScreen] scale] == 0x40000000)
    {        
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
        [[[self navigationController] navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    else 
    {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];        
    
    [[self emailField] setText:@""];
    [[self passwordField] setText:@""];
    [[self emailPasswordConfirmationField] setText:@""];
    
    [[self userSwitch] setSelected:NO];
}

- (IBAction)onUserSwitchPressWithSender:(id)sender 
{
    [userSwitch setSelected:![userSwitch isSelected]];
    if ([userSwitch isSelected])
    {
        passwordField.returnKeyType = UIReturnKeyGo;
        [emailPasswordConfirmationField setHidden:YES];
    }
    else 
    {
        passwordField.returnKeyType = UIReturnKeyNext;
        [emailPasswordConfirmationField setHidden:NO];
    }
}

- (IBAction)onHideKeyboadWithSender:(id)sender 
{
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    [emailPasswordConfirmationField resignFirstResponder];
}

-(IBAction)backgroundTouched:(id)sender
{
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    [emailPasswordConfirmationField resignFirstResponder];
}

- (IBAction)onLoginPressWithSender:(id)sender {
    UIAlertView *alert;  
    
    alert = [[UIAlertView alloc] initWithTitle:@"Coming Soon!" 
                                       message:@"Non-Facebook login will be supported in Crewcam's release next week!"
                                      delegate:nil 
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil];
    [alert show];
    return;
    
    [loadingView setHidden:NO];
    
    if (![userSwitch isSelected])
    {
        if([passwordField.text isEqualToString:emailPasswordConfirmationField.text])
        {
            // Try to create a new user
            [[[CCCoreManager sharedInstance] server] startEmailAuthenticationInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) 
            {
                [loadingView setHidden:YES];
                
                if (!succeeded)
                {
                    UIAlertView *alert;  
                    
                    alert = [[UIAlertView alloc] initWithTitle:@"Login Failed!" 
                                                       message:@"Unable to authenticate"
                                                      delegate:nil 
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
                    [alert show];
                }
                else 
                {
                    if ([user getIsUserNew])
                    {
                        CCUsersDetailsFormViewController *userDetailsVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"usersDetailsViewController"];
                        [[self navigationController] pushViewController:userDetailsVC animated:YES];
                    }
                    else 
                    {
                        [self loadMainTabView];
                    }
                }
                    
            } andEmail:emailField.text andPassword:passwordField.text isNewUser:YES];
        }
        else 
        {
            UIAlertView *alert;  
            
            alert = [[UIAlertView alloc] initWithTitle:@"Oops..." 
                                               message:@"Your passwords do not match"
                                              delegate:nil 
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
            [alert show];
            [loadingView setHidden:YES];
        }
        
    }
    else 
    {
        [[[CCCoreManager sharedInstance] server] startEmailAuthenticationInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) 
        {
            [loadingView setHidden:YES];
            
            if (succeeded)
            {
                [self loadMainTabView];
            }
            else 
            {
                UIAlertView *alert;  
                
                alert = [[UIAlertView alloc] initWithTitle:@"Login Failed!" 
                                                   message:@"Unable to authenticate."
                                                  delegate:nil 
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
                [alert show];
            }
            
        } andEmail:emailField.text andPassword:passwordField.text isNewUser:NO];
    }
}

- (IBAction)onFacebookButtonPressWithSender:(id)sender 
{
    // Show the loading indicator
    
    [loadingView setHidden:NO];
    
    [[CCCoreManager sharedInstance] checkNetowrkConnectivity:^(BOOL succeeded, NSError *error)
     {
         if (!succeeded)             
         {
             [loadingView setHidden:YES];
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You are not connected to an active network. Please connect and try agian. " 
                                                            delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
             [alert show];
         }    
         else 
         {
             [[[CCCoreManager sharedInstance] server] startFacebookAuthenticationInBackgroundWithForce:YES andBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) {
                 
                 [loadingView setHidden:YES];
                 
                 if (!succeeded)
                 {
                     UIAlertView *alert;  
                     
                     alert = [[UIAlertView alloc] initWithTitle:@"Login Failed!" 
                                                        message:@"Unable to authenticate with Facebook"
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
                     [alert show];
                 }
                 else
                 {
                     [self loadMainTabView];
                 }
             }];
         }
     }];
}

- (void) loadMainTabView
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainTabView"];
    mainTabView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mainTabView.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:mainTabView animated:YES];
    
    // Dismiss this view
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *) textField;
{
    NSInteger nextTag = textField.tag + 1;

    // Try to find next responder
    UIView* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder && ![nextResponder isHidden]) 
    {
        [nextResponder becomeFirstResponder];
    } else {    
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void)viewDidUnload
{
    [self setEmailPasswordConfirmationField:nil];
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setUserSwitch:nil];
    [self setEmailPasswordConfirmationField:nil];
    [self setLoadingView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
