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

- (void) onBackButtonPressed:(id) sender
{
    [[self navigationController] popViewControllerAnimated:YES];
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
    [self setFirstNameField:nil];
    [self setLastNameField:nil];
    [self setDoneButton:nil];
    [self setContentScrollView:nil];
    [self setActivityOverlay:nil];
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onDoneButtonPressed:(id)sender {
    
    [activityOverlay setHidden:NO];
    
    // Form validation, and save user's details
    [[[[CCCoreManager sharedInstance] server] currentUser] setFirstName:[firstNameField text]];
    [[[[CCCoreManager sharedInstance] server] currentUser] setLastName:[lastNameField text]];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {    
        [activityOverlay setHidden:YES];    
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
        UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainTabView"];
        mainTabView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        mainTabView.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:mainTabView animated:YES completion:^{
            [[self navigationController] popToRootViewControllerAnimated:NO];   
        }];
    }];    
}
@end
