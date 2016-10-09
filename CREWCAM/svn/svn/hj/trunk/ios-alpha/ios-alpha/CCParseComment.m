//
//  CCParseComment.m
//  Crewcam
//
//  Created by Gregory Flatt on 12-05-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseComment.h"

@implementation CCParseComment

@synthesize author;
@synthesize commentText;

- (CCParseComment *) initWithData:(PFObject *)commentData
{
    self = [super initWithData:commentData];
    
    if (self != nil)
    {
        [self setCommentText:[commentData objectForKey:@"text"]];
        [self setAuthor:[[CCParseUser alloc]initWithData:[commentData objectForKey:@"Author"]]];
        [self setObjectID:[commentData objectId]];
    }
    
    return self;
}


- (id<CCComment>)initLocalCommentCreatedBy:(id<CCUser>)creator message:(NSString *)text
{
    
    self = [super init];
    
    if (self != nil)
    {
        [self setAuthor:creator];
        [self setCommentText:text];
    }
    
    return self;
}

- (void)pushObjectWithBlockOrNil:(CCBooleanResultBlock)block
{    
    PFObject *newComment = [PFObject objectWithClassName:@"Comment"];
    
    [newComment setObject:[PFUser currentUser] forKey:@"Author"];
    [newComment setObject:commentText forKey:@"text"];
    
    [self setParseObject:newComment];
    
    [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
    {
        if (error)
        {
            if (block)
                block(NO, error);            
        }
        else 
        {
            if (block)
                block(YES, nil);
            
        }
    }];
}

@end
