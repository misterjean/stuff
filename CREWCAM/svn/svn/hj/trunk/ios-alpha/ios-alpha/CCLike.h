//
//  CCLike.h
//  ios-alpha
//
//  Created by Desmond McNamee on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCServerStoredObject.h"
#import "CCUser.h"

@protocol CCLike <CCServerStoredObject>

@required

// Required methods
- (void)unlike;

// Required properties
@property (strong, nonatomic) id<CCUser> user;

@end
