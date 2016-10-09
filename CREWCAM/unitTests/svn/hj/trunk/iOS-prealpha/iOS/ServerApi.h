//
//  ServerApi.h
//  iOS
//
//  Created by Development on 12-04-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Video.h"
#import "LocationManager.h"

@interface ServerApi : NSObject

+ (NSInteger) createUser:(NSString *)userName:(NSString *)password:(NSString *)password2;
+ (NSInteger) userLogin:(NSString *)userName:(NSString *)password;
+ (void) userLogOut;

+ (NSInteger) uploadVideo:(NSString *)tags:(NSString *)title :(NSData *)videoData: (NSData*)videoImageData: (int)orientation;

+ (NSArray *) getRecentVideos;
+ (NSArray *) getRecentVideosFromUser:(NSString *) userName;


+ (NSInteger) deleteVideo:(Video *)videoObject;

+ (NSInteger) checkVideoPermission:(NSString *)creator;

@end
