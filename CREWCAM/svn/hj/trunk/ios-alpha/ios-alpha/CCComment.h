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

@protocol CCComment <CCServerStoredObject>

@required

//Factory Creation method
+ (void) createNewCommentInBackGroundWithText:(NSString *)text withBlockOrNil:(CCCommentResultBlock)block;

// Getter/Setter methods
- (NSString *) getCommentText;
- (id<CCUser>) getCommenter;

@end