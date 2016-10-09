//
//  Likable.h
//  iOS
//
//  Created by Ryan Brink on 12-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <User.h>

@protocol Likable <NSObject>

- (BOOL)addLike:(User)likedBy;

@end
