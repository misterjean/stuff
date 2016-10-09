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


@interface CCNewCrewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSMutableArray              *selectedFacebookFriends;
    NSMutableArray              *facebookFriends;
    NSMutableArray              *selectedAddressBookFriends;
    NSMutableArray              *addressBookFriends;    
    NSMutableArray              *selectedCrewcamFriends;
    NSMutableArray              *crewcamFriends;    
    
    BOOL                        isSearching;
    NSMutableArray              *filteredListContent;
    UISearchDisplayController   *searchController;
    BOOL                        isPublicCrew;
}
@property (weak, nonatomic)     IBOutlet UIActivityIndicatorView    *loadingFriendsIndicator;
@property (strong, nonatomic)   NSArray                             *peopleThatAreFriends;
@property (weak, nonatomic)     IBOutlet UITableView                *friendsTableView;
@property (weak, nonatomic)     IBOutlet UITextField                *crewNameField;
@property (strong, nonatomic)   IBOutlet UINavigationItem           *crewNavigationBar;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic)     IBOutlet UILabel                    *activityLabel;
@property (weak, nonatomic)     IBOutlet UIButton         *publicPrivateSelecor;
@property (weak, nonatomic)     IBOutlet UIView                     *optionsBackgroundView;

@property (weak, nonatomic)     IBOutlet UIView                     *postingCrewOverlay;
@property (weak, nonatomic)     IBOutlet UISearchBar                *searchBar;
@property (strong, nonatomic)   NSMutableArray                      *selectedPeople;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishedButton;

@property id<CCCrew> passedCrew;
- (IBAction)onDoneButtonPressed:(id)sender;
- (IBAction)hideKeyboad:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)onPrivatePublicButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *crewcamButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;


- (IBAction)onContactsSelected:(id)sender;
- (IBAction)onFacebookSelected:(id)sender;
- (IBAction)onCrewcamSelected:(id)sender;



@end
