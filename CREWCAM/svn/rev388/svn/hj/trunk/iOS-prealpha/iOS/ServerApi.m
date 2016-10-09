//
//  ServerApi.m
//  iOS
//
//  Created by Development on 12-04-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerApi.h"
#import <CoreLocation/CoreLocation.h>

@implementation ServerApi

+ (NSInteger) createUser:(NSString *)userName:(NSString *)password:(NSString *)password2 {
    
    if ([password isEqualToString:password2]) {
        
        PFUser *user = [PFUser user];
        user.username = userName;
        user.password = password;
        //user.email = NSNull;
        NSError * error;
        [user signUp: &error];
        
        if (error){
            NSLog(@"LOGIN CREATIOON ERROR: %@ %@", error, [error userInfo]);
            return -1;
        }
        
    } else 
        return -1;
    
    return 0;
}


+ (NSInteger) userLogin:(NSString *)userName:(NSString *)password {
    PFUser *user;
    NSError * error;
    
    [PFUser logOut];
    
    if ( !(user = [PFUser logInWithUsername:userName password:password error:&error])){
        NSLog(@"LOGIN ERROR: %@ %@", error, [error userInfo]);
        return -1;
    }
        
    
    NSLog(@"USERNAME: %@", user.username);
    
    return 0;
}

+ (void) userLogOut {
    [PFUser logOut];
}

+ (NSInteger) uploadVideo:(NSString *)tags:(NSString *)title:(NSData *)videoData:(NSData*)videoImageData:(int)orientation{
    
    NSArray *textTags = [tags componentsSeparatedByString:@" "];
    PFQuery *querries[[textTags count]];
    PFUser *user;
    NSError *error;
    
    if ((user =[PFUser currentUser]) == nil)
        return -1;
    
    for (int i = 0; i < [textTags count]; i++) {
        querries[i] = [PFQuery queryWithClassName:@"Tag"];
        [querries[i] whereKey:@"name" matchesRegex:[textTags objectAtIndex:i] modifiers:@"i"];
    }
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:querries count:[textTags count]]];

    NSArray *results = [query findObjects:&error];
    if (error) {
        NSLog(@"TAG QUERY ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
        return -1;
    }
    
    if ([results count] < [textTags count]) {
        BOOL found = false;
        PFObject *newTag;
        
        for (int i = 0; i < [textTags count]; i++) {
            found = false;
            for (int j = 0; j < [results count]; j++) {
            if ([[textTags objectAtIndex:i] isEqualToString:[[results objectAtIndex:j] objectForKey:@"name"]])
                found = true;
            }
            
            if (!found) {
                newTag = [PFObject objectWithClassName:@"Tag"];
                [newTag setObject:[textTags objectAtIndex:i] forKey:@"name"];
                
                [newTag save:&error];
                if (error) {
                    NSLog(@"TAG SAVE ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
                    return -1;
                }
            }
        }
        
        results = [query findObjects:&error];
        if (error) {
            NSLog(@"TAG QUERY ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
            return -1;
        }
    }

    PFFile *videoFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.MOV",title] data:videoData];
    [videoFile save:&error];
    if (error) {
        NSLog(@"FILE SAVE ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
        return -1;
    }
    
    PFFile *videoImageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpeg",title] data:videoImageData];
    [videoImageFile save:&error];
    if (error) {
        NSLog(@"FILE SAVE ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
        return -1;
    }
    
    CLLocation *location = [LocationManager getCurrentLocation];
    PFGeoPoint *currentLocation;
    if (nil != location)
    {
        // Create a new geopoint with our current location
        currentLocation  = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    }
    
    PFObject *videoObject = [PFObject objectWithClassName:@"Video"];
    [videoObject setObject:currentLocation forKey:@"location"];
    [videoObject setObject:title forKey:@"title"];
    [videoObject setObject:results forKey:@"tags"];
    [videoObject setObject:videoFile forKey:@"videoFile"];
    [videoObject setObject:videoImageFile forKey:@"videoImageFile"];
    [videoObject setObject:user forKey:@"owner"];
    //[videoObject setObject:[NSNumber numberWithInt:orientation] forKey:@"orientation"];
    [videoObject save:&error];
    if (error) {
        NSLog(@"VIDEO OBJECT SAVE ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
        return -1;
    }
        
    return 0;
}

+ (NSArray *) getRecentVideos {
    PFUser *user;   
    NSError *error;
    
    if ((user =[PFUser currentUser]) == nil)
        return nil;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Video"];
    [query includeKey:@"tags"];
    [query includeKey:@"owner"];
    
    [query orderByDescending:@"createdAt"];
    query.limit = 15;
    
    NSDate *start = [NSDate date];
    NSArray *videoObjectArray = [query findObjects:&error];    
    if (error) {
        NSLog(@"VIDEO OBJECT QUERY ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
        return nil;
    }
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@"%f seconds to query", -timeInterval);
    start = [NSDate date];
    
    NSMutableArray *videoArray = [[NSMutableArray alloc] init];
     
    
    for (int i = 0; i < [videoObjectArray count]; i++) {
        Video *videoObject = [[Video alloc] init];
        [videoObject setTitle:[[videoObjectArray objectAtIndex:i] objectForKey:@"title"]];
        [videoObject setVideoID:[[videoObjectArray objectAtIndex:i] objectId]];
        
        [videoObject setUrl:[(PFFile*)[[videoObjectArray objectAtIndex:i] objectForKey:@"videoFile"] url]];
        [videoObject setImageUrl:[(PFFile*)[[videoObjectArray objectAtIndex:i] objectForKey:@"videoImageFile"] url]];
        [videoObject setVideoOrientation:[[[videoObjectArray objectAtIndex:i] objectForKey:@"orientation"] intValue]];
        
        PFGeoPoint *pfVideoLocation = [[videoObjectArray objectAtIndex:i] objectForKey:@"location"];
        
        if (nil != pfVideoLocation)
        {
            CLLocation *videoLocation = [[CLLocation alloc] initWithLatitude:[pfVideoLocation latitude] longitude:[pfVideoLocation longitude]];
            [videoObject setVideoLocation:videoLocation];
        }
        
        PFUser *creator = [[videoObjectArray objectAtIndex:i] objectForKey:@"owner"];
        [creator fetchIfNeeded:&error];
        if (error) {
            NSLog(@"CREATOR FETCH ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
            return nil;
        }
        [videoObject setCreator:[creator username]];
        
        NSArray *tagsArray = [[videoObjectArray objectAtIndex:i] objectForKey:@"tags"];
        
        NSMutableArray *tagNames = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < [tagsArray count]; j++) {
            [[tagsArray objectAtIndex:j] fetchIfNeeded:&error];
            if (error) {
                NSLog(@"TAG OBJECT FETCH ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
                return nil;
            }
            [tagNames addObject:[[tagsArray objectAtIndex:j] objectForKey:@"name"]];
        }
        
        [videoObject setTags:tagNames];
        
        [videoArray addObject:videoObject];
    }
    timeInterval = [start timeIntervalSinceNow];
    NSLog(@"%f seconds to iterate", -timeInterval);
    
    return videoArray;
}

+ (NSArray *) getRecentVideosFromUser:(NSString *) userName {
    PFUser *user; 
    NSError *error;
    
    if ((user =[PFUser currentUser]) == nil)
        return nil;
    
    PFQuery *userQuery = [PFQuery queryForUser];
    [userQuery whereKey:@"username" equalTo:userName];
    PFUser *userResult = (PFUser*)[userQuery getFirstObject:&error];
    if (error) {
        NSLog(@"USER OBJECT QUERY ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
        return nil;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Video"];
    [query whereKey:@"owner" equalTo:userResult];
    [query orderByDescending:@"createdAt"];
    query.limit = 15;
    NSArray *videoObjectArray = [query findObjects:&error];
    if (error) {
        NSLog(@"VIDEO OBJECT QUERY ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
        return nil;
    }
    
    NSMutableArray *videoArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [videoObjectArray count]; i++) {
        Video *videoObject = [[Video alloc] init];
        [videoObject setTitle:[[videoObjectArray objectAtIndex:i] objectForKey:@"title"]];
        [videoObject setVideoID:[[videoObjectArray objectAtIndex:i] objectId]];
        
        [videoObject setUrl:[(PFFile*)[[videoObjectArray objectAtIndex:i] objectForKey:@"videoFile"] url]];
        [videoObject setImageUrl:[(PFFile*)[[videoObjectArray objectAtIndex:i] objectForKey:@"videoImageFile"] url]];
        
        PFUser *creator = [[videoObjectArray objectAtIndex:i] objectForKey:@"owner"];
        [creator fetchIfNeeded:&error];
        if (error) {
            NSLog(@"CREATOR FETCH ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
            return nil;
        }
        [videoObject setCreator:[creator username]];
        
        NSArray *tagsArray = [[videoObjectArray objectAtIndex:i] objectForKey:@"tags"];
        
        NSMutableArray *tagNames = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < [tagsArray count]; j++) {
            [[tagsArray objectAtIndex:j] fetchIfNeeded:&error];
            if (error) {
                NSLog(@"TAG OBJECT FETCH ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
                return nil;
            }
            [tagNames addObject:[[tagsArray objectAtIndex:j] objectForKey:@"name"]];
        }
        
        [videoObject setTags:tagNames];
        
        [videoArray addObject:videoObject];
    }
    
    return videoArray;

}



+ (NSInteger) deleteVideo:(Video*)videoObject {
    NSError *error;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Video"];
    PFObject *videoObjectTBD = [query getObjectWithId:videoObject.getVideoID error:&error];
    if (error) {
        NSLog(@"VIDEO OBJECT QUERY ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
        return -1;
    }
    NSLog(@"ObjectId %@",videoObject.getVideoID);
    [videoObjectTBD delete:&error];
    if (error) {
        NSLog(@"VIDEO OBJECT DELETE ERROR: %d %@ %@", __LINE__,error, [error userInfo]);
        return -1;
    }
    
    return 0;
}

+ (NSInteger) checkVideoPermission:(NSString *) creator {
    if (![[PFUser currentUser].username isEqualToString:creator]) 
        return -1;

    return 0;
}

@end
