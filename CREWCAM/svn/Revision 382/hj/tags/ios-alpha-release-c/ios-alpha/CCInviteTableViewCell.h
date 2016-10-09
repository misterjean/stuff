//
//  CCInviteTableViewCell.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCInvite.h"

@interface CCInviteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UILabel *crewNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedByUserNameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *processingActivityIndicator;

@property (weak, nonatomic) id<CCInvite>    inviteForCell;

- (IBAction)onAcceptButtonPressed:(id)sender;
- (IBAction)onDeclineButtonPressed:(id)sender;

- (void) setInviteForCell: (id<CCInvite>) invite;
@end
