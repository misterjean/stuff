//
//  CCParseFriendFinder.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-10.
//
//

#import "CCParseFriendFinder.h"

@implementation CCParseFriendFinder

- (id) init
{
    self = [super init];
    
    if (self)
    {
        delegates = [[NSMutableArray alloc] init];
        isSearching = NO;
    }
    
    return self;
}

/* Required methods */
- (void) startSearchingForFriendsWithString:(NSString *) searchString
{
    if (OSAtomicTestAndSet(YES, &isSearching))
        return;
        
    NSMutableArray *orConstraints = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"firstName" matchesRegex:[NSString stringWithFormat:@"^%@", searchString] modifiers:@"i"];
    [orConstraints addObject:query];
    
    query = [PFUser query];
    [query whereKey:@"lastName" matchesRegex:[NSString stringWithFormat:@"^%@", searchString] modifiers:@"i"];
    [orConstraints addObject:query];

    query = [PFUser query];
    [query whereKey:@"emailAddress" matchesRegex:[NSString stringWithFormat:@"^%@", searchString] modifiers:@"i"];
    [orConstraints addObject:query];
    
    query = [PFQuery orQueryWithSubqueries:orConstraints];
    
    [query whereKey:@"objectId" notEqualTo:[[[[CCCoreManager sharedInstance] server] currentUser] getObjectID]];
    
    [query orderByAscending:@"firstName"];
    [query addAscendingOrder:@"lastName"];
    
    [self notifyDelegatesThatSearchIsBeginning];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        OSAtomicTestAndClear(YES, &isSearching);
        
        if (error)
        {
            [self notifyDelegatesThatSearchHasFinishedWithSuccess:NO andError:error andFriends:nil];
            
            return;
        }
        
        NSMutableArray *ccFriends =[[NSMutableArray alloc] init];
        
        for(PFObject *pfUser in objects)
        {
            [ccFriends addObject:[[CCBasePerson alloc] initWithCCUser:[[CCParseUser alloc] initWithServerData:pfUser]]];
        }
        
        [self notifyDelegatesThatSearchHasFinishedWithSuccess:YES andError:nil andFriends:ccFriends];
    }];
}

- (void) addDelegate:(id<CCParseFriendFinderDelegate>) delegate
{
    if (![delegates containsObject:delegate])
        [delegates addObject:delegate];
}

- (void) removeDelegate:(id<CCParseFriendFinderDelegate>) delegate
{
    if ([delegates containsObject:delegate])
        [delegates removeObject:delegate];
}

- (BOOL) isSearching
{
    return isSearching;
}

/* HELPER METHODS */
- (void) notifyDelegatesThatSearchIsBeginning
{
    for(id<CCParseFriendFinderDelegate> delegate in delegates)
    {
        if ([delegate respondsToSelector:@selector(didBeginSearchingForFriends)])
            [delegate didBeginSearchingForFriends];
    }
}

- (void) notifyDelegatesThatSearchHasFinishedWithSuccess:(BOOL) succes andError:(NSError *) error andFriends:(NSArray *) friends
{
    for(id<CCParseFriendFinderDelegate> delegate in delegates)
    {
        if ([delegate respondsToSelector:@selector(didUpdateFriendsSearchResultWithSuccess:andError:andCCUsersThatAreFriends:)])
            [delegate didUpdateFriendsSearchResultWithSuccess:succes andError:error andCCUsersThatAreFriends:friends];
    }
}

@end
