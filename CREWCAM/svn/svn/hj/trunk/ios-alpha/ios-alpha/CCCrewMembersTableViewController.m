//
//  CCCrewMembersTableViewController.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-05-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewMembersTableViewController.h"

@interface CCCrewMembersTableViewController ()

@end

@implementation CCCrewMembersTableViewController
@synthesize totalMembersLabel;
@synthesize members;
@synthesize viewHeaderText;
@synthesize totalText;
@synthesize viewNavigationHeader;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    totalMembersLabel.text = [[NSString alloc] initWithFormat:@"%@: %d", totalText, [members count]];
    viewNavigationHeader.title = [[NSString alloc] initWithFormat:@"%@: %d", viewHeaderText];
}

- (void)viewDidUnload
{
    [self setTotalMembersLabel:nil];
    [self setMembers:nil];
    [self setViewNavigationHeader:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [members count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MemberCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [[members objectAtIndex:[indexPath row]] name];
    
    if ([[members objectAtIndex:[indexPath row]] userImageData])
    {
        [[cell imageView] setImage:[UIImage imageWithData:[[members objectAtIndex:[indexPath row]] userImageData]]];
        [cell imageView].contentScaleFactor = [[UIScreen mainScreen] scale];

    }
    else 
    {
        [[cell imageView] setImage:[UIImage imageNamed:@"default-user.png"]];
    }
    
    return cell;
}


@end
