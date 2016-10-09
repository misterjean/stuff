//
//  CCNameViewController.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNameViewController.h"

@interface CCNameViewController ()

@end

@implementation CCNameViewController
@synthesize doneButton;
@synthesize contentScrollView;
@synthesize activityOverlay;
@synthesize lastNameField;
@synthesize firstNameField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id<CCUser> thisUser = [[[CCCoreManager sharedInstance] server] currentUser];
    
    [firstNameField setText:[thisUser getFirstName]];
    [lastNameField setText:[thisUser getLastName]];
    
    // Add keyboard handlers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //Add back button
    [[self view] addLeftNavigationButtonFromFileNamed:@"BTN_Back" target:self action:@selector(onBackButtonPressed:)];
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
    if (!CGRectContainsPoint(aRect, doneButton.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, doneButton.frame.origin.y + doneButton.frame.size.height - (keyboardSize.height - 17));
        [contentScrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {    
    // Scroll back to 0/0
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    [contentScrollView setContentOffset:scrollPoint animated:YES];
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
    
    [self setFirstNameField:nil];
    [self setLastNameField:nil];
    [self setDoneButton:nil];
    [self setContentScrollView:nil];
    [self setActivityOverlay:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onDoneButtonPressed:(id)sender {
    
    if ([[firstNameField text] isEqualToString:@""] || [firstNameField text] == nil)
    {
        CCCrewcamAlertView *alert;
        
        alert = [[CCCrewcamAlertView alloc] initWithTitle:@"First name...?"
                                                  message:@"You do have a first name, don't you?"
                                            withTextField:NO
                                                 delegate:nil
                                        cancelButtonTitle:@"Yup"
                                        otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if ([[lastNameField text] isEqualToString:@""] || [lastNameField text] == nil)
    {
        CCCrewcamAlertView *alert;
        
        alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Last name...?"
                                                  message:@"You do have a last name, don't you?"
                                            withTextField:NO
                                                 delegate:nil
                                        cancelButtonTitle:@"Yup"
                                        otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [activityOverlay setHidden:NO];
    
    // Form validation, and save user's details
    [[[[CCCoreManager sharedInstance] server] currentUser] setFirstName:[firstNameField text]];
    [[[[CCCoreManager sharedInstance] server] currentUser] setLastName:[lastNameField text]];
    
    CCUserPictureViewController *userPPView = [[self storyboard] instantiateViewControllerWithIdentifier:@"profilePictureView"];
    
    [userPPView setNewUserProcess:YES];
    
    [[self navigationController] pushViewController:userPPView animated:YES];
    
}
@end
