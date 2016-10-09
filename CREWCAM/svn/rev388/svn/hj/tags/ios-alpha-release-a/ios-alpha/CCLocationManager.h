//
//  LocationManager.h
//  ios
//
//  Created by Ryan Brink on 12-04-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h> 

@interface CCLocationManager : NSObject <CLLocationManagerDelegate>

- (void)startStandardUpdates;
- (CLLocation *)getCurrentLocation;

@end
