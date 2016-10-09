//
//  CCEmailLoginViewController.m
//  Crewcam
//
//  Created by Desmond McNamee on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCEmailLoginViewController.h"

@interface CCEmailLoginViewController ()

@end

@implementation CCEmailLoginViewController
@synthesize emailField;
@synthesize passwordField;
@synthesize confirmPasswordField;
@synthesize passwordConfirmBuble;
@synthesize mainScrollView;
@synthesize confirmButton;
@synthesize activityIndicatorView;
@synthesize customUserSwitchOutlet;
@synthesize textNewUserLabel;
@synthesize customUserSwitchState;
@synthesize autoEmailText;
@synthesize forgotPasswordButton;
@synthesize autoLinkAfterLogin;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Add keyboard handlers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    customUserSwitchState = NO;
    
    [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    BOOL willHideStuff;
    if(autoEmailText != nil)
    {
        [emailField setText:autoEmailText];
    }
    if (autoLinkAfterLogin)
    {
        willHideStuff = YES;
    }
    else
    {
        willHideStuff = NO;
    }
    [[self customUserSwitchOutlet] setHidden:willHideStuff];
    [[self textNewUserLabel] setHidden:willHideStuff];
    [[self forgotPasswordButton] setHidden:willHideStuff];
}

- (void)viewDidUnload
{
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setConfirmPasswordField:nil];
    [self setMainScrollView:nil];
    [self setConfirmButton:nil];
    [self setActivityIndicatorView:nil];
    [self setCustomUserSwitchOutlet:nil];
    [self setTextNewUserLabel:nil];
    [self setForgotPasswordButton:nil];
    [self setPasswordConfirmBuble:nil];
    [self setAutoEmailText:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onSubmitButtonPress:(id)sender
{
    if (![self validateEmail:emailField.text])
    {
        [self displayFailedLoginMessageWithType:ccInvalidEmail];
        return;
    }
    if ([passwordField.text length] == 0)
    {
        [self displayFailedLoginMessageWithType:ccNoPasswordEntered];
        return;
    }
    
    [activityIndicatorView setHidden:NO];

    if (customUserSwitchState == YES)
    {
        [self initiateEmailAuthentication];
    }
    else 
    {
        [[[CCCoreManager sharedInstance] server] performPreloginTasksWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            [self initiateEmailAuthentication];
        } promoText:@""];
    }
}

- (void)initiateEmailAuthentication
{
    BOOL isNewUser = customUserSwitchState; //On = True, Off = False
    
    if (isNewUser)
    {
        if (![passwordField.text isEqualToString:confirmPasswordField.text])
        {
            [self displayFailedLoginMessageWithType:ccPasswordsDontMatch];
            return;
        }
    }

    [[[CCCoreManager sharedInstance] server] startEmailAuthenticationInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) {
        if (!succeeded)
        {
            [self displayFailedLoginMessageWithType:[error code]];
        }
        else
        {
            [activityIndicatorView setHidden:YES];
            [self handleSuccesfullLoginCompletionForUser:user];
        }
    } andEmail:emailField.text andPassword:passwordField.text isNewUser:isNewUser];
}

- (void)displayFailedLoginMessageWithType:(ccFailedEmailAuthenticationErrorCodes)failureType
{
    [activityIndicatorView setHidden:YES];
    
    NSString *messageString;
    NSString *titleString;
    
    switch (failureType) {
        case ccGeneralFailure:
            messageString = NSLocalizedStringFromTable(@"CANT_EMAIL_CONNECT", @"Localizable", nil);
            titleString = NSLocalizedStringFromTable(@"LOGIN_FAILED_TITLE", @"Localizable", nil);
            break;
        case ccPasswordsDontMatch:
            messageString = NSLocalizedStringFromTable(@"PASSWORDS_DONT_MATCH", @"Localizable", nil);
            titleString = NSLocalizedStringFromTable(@"SIGN_UP_FAILED", @"Localizable", nil);
            break;
        case ccInvalidEmail:
            titleString = NSLocalizedStringFromTable(@"LOGIN_FAILED_TITLE", @"Localizable", nil);
            messageString = NSLocalizedStringFromTable(@"INVALID_EMAIL", @"Localizable", nil);
            break;
        case ccNoPasswordEntered:
            titleString = NSLocalizedStringFromTable(@"LOGIN_FAILED_TITLE", @"Localizable", nil);
            messageString = NSLocalizedStringFromTable(@"NO_PASSWORD_ENTERED", @"Localizable", nil);
            break;
        case ccEmailInUseEmailAccount:
            titleString = NSLocalizedStringFromTable(@"SIGN_UP_FAILED", @"Localizable", nil);
            messageString = NSLocalizedStringFromTable(@"EMAIL_IN_USE", @"Localizable", nil);
            break;
        case ccEmailInUseFacebookAccount:
            titleString = NSLocalizedStringFromTable(@"SIGN_UP_FAILED", @"Localizable", nil);
            messageString = NSLocalizedStringFromTable(@"EMAIL_IN_USE_FACEBOOK", @"Localizable", nil);
            break;
        case ccNoNetworkConnection:
            titleString = NSLocalizedStringFromTable(@"NO_INTERNET_ALERT_TITLE", @"Localizable", nil);
            messageString = NSLocalizedStringFromTable(@"NO_INTERNET_ALERT_TEXT", @"Localizable", nil);
            break;
        case ccEmailDoesNotExist:
            titleString = NSLocalizedStringFromTable(@"", @"Localizable", nil);
            messageString = NSLocalizedStringFromTable(@"EMAIL_DOES_NOT_EXIST", @"Localizable", nil);
            break;
        case ccPasswordRecoveryInvalidEmail:
            titleString = NSLocalizedStringFromTable(@"", @"Localizable", nil);
            messageString = NSLocalizedStringFromTable(@"INVALID_EMAIL", @"Localizable", nil);
            break;
        default:
            return;
    }
    
    CCCrewcamAlertView *alert;
    
    alert = [[CCCrewcamAlertView alloc] initWithTitle:titleString
                                              message:messageString
                                        withTextField:NO
                                             delegate:nil
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
    [alert show];
}

- (IBAction)hideKeyboard:(id)sender
{
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    [confirmPasswordField resignFirstResponder];
}

- (IBAction)onCustomNewUserSwitchPress:(id)sender
{
    if (customUserSwitchState == YES)
    {
        [customUserSwitchOutlet setImage:[UIImage imageNamed:@"BTN_No_ACT.png"] forState:UIControlStateNormal];
        [confirmPasswordField setHidden:YES];
        [passwordConfirmBuble setHidden:YES];
    }
    else
    {
        [customUserSwitchOutlet setImage:[UIImage imageNamed:@"BTN_Yes_ACT.png"] forState:UIControlStateNormal];
        [confirmPasswordField setHidden:NO];
        [passwordConfirmBuble setHidden:NO];
    }
    
    customUserSwitchState = !customUserSwitchState;
}

- (IBAction)onForgotPasswordPress:(id)sender
{
    CCCrewcamAlertView * alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Email address"
                                                                   message:@"Please enter your account email address..."
                                                             withTextField:YES
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:@"OK", nil];    
    [[alert getTextField] setText:emailField.text];

    
    [alert show];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    if (![emailField isFirstResponder] && ![passwordField isFirstResponder] && ![confirmPasswordField isFirstResponder])
        return;
        
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    mainScrollView.contentInset = contentInsets;
    mainScrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, confirmButton.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, confirmButton.frame.origin.y + confirmButton.frame.size.height - (keyboardSize.height - 17));
        [mainScrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {    
    // Scroll back to 0/0
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    [mainScrollView setContentOffset:scrollPoint animated:YES];
}

- (void) handleSuccesfullLoginCompletionForUser:(id<CCUser>) user
{
    [activityIndicatorView setHidden:YES];
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
        if(autoLinkAfterLogin)
        {
            [[[CCCoreManager sharedInstance] server] linkCurrentUserToFacebookInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                if(!succeeded)
                {
                    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"LINK_FB_ERROR_TITLE"
                                                                                  message:@"LINK_FAILED_LOGIN_WORKED"
                                                                            withTextField:NO
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                    [alert show];
                }
                
                [self loadMainTabView];
            }];
        }
        else
        {
            [self loadMainTabView];
        }
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
    [self presentViewController:mainTabView animated:YES completion:^{
        // Dismiss this view
        [[self navigationController] popViewControllerAnimated:NO];
    }];
}

//UIScrollViewDelegate Function
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(customUserSwitchState == NO)
    {
        customUserSwitchState = YES;
        [confirmPasswordField setHidden:NO];
    }
    else
    {
        customUserSwitchState = NO;
    }
}

- (BOOL) validateEmail: (NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:candidate];
}

- (IBAction) onBackButtonPressed:(id)sender
{
    if (self == [[[self navigationController] viewControllers] objectAtIndex:0])
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        if (![self validateEmail:[[alertView getTextField] text]])
        {
            [self displayFailedLoginMessageWithType:ccPasswordRecoveryInvalidEmail];
        }
        else
        {
            [[[CCCoreManager sharedInstance] server] doesUserExistWithEmail:[[alertView getTextField] text] block:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    [[[CCCoreManager sharedInstance] server] sendPasswordRecoveryEmailWithEmail:[[alertView getTextField] text]];
                    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Success!"
                                                                                  message:@"Verification Email Sent."
                                                                            withTextField:NO
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                    [alert show];
                }
                else if(!succeeded && !error)
                {
                    [self displayFailedLoginMessageWithType:ccEmailDoesNotExist];
                }
                else
                {
                
                }
            }];
            
        }
    }
}


@end
