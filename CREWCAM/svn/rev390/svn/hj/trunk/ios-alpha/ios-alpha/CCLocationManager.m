//
//  LocationManager.m
//  ios
//
//  Created by Ryan Brink on 12-04-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLocationManager.h"

@implementation CCLocationManager
    static CLLocationManager *locationManager;
    static CLLocation *lastLocation;

- (CLLocation *)getCurrentLocation
{
    return lastLocation;
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    
    [locationManager startUpdatingLocation];
}

- (void) stopStandardUpdates
{
    [locationManager stopUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{    
    lastLocation = newLocation;
}

@end
