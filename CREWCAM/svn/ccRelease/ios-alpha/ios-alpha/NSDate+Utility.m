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
        float minutesSince = timeSincePosting/60;
        
        if (minutesSince < 2)
        {
            timeSinceString = [[NSString alloc] initWithFormat:@"%.f minute ago", minutesSince];
        }
        else
        {
            timeSinceString = [[NSString alloc] initWithFormat:@"%.f minutes ago", minutesSince];
        }
    }    
    else if (timeSincePosting/60/60 < 24)
    {
        float hoursSince = timeSincePosting/60/60;
        
        if (hoursSince < 2)
        {
            timeSinceString = [[NSString alloc] initWithFormat:@"%.f hour ago", hoursSince];
        }
        else
        {
            timeSinceString = [[NSString alloc] initWithFormat:@"%.f hours ago", hoursSince];
        }
    }
    else if (timeSincePosting/60/60 < 24*31)
    {
        float daysSince = timeSincePosting/60/60/24;
        
        if (daysSince < 2)
        {
            timeSinceString = [[NSString alloc] initWithFormat:@"%.f day ago", daysSince];
        }
        else
        {
            timeSinceString = [[NSString alloc] initWithFormat:@"%.f days ago", daysSince];
        }
    }
    else 
    {
        float monthsSince = timeSincePosting/60/60/24/31;
        
        if (monthsSince < 2)
        {
            timeSinceString = [[NSString alloc] initWithFormat:@"%.f month ago", monthsSince];
        }
        else
        {
            timeSinceString = [[NSString alloc] initWithFormat:@"%.f months ago", monthsSince];
        }            
    }
    
    return timeSinceString;
}
@end
