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
@synthesize loggingInIndicator;
@synthesize emailPasswordConfirmationField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)onUserSwitchPressWithSender:(id)sender 
{
    if ([userSwitch isOn])
    {
        [emailPasswordConfirmationField setAlpha:1];
    }
    else 
    {
        [emailPasswordConfirmationField setAlpha:0];
    }
}

- (IBAction)onHideKeyboadWithSender:(id)sender 
{
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailPasswordConfirmationField resignFirstResponder];
}

- (IBAction)onLoginPressWithSender:(id)sender {
    [loggingInIndicator setAlpha:1];
    if ([userSwitch isOn])
    {
        if(![passwordField.text compare:emailPasswordConfirmationField.text])
        {
            [[[CCCoreManager sharedInstance] server] startEmailAuthenticationWithDelegate:self email:emailField.text password:passwordField.text isNewUser:YES];
        }
        else 
        {
            //passwords didn't match try again.
        }
        
    }
    else 
    {
        [[[CCCoreManager sharedInstance] server] startEmailAuthenticationWithDelegate:self email:emailField.text password:passwordField.text isNewUser:NO];
    }
}

- (IBAction)onBackButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEmailPasswordConfirmationField:nil];
    [self setLoggingInIndicator:nil];
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setUserSwitch:nil];
    [self setEmailPasswordConfirmationField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// CCServerLoginDelegate required Method

- (void)loginCompleteWithUser: (id<CCUser>) user isNewUser:(Boolean)isNewUser
{
    
}

- (void)loginFailedWithReason: (NSString *)reason
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:reason, nil];    
}

- (void)silentLoginCompleteWithUser: (id<CCUser>) user isNewUser:(Boolean)isNewUser
{
    
}

- (void)silentLoginFailedWithReason: (NSString *)reason
{
    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelWarning message:reason, nil];
}

@end
