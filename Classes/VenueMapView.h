//
//  VenueMapView.h
//  TheFilter
//
//  Created by Patrick Hernandez on 5/19/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FilterView.h"
#import "FilterLocationManager.h"

@interface VenueMapView : FilterView <MKMapViewDelegate> {
    MKMapView *mapView_;
}

@end
