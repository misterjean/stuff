//
//  OtherViewController.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OtherViewController.h"

@interface OtherViewController ()

@end

@implementation OtherViewController


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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)logoutButton:(id)sender {
    
    printf("Login Successful");
    [ServerApi userLogOut];  
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    LoginViewController *feedVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"firstView"];
    feedVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    feedVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:feedVC animated:NO completion:nil];
    
}
@end
