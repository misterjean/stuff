//
//  CustomCell.m
//  iOS
//
//  Created by Desmond McNamee on 12-04-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

@synthesize titleLabel;
@synthesize ownerLabel;
@synthesize locationLabel;
@synthesize thumbNail;
@synthesize tag1;
@synthesize tag2;
@synthesize tag3;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
    {
        //left side
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.frame = CGRectMake(150, 30, 180, 20);
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel]; 
        
        self.ownerLabel = [[UILabel alloc] init];
        self.ownerLabel.frame = CGRectMake(150, 50, 180, 20);
        self.ownerLabel.font = [UIFont boldSystemFontOfSize:12];
        self.ownerLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:ownerLabel]; 
        
        self.locationLabel = [[UILabel alloc] init];
        self.locationLabel.frame = CGRectMake(150, 70, 180, 20);
        self.locationLabel.font = [UIFont boldSystemFontOfSize:12];
        self.locationLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:locationLabel]; 
        
        self.thumbNail = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 100, 100)];
        [self.contentView addSubview:thumbNail];
        
        self.tag1 = [[UIButton alloc] initWithFrame:CGRectMake(150, 100, 180, 20)];
        [self.tag1 addTarget:self action:@selector(tag1Press:) forControlEvents:UIControlEventTouchDown];
        self.tag1.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:tag1];
        
        self.tag2 = [[UIButton alloc] initWithFrame:CGRectMake(150, 120, 180, 20)];
        [self.tag2 addTarget:self action:@selector(tag2Press:) forControlEvents:UIControlEventTouchDown];
        self.tag2.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:tag2];
        
        self.tag3 = [[UIButton alloc] initWithFrame:CGRectMake(150, 140, 180, 20)];
        [self.tag3 addTarget:self action:@selector(tag3Press:) forControlEvents:UIControlEventTouchDown];
        self.tag3.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:tag3];
    }
    
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tag1Press:(id)sender
{
    [delegate setVideoArray:[self getVideosWithTag:tag1.titleLabel.text]];
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(reloadMyTable)]) {
        [delegate reloadMyTable];
    }
}

- (void)tag2Press:(id)sender
{
    [delegate setVideoArray:[self getVideosWithTag:tag2.titleLabel.text]];
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(reloadMyTable)]) {
        [delegate reloadMyTable];
    }
}

- (void)tag3Press:(id)sender
{
    [delegate setVideoArray:[self getVideosWithTag:tag3.titleLabel.text]];
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(reloadMyTable)]) {
        [delegate reloadMyTable];
    }
}

-(NSArray*)getVideosWithTag:(NSString*) tag
{
    NSArray* oldVideoList = [delegate videoArray];
    NSMutableArray* newVideoList = [[NSMutableArray alloc] init];
    Video* currentVideo = [[Video alloc] init];
    NSString* currentTag = [[NSString alloc] init];
    NSArray* currentTags = [[NSArray alloc] init];
    bool validVideo = NO;
    
    for (int i = 0; i < oldVideoList.count; i++)
    {
        currentVideo = (Video*)[oldVideoList objectAtIndex:i];
        currentTags = [currentVideo getTags];
        for(int j = 0; j < currentTags.count; j++)
        {
            currentTag = (NSString*)[currentTags objectAtIndex:j];
            if ([currentTag compare:tag] ==  NSOrderedSame) {
                NSLog(@"Valid video %@", tag);
                validVideo = YES;
            }
        }
        if (validVideo == YES)
        {
            [newVideoList addObject:currentVideo];
        }
        validVideo = NO;
    }
    NSArray* temp =[NSArray arrayWithArray:newVideoList];
    return temp;
}

@end


