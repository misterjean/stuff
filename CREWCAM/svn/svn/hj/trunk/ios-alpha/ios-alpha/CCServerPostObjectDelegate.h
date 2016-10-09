//
//  CCServerNewVideoDelegate.h
//  Crewcam
//
//  Created by Desmond McNamee on 12-05-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCServerUploadVideoDelegate <NSObject>

@required
-(void) videoUploadSuccessToGUI;
-(void) videoUploadFailedWithReasonToGUI:(NSString *)reason;
-(void) videoUploadProgressIsAtPercent:(int)percent;

@end
