//
//  CCComment.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-05-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCServerStoredObject.h"
#import "CCUser.h"
//#import "CCVideo.h"

@protocol CCComment <CCServerStoredObject>

@required

//Requiered Methods

- (id<CCComment>)initLocalCommentCreatedBy:(id<CCUser>)creator message:(NSString *)text;


// Required properties
@property (strong, nonatomic) id<CCUser> author;
@property (strong, nonatomic) NSString *commentText;

@end