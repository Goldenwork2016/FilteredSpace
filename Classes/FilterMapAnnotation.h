//
//  FilterMapAnnotation.h
//  TheFilter
//
//  Created by John Thomas on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FilterDataObjects.h"

@interface FilterMapAnnotation : NSObject <MKAnnotation> {

	CLLocationCoordinate2D coordinate_;
	NSString *title_;
	NSString *subtitle_;
	
	//eventually we should just use an ID here rather than the object
	NSInteger showID_;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) NSInteger showID;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
