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
@synthesize userThumbnailView;

- (void) dealloc
{
    notificationForCell = nil;
    parentViewController = nil;
    
    [self setNotificationMessageLabel:nil];
    [self setTimeSinceLabel:nil];
    [self setViewDetailsButton:nil];    
    [self setUserThumbnailView:nil];
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
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views.png"] forState:UIControlStateNormal];
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateHighlighted];
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateSelected];
            break;
        case ccFriendJoinedNotification:
            [[cell viewDetailsButton] setImage:nil forState:UIControlStateNormal];
            [[cell viewDetailsButton] setImage:nil forState:UIControlStateHighlighted];
            break;
        case ccInviteAcceptedNotification:
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views.png"] forState:UIControlStateNormal];
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateHighlighted];
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateSelected];
            break;
        case ccNewVideoNotification:
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views.png"] forState:UIControlStateNormal];
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateHighlighted];
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateSelected];
            break;
        case ccFriendRequestNotification:
        {
            [CCParseFriendRequest loadSingleFriendRequestInBackgroundForObjectId:[notification getTargetObjectId] withBlockOrNil:^(id<CCFriendRequest> request, NSError *error) {
                if (request && ![request getHasRequestBeenAcceptedByRequestee])
                {
                    [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views.png"] forState:UIControlStateNormal];
                    [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateHighlighted];
                    [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateSelected];
                }
                else
                {
                    [[cell viewDetailsButton] setImage:nil forState:UIControlStateNormal];
                    [[cell viewDetailsButton] setImage:nil forState:UIControlStateHighlighted];
                }
            }];
            break;
        }
        case ccFriendRequestAcceptedNotification:
        {
            [[cell viewDetailsButton] setImage:nil forState:UIControlStateNormal];
            [[cell viewDetailsButton] setImage:nil forState:UIControlStateHighlighted];
            break;
        }
        case ccNewViewNotification:
        {
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views.png"] forState:UIControlStateNormal];
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateHighlighted];
            [[cell viewDetailsButton] setImage:[UIImage imageNamed:@"BTN_Views_ACT.png"] forState:UIControlStateSelected];
            break;
        }
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
    
    [[notificationForCell getSourceUser] getProfilePictureInBackgroundWithBlock:^(UIImage *image, NSError *error) {
        [[self userThumbnailView] setImage:image];
    }];
    
    if ([notificationForCell getIsClicked])
    {
        [[self notificationMessageLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    }
    else
    {
        [[self notificationMessageLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
    }
    
    CGFloat topCorrect = ([notificationMessageLabel contentSize].height - [notificationMessageLabel bounds].size.height);
    
    if (topCorrect != 0)
    {
        // Only adjust the cell size to be bigger
        if (topCorrect > 0)
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + topCorrect)];
        
        [notificationMessageLabel setFrame:CGRectMake(notificationMessageLabel.frame.origin.x, notificationMessageLabel.frame.origin.y, notificationMessageLabel.frame.size.width, notificationMessageLabel.frame.size.height + topCorrect)];
        [timeSinceLabel setFrame:CGRectMake(timeSinceLabel.frame.origin.x, timeSinceLabel.frame.origin.y + topCorrect, timeSinceLabel.frame.size.width, timeSinceLabel.frame.size.height)];
        [viewDetailsButton setFrame:CGRectMake(viewDetailsButton.frame.origin.x, viewDetailsButton.frame.origin.y + topCorrect/2, viewDetailsButton.frame.size.width, viewDetailsButton.frame.size.height)];
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
    
    // Only register the "navigated to content" event if we actually go somewhere.
    if ([notificationForCell getNotificationType] != ccFriendJoinedNotification)
        [[CCCoreManager sharedInstance] recordMetricEvent:CC_NAVIGATED_TO_CONTENT_FROM_FEED withProperties:nil];
    
    if (![notificationForCell getIsClicked])
    {
        [notificationForCell setIsClickedWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Failed to push notification as clicked: %@", [error localizedDescription]];
            }
        }];
    }
    
    [[parentViewController notificationsTableView] reloadData];
    
    // Notify various parts of the app what we need to do:
    switch ([notificationForCell getNotificationType]) {
        case ccFriendJoinedNotification:
        {         
            break;
        }
        case ccInviteAcceptedNotification:
        {
            [[self viewDetailsButton] setEnabled:NO];
            
            id<CCCrew> crewForNotification = [[[[CCCoreManager sharedInstance] server] currentUser] getCrewFromObjectID:[notificationForCell getTargetCrewObjectID]];
            
            // If we couldn't find this crew, just return (the notification has already been marked as "clicked"
            if (!crewForNotification)
                return;
            
            CCCrewMembersViewController *crewsMembersView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewMembersView"];
            
            [crewsMembersView setCrewForView:crewForNotification];
            
            [[self viewDetailsButton] setEnabled:YES];
            
            [parentViewController.navigationController pushViewController:crewsMembersView animated:YES];
            
            break;
        }
        case ccNewVideoNotification:
        {
            [[self viewDetailsButton] setEnabled:NO];
            
            [[parentViewController globalActivityView] setHidden:NO];
            
            [[[CCCoreManager sharedInstance] server] loadSingleCrewInBackgroundWithObjectID:[notificationForCell getTargetCrewObjectID] andBlock:^(id<CCCrew> crew, BOOL succeeded, NSError *error)
            {
                [[parentViewController globalActivityView] setHidden:YES];
                
                if (succeeded)
                {
                    [[[CCCoreManager sharedInstance] server] loadSingleVideoInBackgroundWithObjectID:[notificationForCell getTargetObjectId] andBlock:^(id<CCVideo> video, BOOL succeeded, NSError *error)
                     {
                         [[parentViewController globalActivityView] setHidden:YES];
                         
                         if (succeeded)
                         {
                             CCCrewViewController *crewView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewFeedView"];
                             [crewView setCrewForView:crew];            
                             
                             [crewView setIsLoadingForNotification:YES];
                             
                             [[[crewView crewForView] ccVideos] insertObject:video atIndex:0];
                             
                             [[parentViewController navigationController] pushViewController:crewView animated:YES];
                         }
                         else 
                         {
                             CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Error" message:@"Hmm... we couldn't load the video. It's possible it was deleted." withTextField:NO delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
                             
                             [alert show];
                         }
                         
                         [[self viewDetailsButton] setEnabled:YES];
                     }];
                }
                else
                {
                    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Error" message:@"Failed To Load Crew" withTextField:NO delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                    
                    [alert show]; 
                    
                    [[self viewDetailsButton] setEnabled:YES];
                }
            }];           
            
            break;
        }
        case ccNewCommentNotification:
        {
            [[self viewDetailsButton] setEnabled:NO];
            
            if ([notificationForCell getTargetCrewObjectID])
            {
                [[parentViewController globalActivityView] setHidden:NO];
                
                [[[CCCoreManager sharedInstance] server] loadSingleCrewInBackgroundWithObjectID:[notificationForCell getTargetCrewObjectID] andBlock:^(id<CCCrew> crew, BOOL succeeded, NSError *error)
                {
                    if (succeeded)
                    {
                        CCCrewViewController *crewView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewFeedView"];
                        [crewView setCrewForView:crew];
                        
                        [[[CCCoreManager sharedInstance] server] loadSingleVideoInBackgroundWithObjectID:[notificationForCell getTargetObjectId] andBlock:^(id<CCVideo> video, BOOL succeeded, NSError *error)
                        {
                            [[parentViewController globalActivityView] setHidden:YES];
                            
                            if (succeeded)
                            {
                                CCCrewViewController *crewView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewFeedView"];
                                [crewView setCrewForView:crew];            
                                
                                [crewView setIsLoadingForNotification:YES];
                                
                                [[[crewView crewForView] ccVideos] addObject:video];
                                
                                [[parentViewController navigationController] pushViewController:crewView animated:NO];
                                
                                CCVideosCommentsViewController *videosCommentsView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"videosCommentsView"];
                               
                                [videosCommentsView setVideoForView:video];
                                                               
                                [[parentViewController navigationController] pushViewController:videosCommentsView animated:YES];
                                
                            }
                            else 
                            {
                                CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Error" message:@"Hmm... we couldn't load the video. It's possible it was deleted." withTextField:NO delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
                                
                                [alert show];
                            }
                            
                            [[self viewDetailsButton] setEnabled:YES];
                       }];     
                    }
                    else 
                    {
                        [[parentViewController globalActivityView] setHidden:YES];
                        
                        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Error" message:@"Failed To Load Crew" withTextField:NO delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
                        
                        [alert show];
                        
                        [[self viewDetailsButton] setEnabled:YES];
                    }
                }];
            }
            else //We do it the old way for outdated notifications, can be cleaned up next major build
            {
                [[[CCCoreManager sharedInstance] server] loadSingleVideoInBackgroundWithObjectID:[notificationForCell getTargetObjectId] andBlock:^(id<CCVideo> video, BOOL succeeded, NSError *error) {
                    CCVideosCommentsViewController *videosCommentsView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"videosCommentsView"];
                    
                    [videosCommentsView setVideoForView:video];

                    [[self viewDetailsButton] setEnabled:YES];
                    
                    [[parentViewController navigationController] pushViewController:videosCommentsView animated:YES];
                }];   
            }            
            break;
        }
        case ccFriendRequestNotification:
        {        
            [[self viewDetailsButton] setEnabled:NO];
            
            [CCParseFriendRequest loadSingleFriendRequestInBackgroundForObjectId:[notificationForCell getTargetObjectId] withBlockOrNil:^(id<CCFriendRequest> request, NSError *error) {
                if (request && ![request getHasRequestBeenAcceptedByRequestee])
                {
                    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Respond to Request"
                                                                                  message:[NSString stringWithFormat:@"Accept the friend request from %@?", [[notificationForCell getSourceUser] getName]]
                                                                            withTextField:NO
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"Decline"
                                                                        otherButtonTitles:@"Accept", nil];
                    
                    [alert setTag:acceptFriendRequestAlertTag];
                    
                    [alert show];
                }
                else
                {
                    [viewDetailsButton setImage:nil forState:UIControlStateNormal];
                    [viewDetailsButton setImage:nil forState:UIControlStateHighlighted];            
                }
                
                [[self viewDetailsButton] setEnabled:YES];
            }];
            break;
        }
        case ccNewViewNotification:
        {
            [[self viewDetailsButton] setEnabled:NO];
            
            if ([notificationForCell getTargetCrewObjectID])
            {
                [[parentViewController globalActivityView] setHidden:NO];
                
                [[[CCCoreManager sharedInstance] server] loadSingleCrewInBackgroundWithObjectID:[notificationForCell getTargetCrewObjectID] andBlock:^(id<CCCrew> crew, BOOL succeeded, NSError *error)
                 {
                     if (succeeded)
                     {
                         CCCrewViewController *crewView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewFeedView"];
                         [crewView setCrewForView:crew];
                         
                         [[[CCCoreManager sharedInstance] server] loadSingleVideoInBackgroundWithObjectID:[notificationForCell getTargetObjectId] andBlock:^(id<CCVideo> video, BOOL succeeded, NSError *error)
                          {
                              [[parentViewController globalActivityView] setHidden:YES];
                              
                              if (succeeded)
                              {
                                  CCCrewViewController *crewView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewFeedView"];
                                  [crewView setCrewForView:crew];            
                                  
                                  [crewView setIsLoadingForNotification:YES];
                                  
                                  [[[crewView crewForView] ccVideos] addObject:video];
                                  
                                  [[parentViewController navigationController] pushViewController:crewView animated:NO];
                                  
                                  CCVideosViewsViewController *videosViewesView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"videosViewsView"];
                                  
                                  [videosViewesView setVideoForView:video];
                                  
                                  [[parentViewController navigationController] pushViewController:videosViewesView animated:YES];
                                  
                              }
                              else 
                              {
                                  CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Error" message:@"Hmm... we couldn't load the video. It's possible it was deleted." withTextField:NO delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
                                  
                                  [alert show];
                              }
                              
                              [[self viewDetailsButton] setEnabled:YES];
                          }];     
                     }
                     else 
                     {
                         [[parentViewController globalActivityView] setHidden:YES];
                         
                         CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Error" message:@"Failed To Load Crew" withTextField:NO delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
                         
                         [alert show];
                         
                         [[self viewDetailsButton] setEnabled:YES];
                     }
                 }];
            }
            else //We do it the old way for outdated notifications, can be cleaned up next major build
            {
                [[[CCCoreManager sharedInstance] server] loadSingleVideoInBackgroundWithObjectID:[notificationForCell getTargetObjectId] andBlock:^(id<CCVideo> video, BOOL succeeded, NSError *error) {
                    CCVideosViewsViewController *videosViewesView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"videosViewsView"];
                    
                    [videosViewesView setVideoForView:video];
                    
                    [[self viewDetailsButton] setEnabled:YES];
                    
                    [[parentViewController navigationController] pushViewController:videosViewesView animated:YES];
                }];   
            }            
            break;

        }
        default:
            break;
    }
}

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag])
    {
        case acceptFriendRequestAlertTag:
            [viewDetailsButton setImage:nil forState:UIControlStateNormal];
            [viewDetailsButton setImage:nil forState:UIControlStateHighlighted];

            [CCParseFriendRequest loadSingleFriendRequestInBackgroundForObjectId:[notificationForCell getTargetObjectId] withBlockOrNil:^(id<CCFriendRequest> request, NSError *error) {
                if (!request)
                {
                    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Error!"
                                                                                  message:@"Error loading friend request."
                                                                            withTextField:NO
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil, nil];
                    
                    [alert show];
                    
                    return;
                }
                
                if (buttonIndex == 1)
                {
                    [request acceptInviteInBackgroundWithBlockOrNil:nil];
                    CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Friend Request"
                                                                                  message:@"Request accepted!"
                                                                            withTextField:NO
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil, nil];

                    [alert show];
                }
                else
                {
                    [notificationForCell deleteObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
                        [[[[CCCoreManager sharedInstance] server] currentUser] loadNotificationsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) { 
                        }];

                    }];
                    
                    [[CCCoreManager sharedInstance] recordMetricEvent:CC_DECLINED_FRIEND_REQUEST withProperties:nil];
                    
                    [request deleteObjectWithBlockOrNil:nil];
                }
            }];
            
            break;
    }
}

@end
