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
}

- (void) onBackButtonPressed:(id) sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setPhoneNumberField:nil];
    [self setEmailAddressField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onDoneButtonPressed:(id)sender 
{    
    [[[[CCCoreManager sharedInstance] server] currentUser] setPhoneNumber:[phoneNumberField text]];
    [[[[CCCoreManager sharedInstance] server] currentUser] setEmailAddress:[emailAddressField text]];
    CCUsersDetailsFormViewController *userDetailsVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"usersNameView"];

    [[self navigationController] pushViewController:userDetailsVC animated:YES];
}

@end
