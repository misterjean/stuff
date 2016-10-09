//
//  CCParseStringManager.h
//  Crewcam
//
//  Created by Ryan Brink on 12-06-25.
//
//

#import <Foundation/Foundation.h>
#import "CCStringManager.h"

@interface CCParseStringManager : NSObject <CCStringManager>
{
    NSMutableDictionary *serverStringsDictionary;

    uint32_t isLoadingStrings;
}

@end
