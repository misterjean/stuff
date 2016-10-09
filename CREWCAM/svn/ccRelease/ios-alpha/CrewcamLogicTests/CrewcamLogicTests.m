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
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSCondition *waitForCompletion = [[NSCondition alloc] init];
    [[[CCCoreManager sharedInstance] server] startEmailAuthenticationInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) {
        STAssertNil(user, @"Unable to authenticate with Parse");
        [waitForCompletion signal];
        [waitForCompletion unlock];
    } andEmail:TEST_USER_USERNAME andPassword:TEST_USER_PASSWORD isNewUser:NO];
    
    [waitForCompletion lock];
    [waitForCompletion wait];
    NSLog(@"Complete");
}

@end
