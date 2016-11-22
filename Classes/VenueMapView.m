//
//  VenueMapView.m
//  TheFilter
//
//  Created by Patrick Hernandez on 5/19/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import "VenueMapView.h"
#import "FilterMapAnnotation.h"

@implementation VenueMapView

- (id)initWithFrame:(CGRect)frame andDictionary:(NSDictionary *)dict {
    
    self = [super initWithFrame:frame];
    if (self) {
		mapView_ = [[MKMapView alloc] initWithFrame:CGRectMake(0, -1, 320, frame.size.height)];
		mapView_.delegate = self;
		mapView_.showsUserLocation = NO;
		[self addSubview:mapView_];
        
        CLLocation *location = [dict objectForKey:@"location"];
        
        FilterMapAnnotation *venueLoc = [[FilterMapAnnotation alloc] initWithCoordinate:[location coordinate]];
        
        [mapView_ setRegion:MKCoordinateRegionMake([location coordinate], MKCoordinateSpanMake(.50, .50)) animated:YES];
//        venueLoc.subtitle = @"test";
//        
//        if ([show.showBands count] > 0) {
//            venueLoc.title = [NSString stringWithString:[[show.showBands lastObject] objectForKey:@"name"]];
//        }
//        else {
//            venueLoc.title = @"Headlinder Name";
//        }
        
        [mapView_ addAnnotation:venueLoc];
        
        [venueLoc release];
    }
    return self;
}

-(void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
    [[FilterToolbar sharedInstance] showLogo];
}

- (void)dealloc {
	[mapView_ release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	MKAnnotationView *annotationView = nil;
	
	if ([annotation isKindOfClass:[FilterMapAnnotation class]]) {
		
		NSString* identifier = @"Pin";
		MKPinAnnotationView *pin = (MKPinAnnotationView*)[mapView_ dequeueReusableAnnotationViewWithIdentifier:identifier];
		
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

//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//	
//	FilterMapAnnotation *annotation = view.annotation;
//	if (annotation != nil) {
//		
//		NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
//		[data setObject:@"showDetails" forKey:@"viewToPush"];
//		[data setObject:[NSNumber numberWithInt:annotation.showID ] forKey:@"ID"];
//		[self.stackController pushFilterViewWithDictionary:data];
//	}
//}

@end
