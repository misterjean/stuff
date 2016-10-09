//
//  LoginViewController.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize userNameField;
@synthesize passwordField;

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
    [self setPasswordField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)authenticateWithFacebook:(id)sender 
{
    if (![[PFFacebookUtils facebook] isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_about_me",
                                @"user_likes", 
                                @"read_stream",
                                nil];
        [[PFFacebookUtils facebook] authorize:permissions];
    }
    
    // Use the Graph API to get the user's ID, and then authenticate with Parse's backend
    [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];    
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary* hash = result;
        
        [PFFacebookUtils logInWithFacebookId:[hash valueForKey:@"id"] accessToken:[[PFFacebookUtils facebook] accessToken] expirationDate:[[PFFacebookUtils facebook] expirationDate] block:^(PFUser *user, NSError *error)
         {
             if (!user) {
                 NSLog(@"Uh oh. The user cancelled the Facebook login.");
             } else {
                 if (user.isNew)
                 {
                     // Read the user's name and contact information to save in the Parse backend so we know what it is in the future!
                     NSLog(@"User signed up and logged in through Facebook!");
                 }
                 else
                 {
                     NSLog(@"User logged in through Facebook!");
                 }
                 
                 [self loadMainStoryboard];
             }
         }];                
        
        NSString *username = (NSString*)[hash valueForKey:@"name"];
        
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"Username"];
    }
};

- (void)loadMainStoryboard {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    FeedTableViewController *feedVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"feedView"];
    feedVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    feedVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:feedVC animated:NO completion:nil];
}

- (IBAction)submitButton:(id)sender {
    @try {
        if([ServerApi userLogin:self.userNameField.text :self.passwordField.text] == 0)
        {
            printf("Login Successful");
            [self loadMainStoryboard];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" 
                                                            message:@"You Idiot!!" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            printf("\nFailed to login");
        }
    }
    @catch (NSException *exception) {
        [ServerApi userLogOut];
        NSLog(@"Exception: %@, Reason: %@", exception.name, exception.reason);
    }
    
}

- (IBAction)hideKeyboard:(id)sender {
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
@end
