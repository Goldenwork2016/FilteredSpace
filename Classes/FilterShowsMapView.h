//
//  FilterShowsMapView.h
//  TheFilter
//
//  Created by John Thomas on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FilterLocationManager.h"
#import "FilterView.h"
#import "Common.h"

@interface FilterShowsMapView : FilterView <FilterAPIOperationDelegate, MKMapViewDelegate> {

	MKMapView *filterMapView;
	NSArray *mapPosterShows_;
	
	FilterLocationManager *locationManager;
	BOOL userLocationInitialized;
}

@property (nonatomic, retain) NSArray *mapPosterShows;

@end
