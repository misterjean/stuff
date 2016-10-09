//
//  CCEmailLoginViewControllerViewController.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLoginViewController.h"

@interface CCLoginViewController ()

@end

@implementation CCLoginViewController
@synthesize usernameField;
@synthesize passwordField;
@synthesize userSwitch;
@synthesize emailPasswordConfirmationField;
@synthesize loginButton;
@synthesize promoCode;
@synthesize mainScrollView;
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
    
    didStartFacebookAuthentication = NO;
    
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
    
    // Add keyboard handlers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReturnFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
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
                [loadingView setHidden:YES];
             });
        });
    }
}
     
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    [[CCCoreManager sharedInstance] checkNetworkConnectivity:^(BOOL succeeded, NSError *error)
     {
         if (!succeeded) 
         {
             [loadingView setHidden:YES];
         }
         else 
         {
             didStartFacebookAuthentication = YES;
             [[[CCCoreManager sharedInstance] server] startFacebookAuthenticationInBackgroundWithForce:NO andBlock:^(id<CCUser> user, BOOL succeeded, NSError *error)
              {
                  didStartFacebookAuthentication = NO;
                  if (!succeeded || ![user isUserActive])
                  {
                      [loadingView setHidden:YES];
                  }
                  else 
                  {
                      [self loadMainTabView];
                  }
              }];
         }
     }];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    mainScrollView.contentInset = contentInsets;
    mainScrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, loginButton.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, loginButton.frame.origin.y + loginButton.frame.size.height - (keyboardSize.height - 17));
        [mainScrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {    
    // Scroll back to 0/0
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    [mainScrollView setContentOffset:scrollPoint animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];        
    
    [[self usernameField] setText:@""];
    [[self passwordField] setText:@""];
    [[self emailPasswordConfirmationField] setText:@""];
    
    [[self userSwitch] setSelected:NO];
    [emailPasswordConfirmationField setHidden:NO];    
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

- (IBAction)hideKeyboardWithSender:(id)sender 
{
    [promoCode resignFirstResponder];
}

-(IBAction)backgroundTouched:(id)sender
{
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    [emailPasswordConfirmationField resignFirstResponder];
}

- (void) handleSuccesfullLoginCompletionForUser:(id<CCUser>) user
{
    // Check for global lockdown
    if ([[[CCCoreManager sharedInstance] server] globalSettings].isInLockdown && ![user isUserDeveloper])
    {
        UIAlertView *alert;  
        
        alert = [[UIAlertView alloc] initWithTitle:@"Lockdown!" 
                                           message:@"Sadly, Crewcam is in a temporary lockdown.  Please try again later."
                                          delegate:nil 
                                 cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
        [alert show];
        
        if (![user isUserActive])
            [user deleteUser];
        
        [user logOutUserInBackground];
        return;
    }
    
    // Determine which view to load
    if ([user getIsUserNew] || ![user isUserActive])
    {
        // Logout the user to clean things up
        [self loadUsersDetailsView];
    }
    else 
    {
        [self loadMainTabView];
    }
}

- (IBAction)onLoginPressWithSender:(id)sender {    
    [loadingView setHidden:NO];
    [self hideKeyboardWithSender:nil];
    
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
                    [self handleSuccesfullLoginCompletionForUser:user];
                }
                    
            } andEmail:usernameField.text andPassword:passwordField.text isNewUser:YES];
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
            
            if (!succeeded)
            {
                UIAlertView *alert;  
                
                alert = [[UIAlertView alloc] initWithTitle:@"Login Failed!" 
                                                   message:@"Unable to authenticate."
                                                  delegate:nil 
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
                [alert show];
                
                return;
            }
            
            [self handleSuccesfullLoginCompletionForUser:user];
            
        } andEmail:usernameField.text andPassword:passwordField.text isNewUser:NO];
    }
}

- (IBAction)onFacebookButtonPressWithSender:(id)sender 
{
    if (didStartFacebookAuthentication)
        return;
    
    [[[CCCoreManager sharedInstance] server] loadDatabaseKeysInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error){
        
        if (![[promoCode text] isEqualToString:@""])
        {
            [[[CCCoreManager sharedInstance] server] setDatabaseForCode:[promoCode text]];
        }        
        
        [[CCCoreManager sharedInstance] checkNetworkConnectivity:^(BOOL succeeded, NSError *error)
         {
             if (!succeeded)             
             {
                 [loadingView setHidden:YES];
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"NO_INTERNET_ALERT_TITLE", @"Localizable", nil)
                                                                 message:NSLocalizedStringFromTable(@"NO_INTERNET_ALERT_TEXT", @"Localizable", nil)
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
                 [alert show];
             }    
             else 
             {
                 [loadingView setHidden:NO];
                 
                 didStartFacebookAuthentication = YES;
                 [[[CCCoreManager sharedInstance] server] startFacebookAuthenticationInBackgroundWithForce:YES andBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) {
                     didStartFacebookAuthentication = NO;
                     [loadingView setHidden:YES];
                     
                     if (!succeeded)
                     {
                         UIAlertView *alert;  
                         
                         alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"LOGIN_FAILED_TITLE", @"Localizable", nil) 
                                                            message:NSLocalizedStringFromTable(@"CANT_FB_CONNECT", @"Localizable", nil)
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
                         [alert show];
                     }
                     else
                     {
                         [self handleSuccesfullLoginCompletionForUser:user];
                     }
                 }];
             }
         }];
        
    }];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [self setUserSwitch:nil];
    [self setEmailPasswordConfirmationField:nil];
    [self setLoadingView:nil];
    [self setMainScrollView:nil];
    [self setLoginButton:nil];    
    [self setPromoCode:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
