//
//  CCConnectorUploadVideoCompleteDelegate.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCServerStoredObject.h"


@protocol CCConnectorPostObjectCompleteDelegate <NSObject>

@required
- (void)objectPostSuccessWithType:(int)objectType;
- (void)objectPostFailedWithType:(int)objectType reason:(NSString *)reason;

@end
