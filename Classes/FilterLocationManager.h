//
//  FilterLocationManager.h
//  TheFilter
//
//  Created by John Thomas on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

// Notification posted once the device has successfully updated its location
#define kFilterLocationUpdated	(@"FilterLocationUpdated")
// Notification posted if the location service fails for some reason
#define kFilterLocationFailed	(@"FilterLocationFailed")

@protocol FilterLocationManagerDelegate
@required
- (void) locationUpdated:(CLLocation *)location;
- (void) locationFailedToUpdate:(NSError *)error;
@end

@interface FilterLocationManager : NSObject <CLLocationManagerDelegate> {

    CLLocationManager *locationManager_;
	
	CLLocation *lastLocation_;
}

@property (nonatomic, retain) CLLocation *lastLocation;

+ (FilterLocationManager *) sharedInstance;

// start/stop trying to update the devices location
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
