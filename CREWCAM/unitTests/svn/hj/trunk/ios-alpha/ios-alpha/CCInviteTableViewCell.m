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
@synthesize processingActivityIndicatorView;
@synthesize inviteForCell;

- (void) dealloc
{
    [self setAcceptButton:nil];
    [self setDeclineButton:nil];
    [self setCrewNameLabel:nil];
    [self setInvitedByUserNameLabel:nil];
    [self setProcessingActivityIndicatorView:nil];
    [self setInviteForCell:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)onAcceptButtonPressed:(id)sender
{
    [processingActivityIndicatorView setHidden:NO];
    [inviteForCell acceptInviteInbackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) 
     {
         [processingActivityIndicatorView setHidden:YES];
         
         if (succeeded)
         {
             NSString *userAcceptedMessage = [[NSString alloc] initWithFormat:@"%@ has accepted your invite to \"%@\"!", [[inviteForCell getUserInvited]getName], [[inviteForCell getCrewInvitedTo]getName]]; 
             
             [CCParseNotification createNewNotificationInBackgroundWithType:ccInviteAcceptedNotification andTargetUser:[inviteForCell getUserInvitedBy] andSourceUser:[inviteForCell getUserInvited] andTargetObject:inviteForCell andTargetCrewOrNil:[inviteForCell getCrewInvitedTo] andMessage:[[NSString alloc] initWithFormat:@"%@ has accepted your invite to \"%@\"!", [[inviteForCell getUserInvited]getName], [[inviteForCell getCrewInvitedTo] getName]]];
             
             [[inviteForCell getUserInvitedBy] sendNotificationWithMessage:userAcceptedMessage];
         }
     }];
}

- (IBAction)onDeclineButtonPressed:(id)sender
{
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle: @"Decline Invite" message: @"Are you sure you want to decline?" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles:@"Decline", nil];
    {
        [updateAlert show];
    }
}    

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [processingActivityIndicatorView setHidden:NO];
        [inviteForCell deleteObjectWithBlockOrNil:nil];
    };
}



- (void) setInviteForCell: (id<CCInvite>) invite
{
    inviteForCell = invite;
    
    [crewNameLabel setText:[[inviteForCell getCrewInvitedTo] getName]];
    [invitedByUserNameLabel setText:[[inviteForCell getUserInvitedBy] getName]];
    
    if ([invite isBusy])
        [processingActivityIndicatorView setHidden:NO];
    else
        [processingActivityIndicatorView setHidden:YES];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
