//
//  CCUser.h
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCServerStoredObject.h"
#import "CoreLocation/CoreLocation.h"

@protocol CCCrew;       // Forward decleration to solve circular protocols

@protocol CCUser <CCServerStoredObject>

@required
// Required methods
- (void)sendNotificationWithMessage:(NSString*)message;

- (void)loadCrewsWithNewThread:(Boolean)useNewThread;
- (void)loadInvitesWithNewThread:(Boolean)useNewThread;

- (void)inviteToCrew:(id<CCCrew>)crew useNewThread:(Boolean)useNewThread;
- (void)subscribeToUserChannel;

// Required properties
@property (strong, nonatomic) NSString          *userId;
@property (strong, nonatomic) NSString          *emailAddress;
@property (strong, nonatomic) NSString          *gender;
@property (strong, nonatomic) NSString          *firstName;
@property (strong, nonatomic) NSString          *lastName;
@property (strong, nonatomic) UIImage           *profilePicture;
@property (strong, nonatomic) CLLocation        *location;
@property (strong, nonatomic) NSMutableArray    *crews;
@property (strong, nonatomic) NSString          *facebookId;
@property (strong, nonatomic) NSMutableArray    *ccInvites;
@property BOOL                                  isLocked;
@property (strong, nonatomic) NSData            *userImageData;

@optional

@end