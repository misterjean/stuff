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

// CCServerStoredObject properties
@synthesize name;
@synthesize objectID;

// CCVideo properties
@synthesize location;
@synthesize likes;
@synthesize owner;
@synthesize createdDate;
@synthesize localTempVideoFilePath;
@synthesize serverNewObjectDelegate;
@synthesize videoCrews;
@synthesize videoURL;
@synthesize videoImageURL;
@synthesize videoImageData;

- (id) initWithData:(PFObject *) videoData
{
    self = [super initWithData:videoData];
    
    NSError *error;
    
    if (self != nil)
    {
        [self setLikes:[[NSMutableArray alloc] init]];
#warning FIXME: if videos are deleted manually from the database and still hold a reference in the crew this could be NSNull class
        [self setObjectID:[videoData objectForKey:@"objectId"]];
        [self setName:[videoData objectForKey:@"videoName"]];
        [self setCreatedDate:videoData.createdAt];        
        
        if ([[videoData objectForKey:@"videoFile"] class] != [NSNull class])
        {
            [self setVideoURL:[(PFFile*)[videoData objectForKey:@"videoFile"] url]];
        }
        
        if ([[videoData objectForKey:@"videoThumbnail"] class] != [NSNull class]) {
            [self setVideoImageURL:[(PFFile*)[videoData objectForKey:@"videoThumbnail"] url]];
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
        
        
    }
    
    return self;
}

- (id<CCVideo>)initLocalVideoWithName:(NSString *)videoName createdBy:(id<CCUser>)creator videoFile:(NSString *)videoFile crews:(NSArray *)crews
{
    self = [super init];
    
    if (self != nil)
    {
        [self setName:videoName];
        [self setOwner:creator];
        [self setLocalTempVideoFilePath:videoFile];
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

- (void)pushObjectWithNewThread:(Boolean)useNewThread delegateOrNil:(id<CCConnectorPostObjectCompleteDelegate>)delegateOrNil
{
    if (delegateOrNil != nil) 
    {
        serverNewObjectDelegate = delegateOrNil;
    }

    if (localTempVideoFilePath != nil && owner != nil && name !=nil)
    {
        [self uploadVideoWithUseNewThread:useNewThread];
    }
    else 
    {
#warning this notification needs to be done on a seperate thread
        [serverNewObjectDelegate objectPostFailedWithType:ccVideo reason:@"CCParseVideo recieved a nil localTempVideoFilePath or owner or name"];
    }


}

- (void)pullObjectWithNewThread:(Boolean)useNewThread
{
    
}

-(void)like
{
    
}

- (void)safelyNotifyObjectUploadCallBackOnNewThreadWithError:(NSError *)error
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async( dispatch_get_main_queue(), ^{
            if (serverNewObjectDelegate != nil)
                [serverNewObjectDelegate objectPostFailedWithType:ccVideo reason:[error description]];
        });
    });
}

//Helper methods

-(void)uploadVideoWithUseNewThread:(Boolean)useNewThread
{
    NSData *videoData = [NSData dataWithContentsOfFile: localTempVideoFilePath];
    NSCharacterSet *nonalphanumericSet = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
    NSString *alphaNumericName =  [[name componentsSeparatedByCharactersInSet:nonalphanumericSet] componentsJoinedByString:@""];
    if([alphaNumericName length] == 0)
    {
        alphaNumericName = @"realname";
    }
    PFFile *videoFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.MOV", alphaNumericName] data:videoData];

    [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
    {
        if(error)
        {
            [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload video: %@", [error localizedDescription]];
            
            [self safelyNotifyObjectUploadCallBackOnNewThreadWithError:error];
            return;
        }
        else 
        {
            // Post the Video class associated with the file
            PFUser *user = [PFUser currentUser];
    		[self setVideoURL:[videoFile url]];
    
    		[self setVideoImageData:[self generateThumbnailWithVideoPath:localTempVideoFilePath]];
    		
            PFFile *videoImageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpeg",alphaNumericName] data:videoImageData];
    		
            [videoImageFile save:&error];

            [self setVideoImageURL:[videoImageFile url]];
    		if (error) 
            {
        		[[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to upload thumbnail for video \"@%\": %@", name, [error localizedDescription]];
    		}
    
    		PFObject *videoObject = [PFObject objectWithClassName:@"Video"];
    		[videoObject setObject:name forKey:@"videoName"];
    		[videoObject setObject:videoFile forKey:@"videoFile"];
    		[videoObject setObject:videoImageFile forKey:@"videoThumbnail"];
    		[videoObject setObject:user forKey:@"theOwner"];
            
            CLLocation *currentCLLocation = [[[CCCoreManager sharedInstance] locationManager] getCurrentLocation];
            PFGeoPoint *currentLocation;
            if (nil != currentCLLocation)
            {
                // Create a new geopoint with our current location
                currentLocation  = [PFGeoPoint geoPointWithLatitude:currentCLLocation.coordinate.latitude longitude:currentCLLocation.coordinate.longitude];
            }
            
            [videoObject setObject:currentLocation forKey:@"takenAt"];            

            if(useNewThread)
            {
                [videoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) 
                    {
                        [self setParseObject:videoObject];
                        [self addVideoToCrews];
                        
                        if (serverNewObjectDelegate != nil)
                            [serverNewObjectDelegate objectPostSuccessWithType:ccVideo];
                    } 
                    else 
                    {
                        if (serverNewObjectDelegate != nil)
                            [serverNewObjectDelegate objectPostFailedWithType:ccVideo reason:[error description]];
                    }
                }];
            }
            else
            {
#warning I don't think this non-new-thread side works, but we're probably not using it right now
                [videoObject save:&error];
                if (error)
                {
                    [[[CCCoreManager sharedInstance] logger] logAtLogLevel:ccLogLevelError message:@"Unable to save video object: %@", [error localizedDescription]];
                }  
                
                [self safelyNotifyObjectUploadCallBackOnNewThreadWithError:error];
            }   
            
        }
        
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

- (void) addVideoToCrews
{
    for(int i =0; i<[videoCrews count]; i++)
    {
        id<CCCrew> thisCrew = [[self videoCrews] objectAtIndex:i];
        
        [thisCrew addVideo:self];

        NSString *newVideoMessage = [[NSString alloc] initWithFormat:@"%@ added a new video to the crew \"%@\"!", [[self owner] name], [thisCrew name] ];
        
        [thisCrew sendNotificationWithMessage:newVideoMessage];
        
        [thisCrew pushObjectWithNewThread:YES delegateOrNil:nil];
    }
}

@end
