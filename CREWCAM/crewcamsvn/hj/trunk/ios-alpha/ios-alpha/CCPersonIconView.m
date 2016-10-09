//
//  CCSelectablePersonView.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-26.
//
//

#import "CCPersonIconView.h"

@implementation CCPersonIconView
@synthesize isPersonSelected;

@synthesize personsImageView;
@synthesize personsNameView;
@synthesize selectedOverlay;
@synthesize pendingRequestOverlay;
@synthesize crewcamFriendOverlay;

- (void) dealloc
{
    personForView = nil;
    personSelectedDelegate = nil;
    personsImageView = nil;
    personsNameView = nil;
    selectedOverlay = nil;
    pendingRequestOverlay = nil;
    crewcamFriendOverlay = nil;
}

- (void) setUpView
{    
    [personsNameView setFont:[UIFont getSteelfishFontForSize:20]];
}

- (void) setupForPerson:(CCBasePerson *) person andIsSelectable:(BOOL) isSelectable andIsSelected:(NSNumber *) isSelected andIsInvitable:(BOOL) isInvitable
{
    if (person == personForView)
        return;
    
    if (!personForView)
        [self setUpView];
    
    isPersonInvitable = isInvitable;
    
    [pendingRequestOverlay setHidden:YES];
    [crewcamFriendOverlay setHidden:YES];
    isPersonSelectable = isSelectable;
    isPersonSelected = [isSelected boolValue];
    
    isPersonAFriend = [[[[CCCoreManager sharedInstance] server] currentUser] isFriendOfUser:[person ccUser]];
    isPersonInvited = [[[[CCCoreManager sharedInstance] server] currentUser] hasFriendRequestedUser:[person ccUser]];
    if (isPersonAFriend)
    {
        [crewcamFriendOverlay setHidden:NO];
    }
    else if(isPersonInvited)
    {
        [pendingRequestOverlay setHidden:NO];
    }
    
    [selectedOverlay setHidden:!isPersonSelected];
    
    personForView = person;
    [personsImageView setImage:nil];
    
    if ([personForView ccUser])
    {
        __block CCBasePerson *personForImage = personForView;
        [[personForView ccUser] getProfilePictureInBackgroundWithBlock:^(UIImage *image, NSError *error) {
            if (personForView == personForImage)
                [personsImageView setImage:image];
        }];
    }
    else
    {
        [personsImageView setImage:[UIImage imageNamed:@"default-profile.png"]];
    }
        
    [personsNameView setText:[[personForView getName] uppercaseString]];
    
    personsNameView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    CGFloat topCorrect = ([personsNameView bounds].size.height - [personsNameView contentSize].height);
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);
    personsNameView.contentInset = UIEdgeInsetsMake(topCorrect, 0, 0, 0);
}

- (IBAction)didSelectPerson:(id)sender {
    
    if (!isPersonSelectable ||
        (isPersonInvitable && (isPersonInvited || isPersonAFriend)) ||
        [[personForView getUniqueID] isEqualToString:[[[[CCCoreManager sharedInstance] server] currentUser] getObjectID]])
        return;
    
    isPersonSelected = !isPersonSelected;
    [selectedOverlay setHidden:![selectedOverlay isHidden]];
    if (personSelectedDelegate)
    {
        if (isPersonSelected && [personSelectedDelegate respondsToSelector:@selector(didSelectPerson:forView:)])
            [personSelectedDelegate didSelectPerson:personForView forView:self];
        else if ([personSelectedDelegate respondsToSelector:@selector(didUnselectPerson:forView:)])
            [personSelectedDelegate didUnselectPerson:personForView forView:self];
    }
    
    if (isPersonInvitable)
    {
        // We're trying to invite a non Crewcam person.  Is the currently released version of the App new enough?
        if (![personForView ccUser])
        {
            if ([CC_MINIMUM_VERSION_FOR_FRIEND_REQUEST compare:[[[CCCoreManager sharedInstance] server] globalSettings].currentAppStoreRevisionString] == NSOrderedDescending)
            {
                CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Version Error" message:@"You are running a pre-release version of Crewcam and the currently released version doesn't support this feature.  You'll have to wait till this version goes live!" withTextField:NO delegate:nil cancelButtonTitle:@"Darn" otherButtonTitles:nil];
                
                [alert show];
                
                [selectedOverlay setHidden:YES];
                
                return;
            }
        }
        else if ([[NSString stringWithFormat: CC_MINIMUM_VERSION_FOR_FRIEND_REQUEST] compare:[[personForView ccUser] getUserRevision] options:NSNumericSearch] == NSOrderedDescending)
        {
            CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"Version Error" message:@"Selected user needs to update Crewcam to support friend requests.  Tell them to update!" withTextField:NO delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
            
            [selectedOverlay setHidden:YES];
            
            return;
        }
        
        CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"FRIEND REQUEST"
                                                                      message:[NSString stringWithFormat:@"Send friend request to %@?", [[personForView ccUser] getName]]
                                                                withTextField:NO
                                                                     delegate:self
                                                            cancelButtonTitle:@"No"
                                                            otherButtonTitles:@"Yes",nil];
                
        [alert show];        
    }
}

/* CCCrewcamAlertViewDelegate Methods */

- (void)alertView:(CCCrewcamAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [selectedOverlay setHidden:YES];
    
    if (buttonIndex != 1)
        return;
    
    isPersonInvited = YES;
    
    [[self pendingRequestOverlay] setHidden:NO];
    
    [[personForView ccUser] sendFriendRequestInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
        [[[[CCCoreManager sharedInstance] server] currentUser] loadFriendRequestsInBackgroundWithBlockOrNil:^(BOOL succeeded, NSError *error) {
            CCCrewcamAlertView *alert = [[CCCrewcamAlertView alloc] initWithTitle:@"FRIEND REQUEST"
                                                                          message:@"Request sent."
                                                                    withTextField:NO
                                                                         delegate:self
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles:nil];
            
            [alert show];
        }];
        
    }];
}

- (void) setDelegate:(id<CCPersonSelectedDelegate>) delegate
{
    personSelectedDelegate = delegate;
}

- (void) setSelected:(BOOL) isSelected
{
    isPersonSelected = isSelected;
    [selectedOverlay setHidden:!isSelected];
}
@end
