//
//  CCCrewTableCell.m
//  Crewcam
//
//  Created by Ryan Brink on 12-05-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCrewTableViewCell.h"

@implementation CCCrewTableViewCell
@synthesize crewNameLabel;
@synthesize numberOfVideosLabel;
@synthesize numberOfMembersLabel;
@synthesize numberOfUnwatchedVideosLabel;
@synthesize unwatchedVideosBadge;
@synthesize crewActivityIndicator;

@synthesize crew;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) 
    {
                                           
    }
    
    return self;
}

- (void)dealloc
{
    [crew removeCrewUpdateListener:self];
    [crew removeListener:self];
    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserUpdateListener:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setNumberOfVideosLabel
{
    NSString *videosString;
    if ([crew getNumberOfVideos] == 1)
    {
        videosString = [[NSString alloc] initWithFormat:@"one video"];
    }
    else 
    {
        videosString = [[NSString alloc] initWithFormat:@"%d videos", [crew getNumberOfVideos]];    
    }
    
    [numberOfVideosLabel setText:videosString];
}

- (void)setNumberOfMembersLabel
{
    NSString *membersString;
    if ([crew getNumberOfMembers] == 1)
    {
        membersString =  [[NSString alloc] initWithFormat:@"one member"];
    }
    else 
    {
        membersString = [[NSString alloc] initWithFormat:@"%d members", [crew getNumberOfMembers]];    
    }
    
    [numberOfMembersLabel setText:membersString]; 
}

- (void)setCrew:(id<CCCrew>) crewForCell
{
    [crew removeCrewUpdateListener:self];
    
    crew = crewForCell;
    
    [crew addCrewUpdateListener:self];
    [crew addListener:self];
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
    
    [crewNameLabel setText:[crew getName]];
    
    if ([crew isBusy])
        [crewActivityIndicator setHidden:NO];
    else
        [crewActivityIndicator setHidden:YES];
    
    if([crew numberOfNewVideos] > 0)
    {
        [[self numberOfUnwatchedVideosLabel] setText:[[NSString alloc] initWithFormat:@"%d", [crew numberOfNewVideos]]]; 
        [unwatchedVideosBadge setHidden:NO];
    }
    else 
    {
        [[self numberOfUnwatchedVideosLabel] setText:@""];
        [unwatchedVideosBadge setHidden:YES];
    }
        
    
    [self setNumberOfVideosLabel];
    
    [self setNumberOfMembersLabel];  
}

- (void) startingToLeaveCrew:(id<CCCrew>) crewBeingLeft
{
    if ([[crewBeingLeft getObjectID] isEqualToString:[crew getObjectID]])
        [crewActivityIndicator setHidden:NO];    
}

- (void) startedDeletingObject:(id<CCServerStoredObject>)object
{
    [crewActivityIndicator setHidden:NO];    
}

- (void) finishedDeletingObject:(id<CCServerStoredObject>)object withSuccess:(BOOL)succes andError:(NSError *)error
{
    [crewActivityIndicator setHidden:YES];    
}

- (void) startedPullingObject:(id<CCServerStoredObject>)object
{
    [crewActivityIndicator setHidden:NO];    
}

- (void) finishedPullingObject:(id<CCServerStoredObject>)object withSuccess:(BOOL)succes andError:(NSError *)error
{
    [crewActivityIndicator setHidden:YES];        
}

- (void) startingToLoadMembers
{
    [crewActivityIndicator setHidden:NO];
}

- (void) finishedLoadingMembersWithSuccess:(BOOL)successful andError:(NSError *)error
{
    [crewActivityIndicator setHidden:YES];
    
    [self setNumberOfMembersLabel];
}

- (void) startingToLoadVideos
{
    [crewActivityIndicator setHidden:NO];
}

- (void) finishedLoadingVideosWithSuccess:(BOOL)successful andError:(NSError *)error
{
    [crewActivityIndicator setHidden:YES];
    
    [self setNumberOfVideosLabel];
}

- (void) finishedLoadingNumberOfNewVideos:(int) numberOfNewVideos
{
    [crewActivityIndicator setHidden:YES];
    
    if (numberOfNewVideos == 0)
    {
        [unwatchedVideosBadge setHidden:YES];
        [[self numberOfUnwatchedVideosLabel] setText:[[NSString alloc] init]];
    }
    else 
    {
        [unwatchedVideosBadge setHidden:NO];
        [[self numberOfUnwatchedVideosLabel] setText:[[NSString alloc] initWithFormat:@"%d", numberOfNewVideos]];
    }
}

@end
