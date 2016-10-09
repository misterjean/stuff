//
//  CCParseServer.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CCServer.h"
#import "Parse/Parse.h"
#import "CCUser.h"
#import "CCCoreManager.h"
#import "CCParseUser.h"
#import "CCParseAuthenticator.h"
#import "CCParseVideo.h"
#import "CCServerStoredObject.h"
#import "KISSMetricsAPI.h"
#import "CCInvite.h"
#import "CCParseInvitedPerson.h"
#import "CCParseVideoUploader.h"
#import "CCCrewcamAlertView.h"

@class CCParseAuthenticator;

@interface CCParseServer : NSObject <CCServer, MFMessageComposeViewControllerDelegate, PF_FBRequestDelegate>
{    
    NSMutableArray                          *coreObjectsDelegates;
    NSArray                                 *addressBookContactsToInvite;
    NSArray                                 *crewsToInviteTo;
    CCBooleanResultBlock                    messageInviteCompletionBlock;
    __block NSMutableDictionary             *customerDatabaseDictionary;
    NSCondition                             *facebookLoadingDataCondition;
    NSDictionary                            *facebookUserData;
    BOOL                                    lastVideoUploadFailed;
    
    NSMutableArray *ccVideoUploadersInProgress;
}


@end
