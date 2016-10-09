//
//  CCFriendCrewTableViewCell.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCFriendCrewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *crewNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *crewMembersLabel;
@property (weak, nonatomic) IBOutlet UILabel *crewVideosLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView  *crewActivityIndicator;


@end
