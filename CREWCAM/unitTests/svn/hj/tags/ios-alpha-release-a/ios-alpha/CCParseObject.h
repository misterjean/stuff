//
//  CCParseObject.h
//  ios-alpha
//
//  Created by Ryan Brink on 12-04-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface CCParseObject : NSObject

- (void)deleteObjectWithNewThread:(Boolean)useNewThread;
- (id) initWithData:(PFObject *) parseData;
- (NSArray *)getArrayOfPFObjectsFromObjects:(NSArray *)object;

@property (strong, nonatomic) PFObject *parseObject;

@end
