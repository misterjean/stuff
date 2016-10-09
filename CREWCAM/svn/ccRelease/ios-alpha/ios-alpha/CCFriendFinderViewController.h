//
//  CCFriendFinderViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-10.
//
//

#import <UIKit/UIKit.h>
#import "UIView+Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import "CCCoreManager.h"
#import "CCParseFriendFinder.h"
#import "CCPersonIconView.h"
#import "CCPeopleTableViewCell.h"
#import "CCTutorialPopover.h"


@interface CCFriendFinderViewController : UIViewController <CCParseFriendFinderDelegate, UITableViewDelegate, UITextViewDelegate, CCPersonSelectedDelegate, UITextFieldDelegate>
{
    NSArray                 *ccFriends;
    CCParseFriendFinder     *friendFinder;
    BOOL                    isSearchQueued;
    CCBasePerson            *selectedPerson;
    
    CCTutorialPopover       *firstTimePopover;
    CCTutorialPopover       *clickToInvitePopover;
}

@property (weak, nonatomic) IBOutlet UITableView            *friendsTableView;
@property (weak, nonatomic) IBOutlet UILabel                *activityTextView;
@property (weak, nonatomic) IBOutlet UITextField            *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton               *searchBarBackground;

@end
