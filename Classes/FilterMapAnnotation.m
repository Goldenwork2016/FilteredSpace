//
//  FilterMapAnnotation.m
//  TheFilter
//
//  Created by John Thomas on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterMapAnnotation.h"


@implementation FilterMapAnnotation

@synthesize coordinate = coordinate_;
@synthesize title = title_;
@synthesize subtitle = subtitle_;
@synthesize showID = showID_;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	self = [super init];
	
	coordinate_ = coordinate;
	return self;
}

- (void) dealloc {
	[super dealloc];
}

@end
