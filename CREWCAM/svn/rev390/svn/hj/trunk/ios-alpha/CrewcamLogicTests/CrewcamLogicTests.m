//
//  CrewcamLogicTests.m
//  CrewcamLogicTests
//
//  Created by Ryan Brink on 12-07-09.
//
//

#import "CrewcamLogicTests.h"

@implementation CrewcamLogicTests

- (void)setUp
{
    [super setUp];
    __block BOOL loginSucceded = NO;
    __block id<CCUser> loggedInUser;
    
    NSCondition *loginLock = [[NSCondition alloc] init];
    
    [[[CCCoreManager sharedInstance] server] startEmailAuthenticationInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) 
    {
        loggedInUser = user;
        loginSucceded = succeeded;
        [loginLock signal];
        [loginLock unlock];
        
    } andEmail:TEST_USER_USERNAME andPassword:TEST_USER_PASSWORD isNewUser:NO];
    
    [loginLock lock];
    [loginLock wait];
    
    STAssertTrue(loginSucceded, @"Login failed");
    STAssertNotNil(loggedInUser, @"Logged in user was nil");
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    
    
    [[[CCCoreManager sharedInstance] server] addNewCrewWithName:@"Test" privacy:CCPublic withBlock:^(id<CCCrew> objectId, BOOL succeeded, NSError *error) {
        STAssertNotNil(objectId, @"Unable to create crew"); 
    }];     
}

@end
