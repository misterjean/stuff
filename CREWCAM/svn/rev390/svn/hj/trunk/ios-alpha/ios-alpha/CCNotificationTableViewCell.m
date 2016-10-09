//
//  CCNotificationTableViewCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNotificationTableViewCell.h"

@implementation CCNotificationTableViewCell
@synthesize notificationMessageLabel;
@synthesize timeSinceLabel;
@synthesize viewDetailsButton; 
@synthesize viewForBackground;

- (void) dealloc
{
    notificationForCell = nil;
    parentViewController = nil;
    
    [self setNotificationMessageLabel:nil];
    [self setTimeSinceLabel:nil];
    [self setViewDetailsButton:nil];
    [self setViewForBackground:nil];
}

+ (CCNotificationTableViewCell *) createNotificationCellForNotification:(id<CCNotification>) notification forTable:(UITableView *) table andViewController:(CCNotificationsViewController *) viewController
{
    NSString *cellIdentifier = @"notificationCell";
    
    CCNotificationTableViewCell *cell = [table dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[CCNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Do type-specific things
    switch ([notification getNotificationType]) {
        case ccNewCommentNotification:
            break;
        case ccFriendJoinedNotification:
            [[cell viewDetailsButton] setHidden:YES];
            break;
        case ccInviteAcceptedNotification:
            break;
        case ccNewVideoNotification:
            break;
    }    
    
    [cell setUpForNotification:notification andViewController:viewController];
    
    return cell;
}


- (void) setUpForNotification:(id<CCNotification>) notification andViewController:(CCNotificationsViewController *) viewController
{
    parentViewController = viewController;
    notificationForCell = notification;
    [notificationMessageLabel setText:[notificationForCell getNotificationMessage]];
    [timeSinceLabel setText:[NSDate getTimeSinceStringFromDate:[notificationForCell getObjectCreatedDate]]];
    if ([notificationForCell getIsClicked])
    {
        [[self notificationMessageLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    }
    else
    {
        [[self notificationMessageLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{   
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)openNotificationButtonPressedWithSender:(id)sender
{
    if (!notificationForCell)
        return;        
    
    [[CCCoreManager sharedInstance] recordMetricEvent:CC_NAVIGATED_TO_CONTENT_FROM_FEED withProperties:nil];
    
    if (![notificationForCell getIsClicked])
    {
        [notificationForCell setIsClickedWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed to push notification as clicked: %@", [error localizedDescription]];
            }
        }];
    }
    
    // Notify various parts of the app what we need to do:
    switch ([notificationForCell getNotificationType]) {
        case ccFriendJoinedNotification:
        {         
            break;
        }
        case ccInviteAcceptedNotification:
        {
            CCCrewMembersViewController *crewsMembersView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewMembersView"];
            
            [crewsMembersView setCrewForView:[[[[CCCoreManager sharedInstance] server] currentUser] getCrewFromObjectID:[notificationForCell getTargetCrewObjectID]]];
            
            [parentViewController presentModalViewController:crewsMembersView animated:YES];
            break;
        }
        case ccNewVideoNotification:
        {
            [[parentViewController globalActivityView] setHidden:NO];
            
            [[[CCCoreManager sharedInstance] server] loadSingleCrewInBackgroundIfNeededWithObjectID:[notificationForCell getTargetCrewObjectID] fromArray:[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] andBlock:^(id<CCCrew> crew, BOOL succeeded, NSError *error)
            {
                [[parentViewController globalActivityView] setHidden:YES];
                
                if (succeeded)
                {
                    CCCrewViewController *crewView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewFeedView"];
                    [crewView setCrewForView:crew];
            
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:crewView];
                    
                    [[navController navigationBar] setClipsToBounds:NO];
                    [[navController navigationBar] setOpaque:YES];   
                    if ([[UIScreen mainScreen] scale] == 0x40000000)
                    {        
                        [[navController navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
                        [[navController navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
                    }
                    else 
                    {
                        [[navController navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
                    }
 
                    [[parentViewController navigationController] presentModalViewController:navController animated:YES];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed To Load Crew" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                    
                    [alert show];  
                }
            }];           
            
            break;
        }
        case ccNewCommentNotification:
        {
            if ([notificationForCell getTargetCrewObjectID])
            {
                [[parentViewController globalActivityView] setHidden:NO];
                
                [[[CCCoreManager sharedInstance] server] loadSingleCrewInBackgroundIfNeededWithObjectID:[notificationForCell getTargetCrewObjectID] fromArray:[[[[CCCoreManager sharedInstance] server] currentUser] ccCrews] andBlock:^(id<CCCrew> crew, BOOL succeeded, NSError *error)
                {
                    if (succeeded)
                    {
                        CCCrewViewController *crewView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewFeedView"];
                        [crewView setCrewForView:crew];
                        
                        [[[CCCoreManager sharedInstance] server] loadSingleVideoInBackgroundIfNeededWithObjectID:[notificationForCell getTargetObjectId] fromArray:[crew ccVideos] andBlock:^(id<CCVideo> video, BOOL succeeded, NSError *error)
                        {
                            [[parentViewController globalActivityView] setHidden:YES];
                            
                            if (succeeded)
                            {
                                CCVideosCommentsViewController *videosCommentsView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"videosCommentsView"];
                               
                                [videosCommentsView setVideoForView:video];
                               
                                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:crewView];
                                
                                
                                [[navController navigationBar] setClipsToBounds:NO];
                                [[navController navigationBar] setOpaque:YES];   
                                if ([[UIScreen mainScreen] scale] == 0x40000000)
                                {        
                                    [[navController navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
                                    [[navController navigationBar] setContentScaleFactor:[[UIScreen mainScreen] scale]];
                                }
                                else 
                                {
                                    [[navController navigationBar] setBackgroundImage:[UIImage imageNamed:@"BAR_Top.png"] forBarMetrics:UIBarMetricsDefault];
                                }
                                
                                [navController pushViewController:videosCommentsView animated:NO];
                                
                                [[parentViewController navigationController] presentModalViewController:navController animated:YES];
                                
                            }
                            else 
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed To Load Video" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
                                
                                [alert show];
                            }
                       }];     
                    }
                    else 
                    {
                        [[parentViewController globalActivityView] setHidden:YES];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed To Load Crew" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
                        
                        [alert show];
                    }
                }];
            }
            else //We do it the old way for outdated notifications, can be cleaned up next major build
            {
                [[[CCCoreManager sharedInstance] server] loadSingleVideoInBackgroundWithObjectID:[notificationForCell getTargetObjectId] andBlock:^(id<CCVideo> video, BOOL succeeded, NSError *error) {
                    CCVideosCommentsViewController *videosCommentsView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"videosCommentsView"];
                    
                    [videosCommentsView setVideoForView:video];
                    
                    [[parentViewController navigationController] pushViewController:videosCommentsView animated:YES];
                }];   
            }
            
            break;
        }
    }
}

@end
