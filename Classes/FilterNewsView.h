//
//  FilterNewsView.h
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterAPIOperationQueue.h"
#import "FilterDataObjects.h"
#import "LoadingIndicator.h"

@interface FilterNewsView : FilterView <UITableViewDelegate, UITableViewDataSource,
                                        FilterAPIOperationDelegate>
{

	
	UITableView *tableView_;
	
    BOOL newsFeedInitialized_;
    FilterPaginator *pager_;
	NSMutableArray *bandFeed_, *friendsFeed_;
	
    LoadingIndicator *indicator;
}

@end
