//
//  CCParseVideo.m
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCParseVideo.h"
#import <CoreLocation/CoreLocation.h>

@implementation CCParseVideo

// CCVideo properties
@synthesize location;
@synthesize likes;
@synthesize owner;
@synthesize createdDate;
@synthesize localTempVideoFilePath;
@synthesize videoCrews;
@synthesize videoURL;
@synthesize videoImageURL;
@synthesize videoImageData;
@synthesize usersThatWatched;
@synthesize comments;

// CCParseVideoProperties
@synthesize videoFile;
@synthesize videoImageFile;

- (id) initWithData:(PFObject *) videoData
{
    self = [super initWithData:videoData];
    
    if (self != nil)
    {
        [self setLikes:[[NSMutableArray alloc] init]];
        [self setUsersThatWatched:[[NSMutableArray alloc] init]];
        [self setComments:[[NSMutableArray alloc] init]];
#warning FIXME: if videos are deleted manually from the database and still hold a reference in the crew this could be NSNull class
        [self setObjectID:[videoData objectForKey:@"objectId"]];
        [self setName:[videoData objectForKey:@"videoName"]];
        [self setCreatedDate:videoData.createdAt];        
        
        if ([[videoData objectForKey:@"videoFile"] class] != [NSNull class])
        {
            [self setVideoURL:[(PFFile*)[videoData objectForKey:@"videoFile"] url]];
            [self setVideoFile:[videoData objectForKey:@"videoFile"]];
        }
        
        if ([[videoData objectForKey:@"videoThumbnail"] class] != [NSNull class]) {
            [self setVideoImageURL:[(PFFile*)[videoData objectForKey:@"videoThumbnail"] url]];
            [self setVideoFile:[videoData objectForKey:@"videoThumbnail"]];
        }
        
        //Convert the passed
        if ([[videoData objectForKey:@"watchedBy"] class] != [NSNull class])
        {
            NSArray *tempWatchedByArray = [videoData objectForKey:@"watchedBy"];    

            for (int tempwatchedByIndex = 0; tempwatchedByIndex < [[videoData objectForKey:@"watchedBy"] count]; tempwatchedByIndex++)
            {
                if([[tempWatchedByArray objectAtIndex: tempwatchedByIndex] class] != [NSNull class])
                {
                    id<CCUser> thisUser = [[CCParseUser alloc] initWithData:[tempWatchedByArray objectAtIndex: tempwatchedByIndex]];
                    if (thisUser)
                        [usersThatWatched addObject:thisUser];
                }
                
            }
        }
        
        // Start downloading the thumbnail on a new thread
        [self loadThumbnailWithNewThread:YES];
        
        // Save the video's location
        PFGeoPoint *pfVideoLocation = [videoData objectForKey:@"takenAt"];            
        if (nil != pfVideoLocation)
        {
            [self setLocation:[[CLLocation alloc] initWithLatitude:[pfVideoLocation latitude] longitude:[pfVideoLocation longitude]]];
        }
        
        // Download the creator data if we haven't cached it already
        PFUser *creator = [videoData objectForKey:@"theOwner"];
        [creator fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) 
        {
            if (!error)
            {
                [self setOwner:[[CCParseUser alloc] initWithData:creator]];
            }
        }];
        
        NSArray *parseComments = [videoData objectForKey:@"videoComments"];
        for (int parseCommentsIndex = 0; parseCommentsIndex < [parseComments count]; parseCommentsIndex++) 
        {
            [comments addObject:[[CCParseComment alloc] initWithData:[parseComments objectAtIndex:parseCommentsIndex]]];
        }
        
    }
    
    return self;
}

- (id<CCVideo>)initLocalVideoWithName:(NSString *)videoName createdBy:(id<CCUser>)creator videoFile:(NSString *)videoFilePath crews:(NSArray *)crews
{
    self = [super init];
    
    if (self != nil)
    {
        [self setName:videoName];
        [self setOwner:creator];
        [self setLocalTempVideoFilePath:videoFilePath];
        [self setVideoCrews:crews];
        [self setCreatedDate:[NSDate date]];
    }
    
    return self;
}

- (void)loadThumbnailWithNewThread:(Boolean) useNewThread
{
    if (useNewThread)
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{            
            [self setVideoImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:videoImageURL]]];            
        });
    }
    else
    {
        [self setVideoImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:videoImageURL]]];
    }
}

- (void)uploadVideoWithProgressIndicatorOrNil:(id<CCServerUploadVideoDelegate>)delegate block:(CCBooleanResultBlock)block
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *videoData = [NSData dataWithContentsOfFile: localTempVideoFilePath];
        
        NSCharacterSet *nonalphanumericSet = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
        NSString *alphaNumericName =  [[[self name] componentsSeparatedByCharactersInSet:nonalphanumericSet] componentsJoinedByString:@""];
        
        if([alphaNumericName length] == 0)
        {
            alphaNumericName = @"realname";
        }
        
        videoFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.MOV", alphaNumericName] data:videoData];

        [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
         {                          
             if (error) 
             {
                 [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload video \"@%\": %@", [self name], [error localizedDescription]];
             }
             else 
             {
                 [self setVideoImageURL:[videoImageFile url]];
                 [self setVideoURL:[videoFile url]];
                 
                 [self setVideoImageData:[self generateThumbnailWithVideoPath:localTempVideoFilePath]];
                 
                 videoImageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpeg",alphaNumericName] data:videoImageData];
                 
                 [videoImageFile save:&error];
                 
                 [self setVideoImageURL:[videoImageFile url]];
                 
                 if (error) 
                 {
                     block(NO, error);
                 }   
                 else 
                 {
                     block(YES, nil);
                 }                 
             }
             
         } progressBlock:^(int percentDone) {
             dispatch_async( dispatch_get_main_queue(), ^{
                 if (delegate != nil)
                     [delegate videoUploadProgressIsAtPercent:percentDone];
             });
         }];                 
    });    
}

- (void)pushObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
    if (localTempVideoFilePath == nil || owner == nil || [self name] ==nil )
    {
        if (block)
            block(NO, [[NSError alloc] init]);
        return;
    }
    
    // Post the Video class associated with the file
    PFUser *user = [PFUser currentUser];    
    
    PFObject *videoObject = [PFObject objectWithClassName:@"Video"];
    [videoObject setObject:[self name] forKey:@"videoName"];
    [videoObject setObject:[self videoFile] forKey:@"videoFile"];
    [videoObject setObject:[self videoImageFile] forKey:@"videoThumbnail"];
    [videoObject setObject:user forKey:@"theOwner"];
    
    CLLocation *currentCLLocation = [[[CCCoreManager sharedInstance] locationManager] getCurrentLocation];
    PFGeoPoint *currentLocation;
    if (nil != currentCLLocation)
    {
        // Create a new geopoint with our current location
        currentLocation  = [PFGeoPoint geoPointWithLatitude:currentCLLocation.coordinate.latitude longitude:currentCLLocation.coordinate.longitude];
        
        [videoObject setObject:currentLocation forKey:@"takenAt"];
    }
    
    [videoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
    {
        if (!error) 
        {
            [self setParseObject:videoObject];
            [self addVideoToCrewsWithBlockOrNil:^(BOOL succeeded, NSError *error) 
            {
                if (!error)
                {
                    if (block)
                        block(NO, error);
                }
                else 
                {
                    if (block)
                        block(YES, nil);
                }
            }];            
        } 
        else 
        {
            if (block)
                block(NO, error);
        }
    }];
}

- (void)pullObjectWithBlockOrNil:(CCBooleanResultBlock)block
{
#warning Doesn't do anything.  Duh.    
}

-(void)like
{
    
}


-(void) addComment:(NSString *) text
{
    CCParseComment *comment = [[CCParseComment alloc] initLocalCommentCreatedBy:[[[CCCoreManager sharedInstance] server] currentUser] message:text];
    
    [comment pushObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
    {
        [[self comments] insertObject:comment atIndex:0]; 
        
        NSArray *parseComments = [[NSArray alloc] initWithArray:[self getArrayOfPFObjectsFromObjects:[self comments]]];
        
        [[self parseObject] setObject:parseComments forKey:@"videoComments"];
        
        [[self parseObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) 
            {
                [[[CCCoreManager sharedInstance]logger] logAtLogLevel:ccLogLevelError message:@"failed to add videoComments to video"];
            }
        }];
        
    }];
}

- (NSData *)generateThumbnailWithVideoPath:(NSString *)videoPath
{
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    CMTime capturePoint = CMTimeMakeWithSeconds(0.1, 600);
    CMTime actualTime;
    UIImage *imageForUse;
    NSError *error;
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    CGImageRef capturedImage = [imageGenerator copyCGImageAtTime:capturePoint actualTime:&actualTime error:&error];
    imageForUse = [[UIImage alloc] initWithCGImage:capturedImage scale:(CGFloat)1.0 orientation:(UIImageOrientation)UIImageOrientationRight];
    
    return UIImageJPEGRepresentation(imageForUse, 0.1);        
}

- (void) addVideoToCrewsWithBlockOrNil:(CCBooleanResultBlock)block
{
    for(int i =0; i<[videoCrews count]; i++)
    {
        id<CCCrew> thisCrew = [[self videoCrews] objectAtIndex:i];
        
        [thisCrew pullObjectWithBlockOrNil:^(BOOL succeeded, NSError *error) 
        {
            if (error)
            {  
                if (block)
                    block(NO, error);
            }
            else 
            {
                [thisCrew addVideo:self];
                
                NSString *newVideoMessage = [[NSString alloc] initWithFormat:@"%@ added a new video to the crew \"%@\"!", [[self owner] name], [thisCrew name] ];
                NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:newVideoMessage, @"alert",
                                             [NSNumber numberWithInt:1], @"badge",
                                             [[[[CCCoreManager sharedInstance] server] currentUser] objectID], @"src_User",
                                             @"type_video", @"type",
                                             nil];
                
                [thisCrew sendNotificationWithData:messageData];
                
                [thisCrew pushObjectWithBlockOrNil:nil];                                   
            }                    
        }];        
    }
    
    // Hmm... in theory this could be called even though a push failed.
    if (block)
        block(YES, nil);
}

- (void)addWatchedByWithUser:(id<CCUser>)user
{
#warning the following code could cause data sync issues... Parse should be releasing a fix for this
    if (![[self usersThatWatched] containsObject:user])
    {
        [[self usersThatWatched] addObject:user];
        if ([self usersThatWatched] != nil)
        {
            NSArray *parseUsers = [[NSArray alloc] initWithArray:[self getArrayOfPFObjectsFromObjects:[self usersThatWatched]]];
            
            if (parseUsers != nil)
            {
                [[self parseObject] setObject:parseUsers forKey:@"watchedBy"];
                
                [[self parseObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) 
                    {
                        [[[CCCoreManager sharedInstance]logger] logAtLogLevel:ccLogLevelError message:@"failed to add watchedBy to video"];
                    }
                }];
            }
            
        }
    }
}

@end
