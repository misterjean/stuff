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
@synthesize detailsInfoText;


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
    
    NSString *detailsInfoString = [[[CCCoreManager sharedInstance] stringManager]
                                   getStringForKey:CC_USER_DETAILS_INFO_TEXT_KEY
                                   withDefault:@"If you don't mind giving us some contact information, we can help connect you to people you already know.  Crewcam uses this information only while creating your account."];
    
    [detailsInfoText setText:detailsInfoString];
    
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
    [[[CCCoreManager sharedInstance] server] logOutCurrentUserInBackground];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setPhoneNumberField:nil];
    [self setEmailAddressField:nil];
    [self setLoadingOverlay:nil];
    [self setContentScrollView:nil];
    [self setNextButton:nil];
    [self setDetailsInfoText:nil];
    
    [super viewDidUnload];
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

- (IBAction)onDoneButtonPressed:(id)sender 
{    
    [loadingOverlay setHidden:NO];
    
    [self hideKeyboard:nil];
    
    id<CCUser> currentUser = [[[CCCoreManager sharedInstance] server] currentUser];
            
    if (![[phoneNumberField text] isEqualToString:@""] && [phoneNumberField text] != nil)
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
    
    if (![[emailAddressField text] isEqualToString:@""] && [emailAddressField text] != nil)
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
            
            [currentUser deleteUser];
            [[[CCCoreManager sharedInstance] server] logOutCurrentUserInBackground];
            [[self navigationController] popViewControllerAnimated:YES];
            return;
        }
        

        // If the user isn't active, and we're not open access we can't allow them to login.
        if (![currentUser isUserActive] && ![[[CCCoreManager sharedInstance] server] globalSettings].isOpenAccess)
        {
            UIAlertView *alert;  
            
            NSString *noInviteTitle = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_NO_INVITE_ALERT_TITLE_KEY
                                                                                          withDefault:NSLocalizedStringFromTable(@"NO_INVITE_ALERT_TITLE", @"Localizable", nil)];
            NSString *noInviteMessage = [[[CCCoreManager sharedInstance] stringManager] getStringForKey:CC_NO_INVITE_ALERT_MESSAGE_KEY
                                                                                          withDefault:NSLocalizedStringFromTable(@"NO_INVITE_ALERT_MESSAGE", @"Localizable", nil)];
            alert = [[UIAlertView alloc] initWithTitle:noInviteTitle 
                                               message:noInviteMessage
                                              delegate:self 
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:@"Request Invite",nil];
            
            alert.tag = ccNoInviteAlert;
            
            [alert show];
            return;
        }
        
        // Otherwise we can go ahead and give the user the next page
        CCUsersDetailsFormViewController *userDetailsVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"usersNameView"];
        
        [[self navigationController] pushViewController:userDetailsVC animated:YES];  
        
        [loadingOverlay setHidden:YES];
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch ([alertView tag]) {           
        case ccNoInviteAlert:
        {
            if (buttonIndex == 1)
            {
                //Requested invite
                PFObject *requestInvite = [PFObject objectWithClassName:@"InviteRequest"];
                
                [requestInvite setObject:[[[[CCCoreManager sharedInstance] server] currentUser] getFacebookID] forKey:@"facebookId"];
                [requestInvite setObject:[[[[CCCoreManager sharedInstance] server] currentUser] getFirstName] forKey:@"firstName"];
                [requestInvite setObject:[[[[CCCoreManager sharedInstance] server] currentUser] getLastName] forKey:@"lastName"];
                [requestInvite setObject:[[[[CCCoreManager sharedInstance] server] currentUser] getEmailAddress] forKey:@"email"];
                [requestInvite setObject:[[[[CCCoreManager sharedInstance] server] currentUser] getPhoneNumber] forKey:@"phoneNumber"];
                [requestInvite saveEventually];
            }
            
            [[[[CCCoreManager sharedInstance] server] currentUser] deleteUserInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) 
                {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed to delete account. Error %@", [error description]];
                }
                
                [[[CCCoreManager sharedInstance] server] logOutCurrentUserInBackground];
            }];
            [[self navigationController] popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
    
    
    return;
    
}

- (IBAction)hideKeyboard:(id)sender {
    [phoneNumberField resignFirstResponder];
    [emailAddressField resignFirstResponder];
}

@end