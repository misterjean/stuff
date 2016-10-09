//
//  CCParseCrew.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CCServerStoredObject.h"
#import "CCParseObject.h"
#import "CCParseVideo.h"
#import "CCCrew.h"

@interface CCParseCrew : CCParseObject <CCCrew>

- (id) initWithData:(PFObject *) crewData;
- (void)loadVideosWithNewThread:(Boolean)useNewThread;

@end
