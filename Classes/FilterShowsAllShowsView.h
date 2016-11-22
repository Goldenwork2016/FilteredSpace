//
//  FilterShowsAllShows.h
//  TheFilter
//
//  Created by John Thomas on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterDataObjects.h"
#import "LoadingIndicator.h"
#import "FilterAPIOperationQueue.h"

@interface FilterShowsAllShowsView : FilterView <UITableViewDelegate, UITableViewDataSource, 
												 UIActionSheetDelegate, FilterAPIOperationDelegate>
{

	UITableView *allShowsTableView_;
    
    BOOL showsPageInitialized_;
    FilterPaginator *pager_;
    FilterAPIType lastOpType;
	NSMutableArray *showsArray_;
    //NSMutableArray *showIdArray_;
	NSMutableArray *datesArray_;
    NSDateFormatter *formatter;
    NSMutableDictionary *showsDict_;
    
    NSString *prevSearchString;
    
	NSDateFormatter *dayOfWeekFormatter, *dayOfMonthFormatter, *timeFormatter;
	
    LoadingIndicator *indicator;
}

- (void)mapButtonTapped:(id)button;

@end
