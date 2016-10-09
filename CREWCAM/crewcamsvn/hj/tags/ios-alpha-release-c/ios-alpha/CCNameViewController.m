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
}

- (void) onBackButtonPressed:(id) sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setFirstNameField:nil];
    [self setLastNameField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onDoneButtonPressed:(id)sender {
    
    // Form validation, and save user's details
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
    UIViewController *mainTabView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainTabView"];
    mainTabView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mainTabView.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:mainTabView animated:YES completion:^{
        [[self navigationController] popToRootViewControllerAnimated:NO];   
    }];
    
}
@end
