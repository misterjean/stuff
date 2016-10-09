//
//  CCParseComment.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-05-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseComment.h"

@implementation CCParseComment

static NSString *className = @"Comment";

// Required CCServerStoredObject methods

+ (void) createNewCommentInBackGroundWithText:(NSString *)text withBlockOrNil:(CCCommentResultBlock) block
{
    PFObject *newComment = [PFObject objectWithClassName:@"Comment"];
    
    [newComment setObject:text forKey:@"comment"];    
    [newComment setObject:[PFUser currentUser] forKey:@"commenter"];
    
    CCParseComment *newCCComment = [[CCParseComment alloc] initWithServerData:newComment];
    
    [newCCComment pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
        if (error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to create new comment: %@", [error localizedDescription]];
        }
        
        if (block)
            block(newCCComment, succeeded, error);
    }];
}

- (void)initialize
{
}


- (NSString *) getCommentText
{
    [self checkForParseDataAndThrowExceptionIfNil];
    
    return [[self parseObject] objectForKey:@"comment"];
}

- (id<CCUser>) getCommenter
{
    [self checkForParseDataAndThrowExceptionIfNil];    
    
    return [[CCParseUser alloc] initWithServerData:[[self parseObject] objectForKey:@"commenter"]];
}

@end
