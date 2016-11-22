//
//  VenueDirectoryView.h
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 MutualMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterSearchBar.h"
#import "FilterAPIOperationQueue.h"
#import "FilterDataObjects.h"



@interface VenueDirectoryView : FilterView <UITableViewDelegate, UITableViewDataSource,
											UITextFieldDelegate, FilterAPIOperationDelegate> 
{

	UITableView *venueTable;
	FilterSearchBar *venueSearchBar;
    NSString *lastSearch_;
	
	NSMutableArray *venueArray_;
    BOOL venuesInitialized_;
    FilterPaginator *pager_;
    
    BOOL nearbyVenues_;
    
    NSMutableArray *sectionHeaders_;
    NSMutableDictionary *venueDictionary_;
    FilterAPIType lastOpType;
    
}

@property (nonatomic, retain) NSMutableArray *venueArray;

@end
