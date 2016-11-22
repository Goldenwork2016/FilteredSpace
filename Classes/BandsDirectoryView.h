//
//  BandsDirectoryView.h
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterSearchBar.h"
#import "FilterAPIOperationQueue.h"
#import "FilterDataObjects.h"
#import "LoadingIndicator.h"


@interface BandsDirectoryView : FilterView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FilterAPIOperationDelegate>{

	UITableView *tableView_;
	FilterSearchBar *searchBar_;
    NSString *lastSearch_;

	NSMutableArray *bandArray_;
	NSMutableDictionary *bandDictionary_;
	NSMutableArray *sectionHeaders;
    
    BOOL bandsInitialized_;
    FilterPaginator *pager_;
    FilterAPIType lastOpType;
    
    LoadingIndicator *indicator;
}

@end
