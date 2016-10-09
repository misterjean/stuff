//
//  CCParseServer.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CCFacebookConnector.h"
#import "CCServer.h"
#import "Parse/Parse.h"
#import "CCServerLoginDelegate.h"
#import "CCUser.h"
#import "CCCoreManager.h"
#import "CCParseUser.h"
#import "CCParseAuthenticator.h"
#import "CCParseVideo.h"
#import "CCServerPostObjectDelegate.h"
#import "CCServerStoredObject.h"
#import "KISSMetricsAPI.h"
#import "CCInvite.h"

@interface CCParseServer : NSObject <CCServer>
{
    CCFacebookConnector                     *facebookConnector;
    CCParseAuthenticator                    *parseAuthenticator;
    
    // Delegates
    id<CCServerLoginDelegate>               serverLoginDelegate;
    CCArrayResultBlock                      serverLoadFriendsBlock;
    CCArrayResultBlock                      serverLoadFriendsCrewsBlock;
    NSMutableArray                          *coreObjectsDelegates;
}
@end
