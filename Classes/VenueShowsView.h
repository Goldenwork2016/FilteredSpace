//
//  VenueShowsView.h
//  TheFilter
//
//  Created by Patrick Hernandez on 5/23/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterView.h"
#import "FilterDataObjects.h"
#import "LoadingIndicator.h"

@interface VenueShowsView : FilterView <FilterAPIOperationDelegate, UITableViewDelegate, UITableViewDataSource>{
    UITableView *allShowsTableView_;
    
    BOOL showsPageInitialized_;
    FilterPaginator *pager_;
    
	NSMutableArray *showsArray_;
	NSMutableArray *datesArray_;
    NSDateFormatter *formatter;
    NSMutableDictionary *showsDict_;
    
    NSString *prevSearchString;
    
	NSDateFormatter *dayOfWeekFormatter, *dayOfMonthFormatter, *timeFormatter;
	
    LoadingIndicator *indicator;
    
    NSNumber *ID_;
}

@end
