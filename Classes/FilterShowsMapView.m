//
//  FilterShowsMapView.m
//  TheFilter
//
//  Created by John Thomas on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterShowsMapView.h"
#import "FilterToolbar.h"
#import "FilterMapAnnotation.h"
#import "FilterAPIOperationQueue.h"
#import "FilterDataObjects.h"
#import "FilterCache.h"
#import "FilterAPIOperationQueue.h"

@implementation FilterShowsMapView

@synthesize mapPosterShows = mapPosterShows_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		mapPosterShows_ = [[NSMutableArray alloc] init];
        
		filterMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, -1, 320, frame.size.height)];
		filterMapView.delegate = self;
		filterMapView.showsUserLocation = YES;

		[self addSubview:filterMapView];
		
		userLocationInitialized = NO;
		locationManager = [FilterLocationManager sharedInstance];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(locationUpdated:)
													 name:kFilterLocationUpdated
												   object:nil];
		}
    return self;
}

-(void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeNone];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_UpcomingShows withLabel:@"Today's Shows"];
	[[FilterToolbar sharedInstance] showUpcomingShowsMapButton:NO];
    [[FilterToolbar sharedInstance] showLogo];
}

- (void)dealloc {
	
	[locationManager stopUpdatingLocation];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:kFilterLocationUpdated 
												  object:nil];
	
	[filterMapView release];
	
    [super dealloc];
}

- (void)didMoveToSuperview {
    
    for (FilterShow *show in mapPosterShows_) {
        if (show != nil) {
            if (show.showVenue != nil) {
                
                FilterMapAnnotation *venueLoc = [[FilterMapAnnotation alloc] initWithCoordinate:show.showVenue.venueLocation.coordinate];
                venueLoc.subtitle = show.showVenue.venueName;
                
                if ([show.showBands count] > 0) {
                    venueLoc.title = [NSString stringWithString:[[show.showBands lastObject] objectForKey:@"name"]];
                }
                else {
                    venueLoc.title = @"Headlinder Name";
                }
                
                venueLoc.showID = show.showID;
                [filterMapView addAnnotation:venueLoc];
                
                [venueLoc release];
            }                
        }
    }
    
    /*
    //JDH center map on user location
    [filterMapView setCenterCoordinate:filterMapView.userLocation.location.coordinate animated:YES];
    NSLog(@"location.coordinate %f %f", filterMapView.userLocation.location.coordinate.latitude, filterMapView.userLocation.location.coordinate.longitude);
    [filterMapView setRegion:MKCoordinateRegionMake(filterMapView.userLocation.location.coordinate, MKCoordinateSpanMake(.20, .20)) animated:YES];
     */
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
		
	// make sure the main toolbar displays the correct subtoolbar
	if (newSuperview == nil) {
		
		//[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	}
	else {
		[locationManager startUpdatingLocation];
	}
}

#pragma mark -
#pragma mark Notifcation Handlers

- (void)locationUpdated:(NSNotification *)note {
    //Testing ...  take out for production
//	userLocationInitialized = YES;
	
    if (!userLocationInitialized) {
		CLLocation *location = [note object];
        //JDH center map on user location
         [filterMapView setCenterCoordinate:location.coordinate animated:YES];
       // [filterMapView setCenterCoordinate:filterMapView.userLocation.location.coordinate animated:YES];
        NSLog(@"location.coordinate %f %f", location.coordinate.latitude, location.coordinate.longitude);
        [filterMapView setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.20, .20)) animated:YES];
		//[filterMapView setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.50, .50)) animated:YES];
		
		userLocationInitialized = YES;
		[locationManager stopUpdatingLocation];
	}
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	MKAnnotationView *annotationView = nil;
	
	if ([annotation isKindOfClass:[FilterMapAnnotation class]]) {
		
		NSString* identifier = @"Pin";
		MKPinAnnotationView *pin = (MKPinAnnotationView*)[filterMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if (pin == nil)
			pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		
		annotationView = pin;
		annotationView.draggable = NO;
		annotationView.canShowCallout = YES;
		annotationView.image = [UIImage imageNamed:@"map_pin.png"];
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	}
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
	FilterMapAnnotation *annotation = view.annotation;
	if (annotation != nil) {
		
		NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
		[data setObject:@"showDetails" forKey:@"viewToPush"];
		[data setObject:[NSNumber numberWithInt:annotation.showID ] forKey:@"showID"];
		[self.stackController pushFilterViewWithDictionary:data];
	}
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {


}

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFailWithError:(NSError*)err {
	
    NSString *title;
    NSString *message;
    
    if ([[err domain] isEqualToString:@"USR"]) {
        title = [[err userInfo] objectForKey:@"name"];
        message = [[err userInfo] objectForKey:@"description"];
    }
    else {
        title = @"Sorry";
        message = @"The Server could not be reached";
    }
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle: title
							   message: message
							   delegate:self
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}

@end
