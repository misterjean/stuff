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

@protocol CCVideoFilesUpdatesDelegate <NSObject>

@optional
- (void) startingToUplaodVideoFiles;
- (void) finishedUploadingVideoFilesWithSucces:(BOOL) successful error:(NSError *) error andVideoFilesReference:(id<CCVideoFiles>) videoFiles;
- (void) videoFilesUploadProgressIsAtPercent:(int) percent;

@end


@protocol CCVideoFiles <NSObject>


@required

@property ccMediaSources videoMediaSource;

+ (id<CCVideoFiles>) createNewVideoFilesWithName:(NSString *)name mediaSource:(ccMediaSources)mediaSource delegate:(id<CCVideoFilesUpdatesDelegate>)delegate andVideoPath:(NSString *)videoPath;

- (void) uploadAndSaveInBackgroundWithBlock:(CCBooleanResultBlock)block;



//Notifier Methods
@property (strong, atomic) NSMutableArray *videoFilesUpdatesDelegates;
- (void) addVideoFilesUpdateListener:(id<CCVideoFilesUpdatesDelegate>) delegate;
- (void) removeVideoFilesUpdateListener:(id<CCVideoFilesUpdatesDelegate>) delegate;

@end