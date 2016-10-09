//
//  CCUnlinkFBEmailViewController.m
//  Crewcam
//
//  Created by Desmond McNamee on 12-07-31.
//
//

#import "CCUnlinkFBEmailViewController.h"

@interface CCUnlinkFBEmailViewController ()

@end

@implementation CCUnlinkFBEmailViewController
@synthesize scrollView;
@synthesize passwordTextField;
@synthesize submitButton;
@synthesize confirmPasswordTextField;
@synthesize textBlockOutlet;
@synthesize textForTextBlock;
@synthesize loadingView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    if (textForTextBlock != nil)
    {
        [textBlockOutlet setText:textForTextBlock];
    }
}

- (void)viewDidUnload
{
    [self setPasswordTextField:nil];
    [self setConfirmPasswordTextField:nil];
    [self setPasswordTextField:nil];
    [self setScrollView:nil];
    [self setSubmitButton:nil];
    [self setTextBlockOutlet:nil];
    [self setLoadingView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, submitButton.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, submitButton.frame.origin.y + submitButton.frame.size.height - (keyboardSize.height));
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    // Scroll back to 0/0
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    [scrollView setContentOffset:scrollPoint animated:YES];
}

- (IBAction)hideKeyboard:(id)sender
{
    [passwordTextField resignFirstResponder];
    [confirmPasswordTextField resignFirstResponder];
}

- (IBAction)onSubmitButtonPress:(id)sender
{
    [passwordTextField resignFirstResponder];
    [confirmPasswordTextField resignFirstResponder];
    
    if ([[passwordTextField text] isEqualToString:[confirmPasswordTextField text]] && ![[passwordTextField text] isEqualToString:@""])
    {
        [loadingView setHidden:NO];
        [[[CCCoreManager sharedInstance] server] changeUsernameAndPasswordWithEmail:[[[[CCCoreManager sharedInstance] server] currentUser] getEmailAddress] password:[confirmPasswordTextField text] block:^(BOOL succeeded, NSError *error) {
#warning Handle errors
            [loadingView setHidden:YES];
            [self loadMainTabView];
        }];
    }
    else
    {
        CCCrewcamAlertView *updateAlert = [[CCCrewcamAlertView alloc] initWithTitle: NSLocalizedStringFromTable(@"ERROR", @"Localizable", nil)
                                                                            message: NSLocalizedStringFromTable(@"NEW_PASSWORD_ERROR", @"Localizable", nil)
                                                                      withTextField: NO
                                                                           delegate: nil
                                                                  cancelButtonTitle: @"Ok"
                                                                  otherButtonTitles: nil];
        [updateAlert show];
    }
}

- (void)loadMainTabView
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
