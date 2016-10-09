//
//  CCInviteTableViewCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCInviteTableViewCell.h"

@implementation CCInviteTableViewCell
@synthesize acceptButton;
@synthesize declineButton;
@synthesize crewNameLabel;
@synthesize invitedByUserNameLabel;
@synthesize inviterThumbnailView;
@synthesize loadingOverlay;
@synthesize inviteForCell;
@synthesize invitedByLabel;

- (void) dealloc
{
    [self setAcceptButton:nil];
    [self setDeclineButton:nil];
    [self setCrewNameLabel:nil];
    [self setInvitedByUserNameLabel:nil];
    [self setInviteForCell:nil];
    [self setInvitedByLabel:nil];
    parentViewController = nil;
    [self setInviterThumbnailView:nil];
    [self setLoadingOverlay:nil];
}

- (IBAction)onAcceptButtonPressed:(id)sender
{
    [loadingOverlay setHidden:NO];
    [inviteForCell acceptInviteInbackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) 
     {
         [loadingOverlay setHidden:YES];
         if (succeeded && [inviteForCell getUserInvitedBy])
         {
             NSString *userAcceptedMessage = [[NSString alloc] initWithFormat:@"%@ has accepted your invite to \"%@\"!", [[inviteForCell getUserInvited]getName], [[inviteForCell getCrewInvitedTo]getName]]; 
             
             [CCParseNotification createNewNotificationInBackgroundWithType:ccInviteAcceptedNotification andTargetUser:[inviteForCell getUserInvitedBy] andSourceUser:[inviteForCell getUserInvited] andTargetObject:inviteForCell andTargetCrewOrNil:[inviteForCell getCrewInvitedTo] andMessage:[[NSString alloc] initWithFormat:@"%@ has accepted your invite to \"%@\"!", [[inviteForCell getUserInvited]getName], [[inviteForCell getCrewInvitedTo] getName]]];
             
             [[inviteForCell getUserInvitedBy] sendNotificationWithMessage:userAcceptedMessage];
         }
     }];
}

- (IBAction)onDeclineButtonPressed:(id)sender
{
    CCCrewcamAlertView *updateAlert = [[CCCrewcamAlertView alloc] initWithTitle: @"Decline Invite" message: @"Are you sure you want to decline?" withTextField:NO delegate: self cancelButtonTitle: @"NO" otherButtonTitles:@"YES", nil];
    {
        [updateAlert show];
    }
}    

- (IBAction)onViewMembersButtonPressed:(id)sender {
    id<CCCrew> crewForView = [inviteForCell getCrewInvitedTo];
    
    CCCrewMembersViewController *crewsMembersView = [[parentViewController storyboard] instantiateViewControllerWithIdentifier:@"crewMembersView"];
    
    [crewsMembersView setCrewForView:crewForView];
    
    [parentViewController.navigationController pushViewController:crewsMembersView animated:YES];
}

- (void)alertView:(CCCrewcamAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [loadingOverlay setHidden:NO];
        [inviteForCell deleteObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            [loadingOverlay setHidden:YES];
        }];
    };
}

- (void) setInviteForCell: (id<CCInvite>) invite withViewController:(UIViewController *) viewController
{
    [loadingOverlay setHidden:YES];
    parentViewController = viewController;
    inviteForCell = invite;
    [crewNameLabel setFont:[UIFont getSteelfishFontForSize:30]];
    [crewNameLabel setText:[[[inviteForCell getCrewInvitedTo] getName] uppercaseString]];
    
    [[invite getUserInvitedBy] getProfilePictureInBackgroundWithBlock:^(UIImage *image, NSError *error) {
        [inviterThumbnailView setImage:image];
    }];

    if ([inviteForCell getUserInvitedBy])
    {
        [[self invitedByLabel] setHidden:NO];
        [[self invitedByUserNameLabel] setHidden:NO];
        [invitedByUserNameLabel setText:[[inviteForCell getUserInvitedBy] getName]];
    }
    else 
    {
        [[self invitedByUserNameLabel] setHidden:YES];
        [[self invitedByLabel] setHidden:YES];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
