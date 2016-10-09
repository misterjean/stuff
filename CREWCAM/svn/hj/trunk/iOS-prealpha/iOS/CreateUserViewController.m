//
//  CreateUserViewController.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateUserViewController.h"

@interface CreateUserViewController ()

@end

@implementation CreateUserViewController
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

@end
