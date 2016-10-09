//
//  CCUsersDetailsFormViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCUsersDetailsFormViewController.h"

@interface CCUsersDetailsFormViewController ()

@end

@implementation CCUsersDetailsFormViewController
@synthesize phoneNumberField;
@synthesize emailAddressField;
@synthesize loadingOverlay;
@synthesize contentScrollView;
@synthesize nextButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationItem] setLeftBarButtonItem:[UIBarButtonItem barItemWithImageName:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)]];
    
    [phoneNumberField setText:[[[[CCCoreManager sharedInstance] server] currentUser] getPhoneNumber]];
    [emailAddressField setText:[[[[CCCoreManager sharedInstance] server] currentUser] getEmailAddress]];    
    
    // Add keyboard handlers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    contentScrollView.contentInset = contentInsets;
    contentScrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, nextButton.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, nextButton.frame.origin.y + nextButton.frame.size.height - (keyboardSize.height - 17));
        [contentScrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {    
    // Scroll back to 0/0
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    [contentScrollView setContentOffset:scrollPoint animated:YES];
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

- (void) onBackButtonPressed:(id) sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setPhoneNumberField:nil];
    [self setEmailAddressField:nil];
    [self setLoadingOverlay:nil];
    [self setContentScrollView:nil];
    [self setNextButton:nil];
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL) checkemailAddress
{
    
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:[emailAddressField text]];

}

/* Only use if we change the keyboard type to include symbols
- (NSString *) convertPhoneNumber
{
    NSCharacterSet *nondecimalSet = [[ NSCharacterSet decimalDigitCharacterSet ] invertedSet ];
    NSString *decimalDigitString =  [[[phoneNumberField text] componentsSeparatedByCharactersInSet:nondecimalSet] componentsJoinedByString:@""];
    
    return decimalDigitString;
}
*/
- (IBAction)onDoneButtonPressed:(id)sender 
{    
    [loadingOverlay setHidden:NO];
    
    [self hideKeyboard:nil];
    
    id<CCUser> currentUser = [[[CCCoreManager sharedInstance] server] currentUser];
            
    if (![[phoneNumberField text] isEqualToString:@""])
    {
        if ([[phoneNumberField text] length] == 10)
            [currentUser setPhoneNumber:[phoneNumberField text]];
        else 
        {
            UIAlertView *alert;  
            
            alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                               message:@"Please Enter A 10 Digit Phone Number"
                                              delegate:nil 
                                     cancelButtonTitle:@"Close"
                                     otherButtonTitles:nil];
            [alert show];
            [loadingOverlay setHidden:YES];
            return;
        }
    }
    
    if (![[emailAddressField text] isEqualToString:@""])
    {
        if ([self checkemailAddress])
            [currentUser setEmailAddress:[emailAddressField text]];
        else 
        {
            UIAlertView *alert;  
            
            alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                               message:@"Invalid Email"
                                              delegate:nil 
                                     cancelButtonTitle:@"Close"
                                     otherButtonTitles:nil];
            [alert show];
            [loadingOverlay setHidden:YES];
            return;
        }
    }
    
    [[[[CCCoreManager sharedInstance] server] authenticator] tryToActivateNewUser:currentUser withBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            UIAlertView *alert;  
            
            alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                               message:[error localizedDescription]
                                              delegate:nil 
                                     cancelButtonTitle:@"Darn"
                                     otherButtonTitles:nil];
            [alert show];
            
            [currentUser logOutUserInBackground];
            [[self navigationController] popViewControllerAnimated:YES];
            return;
        }
        
        // If the user isn't active, and we're not open access we can't allow them to login.
        if (![currentUser isUserActive] && ![[[CCCoreManager sharedInstance] server] globalSettings].isOpenAccess)
        {
            UIAlertView *alert;  
            
            alert = [[UIAlertView alloc] initWithTitle:@"No invite!" 
                                               message:@"Crewcam is currently only available to new users via invitations.  Ask one of your friends to invite you and we'll be able to give you access!"
                                              delegate:nil 
                                     cancelButtonTitle:@"Aw..."
                                     otherButtonTitles:nil];
            [alert show];
            
            [currentUser logOutUserInBackground];
            [[self navigationController] popViewControllerAnimated:YES];
            return;
        }
        
        // Otherwise we can go ahead and give the user the next page
        CCUsersDetailsFormViewController *userDetailsVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"usersNameView"];
        
        [[self navigationController] pushViewController:userDetailsVC animated:YES];  
        
        [loadingOverlay setHidden:YES];
        
    }];
}

- (IBAction)hideKeyboard:(id)sender {
    [phoneNumberField resignFirstResponder];
    [emailAddressField resignFirstResponder];
}

@end
