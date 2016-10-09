//
//  LocationManager.m
//  ios
//
//  Created by Ryan Brink on 12-04-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager
    static CLLocationManager *locationManager;
    static LocationManager *instance;
    static CLLocation *lastLocation;

+ (LocationManager *)getInstance
{
    if (nil == instance)
        instance = [[LocationManager alloc] init];
    
    return instance;    
}

+ (CLLocation *)getCurrentLocation
{
    return lastLocation;
}

+ (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = [LocationManager getInstance];
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    
    [locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    lastLocation = newLocation;
}

@end
