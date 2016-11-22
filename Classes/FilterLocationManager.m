//
//  FilterLocationManager.m
//  TheFilter
//
//  Created by John Thomas on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterLocationManager.h"

#define HORZ_ACCURACY	1000.0
#define LOCATION_AGE	100.0

@implementation FilterLocationManager

static FilterLocationManager *singleton = nil;

@synthesize lastLocation = lastLocation_;

#pragma mark -
#pragma mark Singleton Methods

+(id)sharedInstance {
	@synchronized(self) {
		if(singleton == nil) {
			singleton = [[FilterLocationManager alloc] init];
		}
		
		return singleton;
	}
}

- (id)init {
    self = [super init];
    
    if (nil != self) {
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager_.delegate = self;
	}
    
    return self;
}

- (void)dealloc {
    
    [locationManager_ stopUpdatingLocation];
    [locationManager_ release], locationManager_ = nil;
	
    [super dealloc];
}

- (void)startUpdatingLocation {
	[locationManager_ startUpdatingLocation];
}

- (void)stopUpdatingLocation {
	[locationManager_ stopUpdatingLocation];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    
    self.lastLocation = newLocation;
    
    //Setting simulator default location to Carlsbad
	CLLocation *simLocation;

	// test the age of the location to detemine if the measurement is cached
	// in most cases you will not want to rely on cached locations
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	if (locationAge > LOCATION_AGE)
		return;
	
#if TARGET_IPHONE_SIMULATOR
    simLocation = newLocation;
    //Phoenix
    //[simLocation initWithLatitude: 33.445412 longitude:-112.073961 ];
   
    //Seattle
    //[simLocation initWithLatitude: 47.6097 longitude:-122.3331 ];
    // Leakey TX
   //[simLocation initWithLatitude: 32.9613 longitude:-96.8375 ];
    //Tyler tx
    //   [simLocation initWithLatitude: 32.3252 longitude:-95.2947 ];
    // San Diego
    // [simLocation initWithLatitude: 32.740687 longitude:-117.238741 ];
   // Carlsbad
     [simLocation initWithLatitude: 33.143733 longitude:-117.320361 ];
    //Los Angeles
    //[simLocation initWithLatitude: 34.0500 longitude:-118.250000 ];
    // NYC
    //[simLocation initWithLatitude: 40.6700 longitude:-73.940000 ];
    self.lastLocation = simLocation;
#endif
	// test to make sure the accuracy holds a valid value and is within our accuracy threshhold
	if (newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > HORZ_ACCURACY)
		return;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:kFilterLocationUpdated object:self.lastLocation];	//Ben: there's no reason to pass "newlocation"
    
    
    [self stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (kCLErrorLocationUnknown == error.code || kCLErrorDenied == error.code) {
        if (kCLErrorDenied == error.code) {
            [self stopUpdatingLocation];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFilterLocationFailed object:nil];
}

@end
