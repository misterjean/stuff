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
@synthesize emailLoginButton;
@synthesize facebookLoginButton;
@synthesize promoCode;
@synthesize mainScrollView;
@synthesize loadingView;

- (void) viewDidLoad
{
    [super viewDidLoad];          
    
    didStartFacebookAuthentication = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden: NO animated:YES];
    
    // Add keyboard handlers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [emailLoginButton setFont:[UIFont getSteelfishFontForSize:30]];
    [facebookLoginButton setFont:[UIFont getSteelfishFontForSize:30]];
}
    
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *customDatabaseLabelString = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_CUSTOM_DATABASE_FIELD_LABEL_KEY withDefault:@"Promo Code"];
    
    [promoCode setPlaceholder:customDatabaseLabelString];            
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
    if (!CGRectContainsPoint(aRect, promoCode.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, promoCode.frame.origin.y + promoCode.frame.size.height - (keyboardSize.height - 17));
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
 
}

- (IBAction)hideKeyboardWithSender:(id)sender 
{
    [promoCode resignFirstResponder];
}

- (void) handleSuccesfullLoginCompletionForUser:(id<CCUser>) user
{
    // Check for global lockdown
    if ([[[CCCoreManager sharedInstance] server] globalSettings].isInLockdown && ![user isUserDeveloper])
    {
        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Lockdown!"
                                                                      message:@"Sadly, Crewcam is in a temporary lockdown.  Please try again later."
                                                                withTextField:NO
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

- (IBAction)onFacebookButtonPressWithSender:(id)sender 
{
    if (didStartFacebookAuthentication)
        return;
     
    [PFUser logOut];
    
    [loadingView setHidden:NO];
    
    [[CCCoreManager sharedInstance] checkNetworkConnectivity:^(BOOL succeeded, NSError *error)
     {
         if (!succeeded)             
         {
             [loadingView setHidden:YES];
             
             CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"NO_INTERNET_ALERT_TITLE", @"Localizable", nil)
                                                                           message:NSLocalizedStringFromTable(@"NO_INTERNET_ALERT_TEXT", @"Localizable", nil)
                                                                     withTextField:NO
                                                                          delegate:self
                                                                 cancelButtonTitle:@"Ok"
                                                                 otherButtonTitles:nil];
             [alert show];
         }    
         else 
         {

             [[[CCCoreManager sharedInstance] server] performPreloginTasksWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                 if (succeeded)
                 {
                     didStartFacebookAuthentication = YES;
                     [[[CCCoreManager sharedInstance] server] startFacebookAuthenticationInBackgroundWithForce:YES andBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) {
                         didStartFacebookAuthentication = NO;
                         
                         [loadingView setHidden:YES];
                         
                         if (!succeeded)
                         {
                             if (user != nil)
                             {
                                 failedLoginUser = user;
                             }
                             
                             [self handleFailedLoginWithType:[error code]];                             
                         }
                         else
                         {
                             [self handleSuccesfullLoginCompletionForUser:user];
                         }
                     }];
                 }
                 else
                 {
                     [loadingView setHidden:YES];
                 }
             } promoText:promoCode.text];
             
         }
     }];
}

- (IBAction)onFacebookQuestionPress:(id)sender
{
    
    CCCrewcamAlertView *alert= [[CCCrewcamAlertView alloc] initWithTitle:@"Help" message:@"Logging in with Facebook will help Crewcam connect you with friends who already have the app. Unlike some apps, WE WON'T do anything malicious like posting on your wall without asking first." withTextField:NO  delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    
    [alert show];
}

- (void)handleFailedLoginWithType:(ccFacebookLoginErrorCodes)failureType
{
    NSString *messageString;
    NSString *titleString;
    CCCrewcamAlertView *alert;
    
    switch (failureType) {
        case ccGeneralFacebookLoginError:
            messageString = NSLocalizedStringFromTable(@"CANT_FB_CONNECT", @"Localizable", nil);
            titleString = NSLocalizedStringFromTable(@"LOGIN_FAILED_TITLE", @"Localizable", nil);
            alert = [[CCCrewcamAlertView alloc] initWithTitle:titleString
                                               message:messageString
                                                withTextField:NO
                                              delegate:self
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
            [alert setTag:ccGeneralFacebookLoginErrorAlert];
            break;
        case ccEmailAccountAlreadyExistsForAccount:
            messageString = NSLocalizedStringFromTable(@"EXISTING_EMAIL_ACCOUNT_WITH_EMAIL", @"Localizable", nil);
            titleString = NSLocalizedStringFromTable(@"LOGIN_FAILED_TITLE", @"Localizable", nil);
            alert = [[CCCrewcamAlertView alloc] initWithTitle:titleString
                                               message:messageString
                                                withTextField:NO                     
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"Login and Link", nil];
            [alert setTag:ccEmailAccountAlreadyExistsForAccountAlert];
            [[[CCCoreManager sharedInstance] server] deleteCurrentUserWithBlock:nil];
            break;
        case ccMoreThenOneAccountWithSameEmail:
            messageString = NSLocalizedStringFromTable(@"CANT_FB_CONNECT", @"Localizable", nil);
            titleString = NSLocalizedStringFromTable(@"LOGIN_FAILED_TITLE", @"Localizable", nil);
            alert = [[CCCrewcamAlertView alloc] initWithTitle:titleString
                                               message:messageString
                                                withTextField:NO
                                              delegate:self
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
            [alert setTag:ccMoreThenOneAccountWithSameEmailAlert];
            [[[CCCoreManager sharedInstance] server] deleteCurrentUserWithBlock:nil];            
            break;
        default:
            return;
    }

    [alert show];
}

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag]) {
        case ccGeneralFacebookLoginErrorAlert:
            //Maybe do nothing?
            break;
        case ccEmailAccountAlreadyExistsForAccountAlert:
        {
            if (buttonIndex == 1)
            {
                //Login and Link Pressed
                UINavigationController *navController = [self navigationController];
                
                [navController popToRootViewControllerAnimated:NO];
                
                CCEmailLoginViewController *emailLoginView = [[self storyboard] instantiateViewControllerWithIdentifier:@"emailLoginVC"];
                
                [emailLoginView setAutoLinkAfterLogin:YES];
                [emailLoginView setAutoEmailText:[failedLoginUser getEmailAddress]];
                [[emailLoginView emailField] setEnabled:NO];
                
                [navController pushViewController:emailLoginView animated:YES];
            }
            else
            {
                //cancel
            }

            break;
        }
        case ccMoreThenOneAccountWithSameEmailAlert:
            //maybe do nothing?
            break;
        default:
            break;
    }
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
    [self presentModalViewController:mainTabView animated:YES];    
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

    [self setLoadingView:nil];
    [self setMainScrollView:nil];
    [self setPromoCode:nil];
    [self setEmailLoginButton:nil];
    [self setFacebookLoginButton:nil];
    [super viewDidUnload];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end