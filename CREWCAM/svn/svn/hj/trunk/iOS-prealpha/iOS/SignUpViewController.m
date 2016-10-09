//
//  SignUpViewController.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"


@interface SignUpViewController ()

@end

@implementation SignUpViewController
@synthesize userNameField;
@synthesize password1Field;
@synthesize password2Field;

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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setUserNameField:nil];
    [self setPassword2Field:nil];
    [self setPassword1Field:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)submitButton:(id)sender {
    
    if([ServerApi createUser:self.userNameField.text :self.password1Field.text :self.password2Field.text] ==  0)
    {
        printf("User Created");
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signup Failed" 
                                                        message:@"You Idiot!! The user already exists." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        printf("Failed to signup");
    }
}

- (IBAction)hideKeyboard:(id)sender {
    [self.userNameField resignFirstResponder];
    [self.password1Field resignFirstResponder];
    [self.password2Field resignFirstResponder];
}
@end
