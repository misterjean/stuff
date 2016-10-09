//
//  CCLogicTests.m
//  Crewcam
//
//  Created by jean-elie jean-gilles on 12-07-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <GHUnitIOS/GHUnit.h>
#import "CCCoreManager.h"
#import "CCGHUnitConstants.h"
#import "CCParseAuthenticator.h"

@interface CCLogicTests : GHAsyncTestCase
@end


@implementation CCLogicTests


-(void) setUp{
    
    [self prepare];
    
    [[[CCCoreManager sharedInstance] server]startEmailAuthenticationInBackgroundWithBlock:^(id<CCUser> user, BOOL succeeded, NSError *error) {
        GHAssertNil(user, @"unable to authenticate with parse");
    } andEmail:TEST_USER_USERNAME andPassword:TEST_USER_PASSWORD isNewUser:TRUE];
}



/*- (void)testStrings {
    NSString *string1 = @"a string";
    GHTestLog(@"I can log to the GHUnit test console: %@", string1);
    
    //assert its not null
    GHAssertNotNil(string1, nil);
    
    //Assert equal objects
    NSString *string2 = @"a string";
    GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
    
}*/



@end
