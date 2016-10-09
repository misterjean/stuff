//
//  CCNewCrewViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCoreManager.h"
#import "UIBarButtonItem+CCCustomBarButtonItem.h"
#import "UIView+Utilities.h"
#import "CCPeopleTableViewCell.h"
#import "CCPersonIconView.h"
#import "CCTutorialPopover.h"


@interface CCInviteAndAddCrewViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CCPersonSelectedDelegate, CCCrewcamAlertViewDelegate>
{
    NSMutableArray              *selectedFacebookFriends;
    NSArray                     *facebookFriends;
    NSMutableArray              *selectedAddressBookFriends;
    NSArray                     *addressBookFriends;
    NSMutableArray              *selectedCrewcamFriends;
    NSArray                     *crewcamFriends;
    NSMutableArray              *selectedPeople;
    
    BOOL                        isSearching;
    NSMutableArray              *filteredListContent;
    BOOL                        isPublicCrew;
    
    CCTutorialPopover           *noFriendsPopover;
}

@property (strong, nonatomic)   NSArray                             *peopleThatAreFriends;
@property (weak, nonatomic)     IBOutlet UITableView                *friendsTableView;
@property (weak, nonatomic)     IBOutlet UITextField                *crewNameField;
@property (weak, nonatomic)     IBOutlet UILabel                    *activityLabel;
@property (weak, nonatomic)     IBOutlet UIButton                   *publicPrivateSelecor;
@property (weak, nonatomic) IBOutlet UIButton                       *privatePublicHelpButton;
@property (weak, nonatomic) IBOutlet UIButton                       *searchBarBackground;
@property (weak, nonatomic)     IBOutlet UIView                     *postingCrewOverlay;
@property (weak, nonatomic) IBOutlet UITextField                    *searchStringField;
@property (strong, nonatomic) UINavigationController                *storedNavigationController;
@property (weak, nonatomic)     IBOutlet UIButton                   *crewcamButton;
@property (weak, nonatomic)     IBOutlet UIButton                   *facebookButton;
@property (weak, nonatomic)     IBOutlet UIButton                   *contactsButton;
@property id<CCCrew>                                                passedCrew;


- (IBAction)onDoneButtonPressed:(id)sender;
- (IBAction)hideKeyboad:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)onPrivatePublicHelpPressed:(id)sender;
- (IBAction)onPrivatePublicButtonPress:(id)sender;


- (IBAction)onContactsSelected:(id)sender;
- (IBAction)onFacebookSelected:(id)sender;
- (IBAction)onCrewcamSelected:(id)sender;



@end
