//
//  CCCrewTableCell.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCrew.h"
#import "CCServerStoredObjectDelegate.h"
#import "CCUser.h"
#import "CCCoreManager.h"

@interface CCCrewTableViewCell : UITableViewCell <CCCrewUpdatesDelegate, CCUserUpdatesDelegate,  CCServerStoredObjectDelegate>
@property (weak, nonatomic) IBOutlet UILabel    *crewNameLabel;
@property (weak, nonatomic) IBOutlet UILabel    *numberOfVideosLabel;
@property (weak, nonatomic) IBOutlet UILabel    *numberOfMembersLabel;
@property (weak, nonatomic) IBOutlet UILabel    *numberOfUnwatchedVideosLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *unwatchedVideosBadge;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *crewActivityIndicator;
@property (weak, nonatomic)          id<CCCrew> crew;

- (void)setCrew:(id<CCCrew>) crew;
@end
