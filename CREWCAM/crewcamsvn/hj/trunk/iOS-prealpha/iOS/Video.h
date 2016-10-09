//
//  Video.h
//  iOS
//
//  Created by Ryan Brink on 12-04-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Video : NSObject

{
    @private NSString *videoCreator;
    @private NSArray *videoTags;
    @private NSString *videoTitle;
    @private NSString *videoUrl;
    @private UIImage* videoImage;    
    @private NSString *videoImageUrl;
    @private NSString *objectId;
    @private int videoOrientation;
    @private CLLocation *videoLocation;
    
}

- (NSString *) getCreator;
- (void) setCreator: (NSString *) creator;

- (NSString *) getTitle;
- (void) setTitle: (NSString *) title;

- (NSArray *) getTags;
- (void) setTags: (NSArray *) tags;

- (NSString *) getUrl;
- (void) setUrl: (NSString *) url;

- (UIImage *) getVideoImage;
- (void) setVideoImage: (UIImage *) image;

- (NSString *) getImageUrl;
- (void) setImageUrl: (NSString *) url;

-(NSString *) getVideoID;
- (void) setVideoID: (NSString *) ID;

- (int) getVideoOrientation;
- (void) setVideoOrientation: (int)orientation;

- (CLLocation *) getVideoLocation;
- (void) setVideoLocation: (CLLocation *)location;

@end
