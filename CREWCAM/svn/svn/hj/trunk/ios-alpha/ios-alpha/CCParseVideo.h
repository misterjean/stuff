//
//  CCParseVideo.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCVideo.h"
#import "CCUser.h"
#import <Parse/Parse.h>
#import "CCParseUser.h"
#import "CCParseObject.h"
#import "CCParseComment.h"
#import "CCServerStoredObject.h"
#import "CCCrew.h"

@interface CCParseVideo : CCParseObject <CCVideo>

- (id) initWithData:(PFObject *) videoData;

@property (strong, nonatomic) PFFile                                        *videoImageFile;
@property (strong, nonatomic) PFFile                                        *videoFile;

@end
