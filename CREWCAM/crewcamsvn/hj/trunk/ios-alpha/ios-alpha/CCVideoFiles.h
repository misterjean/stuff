//
//  CCVideoFiles.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-06-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCServerStoredObject.h"
#import "CCUser.h"

@protocol CCVideoFiles;
@protocol CCVideoUploader;

@protocol CCVideoFilesUpdatesDelegate <NSObject>

@optional
- (void) startingToUploadVideoFiles;
- (void) finishedUploadingVideoFilesWithSucces:(BOOL) successful error:(NSError *) error forUploader:(id<CCVideoUploader>) videoUploader;
- (void) videoFilesUploadProgressIsAtPercent:(int) percent;

@end


@protocol CCVideoFiles <CCServerStoredObject>


@required

@property ccMediaSources videoMediaSource;
@property (strong, nonatomic) NSString      *localVideoLocation;
@property (strong, nonatomic) NSData        *localThumbnailData;

+ (id<CCVideoFiles>) createNewVideoFilesWithName:(NSString *)name mediaSource:(ccMediaSources)mediaSource andVideoPath:(NSString *)videoPath;

- (void) uploadAndSaveInBackgroundWithBlock:(CCBooleanResultBlock)block;
- (void) cancelUpload;

- (NSString *) getVideoMovieFileURL;
- (NSString *) getVideoImageFileURL;

- (NSString *) getVideoMovieFileName;
- (NSString *) getVideoImageFileName;

//Notifier Methods
@property (strong, atomic) NSMutableArray *videoFilesUpdatesDelegates;
- (void) addVideoFilesUpdateListener:(id<CCVideoFilesUpdatesDelegate>) delegate;
- (void) removeVideoFilesUpdateListener:(id<CCVideoFilesUpdatesDelegate>) delegate;

@end