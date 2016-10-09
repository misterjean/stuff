//
//  NSDate+Utility.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-12.
//
//

#import "NSDate+Utility.h"

@implementation NSDate (Utility)
+ (NSString *) getTimeSinceStringFromDate:(NSDate *) date
{
    NSTimeInterval timeSincePosting = [[NSDate date] timeIntervalSinceDate:date];
    
    NSString *timeSinceString;
    
    if (timeSincePosting/60 < 1) 
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"Just Now"];    
    }
    else if (timeSincePosting/60 < 60)
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"%.f minutes ago", timeSincePosting/60];            
    }    
    else if (timeSincePosting/60/60 < 24)
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"%.f hours ago", timeSincePosting/60/60];
    }
    else if (timeSincePosting/60/60 < 24*31)
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"%.f days ago", timeSincePosting/60/60/24];
    }
    else 
    {
        timeSinceString = [[NSString alloc] initWithFormat:@"%.f months ago", timeSincePosting/60/60/24/31];
    }
    
    return timeSinceString;
}
@end
