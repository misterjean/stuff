//
//  CCParseFriendFinder.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-10.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CCParseUser.h"
#import <Foundation/Foundation.h>

@protocol CCParseFriendFinderDelegate <NSObject>

@optional
- (void) didUpdateFriendsSearchResultWithSuccess:(BOOL) wasSuccesfull andError:(NSError *) error andCCUsersThatAreFriends:(NSArray *) ccFriends;
- (void) didBeginSearchingForFriends;

@end

@interface CCParseFriendFinder : NSObject
{
    NSMutableArray *delegates;
    
    u_int32_t isSearching;
}

- (void) startSearchingForFriendsWithString:(NSString *) searchString;

- (void) addDelegate:(id<CCParseFriendFinderDelegate>) delegate;
- (void) removeDelegate:(id<CCParseFriendFinderDelegate>) delegate;

- (BOOL) isSearching;

@end
