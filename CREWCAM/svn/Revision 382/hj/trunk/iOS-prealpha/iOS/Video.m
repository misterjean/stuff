//
//  Video.m
//  iOS
//
//  Created by Ryan Brink on 12-04-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Video.h"

@implementation Video

- (NSString *) getCreator { 
    return videoCreator;   
}

- (void) setCreator: (NSString *) creator {
    if (creator == nil)
        return;
    videoCreator = creator;
}


- (NSString *) getTitle { 
    return videoTitle;   
}

- (void) setTitle: (NSString *) title {
    if (title == nil)
        return;
    videoTitle = title;
}

- (NSArray *) getTags { 
    return videoTags;   
}

- (void) setTags: (NSArray *) tags {
    if (tags == nil)
        return;
    videoTags = tags;
}

- (NSString *) getUrl { 
    return videoUrl;   
}


- (void) setUrl: (NSString *) url {
    if (url == nil)
        return;
    videoUrl = url;
}

- (NSString *) getVideoImage { 
    return videoImageUrl;   
}


- (void) setVideoImage: (NSString *) url {
    if (url == nil)
        return;
    videoImageUrl = url;
}

- (NSString *) getImageUrl { 
    return videoImageUrl;   
}


- (void) setImageUrl: (NSString *) url {
    if (url == nil)
        return;
    videoImageUrl = url;
}


- (NSString *) getVideoID { 
    return objectId;   
}


- (void) setVideoID:(NSString *)ID {
    if (ID == nil)
        return;
    objectId = ID;
}

- (int) getVideoOrientation {
    return videoOrientation;
}

- (void) setVideoOrientation: (int)orientation {
    videoOrientation = orientation;
}

- (CLLocation *) getVideoLocation
{
    return videoLocation;
}

- (void) setVideoLocation: (CLLocation *)location
{
    videoLocation = location;
}

@end
