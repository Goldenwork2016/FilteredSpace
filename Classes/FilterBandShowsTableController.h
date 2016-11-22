//
//  FilterBandShowsTableController.h
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterStackController.h"
#import "FilterDataObjects.h"
#import "FilterAPIOperationQueue.h"

@interface FilterBandShowsTableController : NSObject <UITableViewDelegate, UITableViewDataSource,
                                                      FilterAPIOperationDelegate> 
{

	UIView *headerView;
    
    UITableView *showsTable_;
	
	FilterBand *bandProfile_;

	NSMutableArray *bandShows_;
    FilterPaginator *pager_;

	FilterStackController *stackController;
    
    NSDateFormatter *timeFormatter;
    
}

@property (nonatomic, retain) FilterStackController *stackController;
@property (nonatomic, retain) FilterBand *bandProfile;
@property (nonatomic, retain) NSMutableArray *bandShows;
@property (nonatomic, retain) FilterPaginator *pager;
@property (nonatomic, retain) UITableView *showsTable;

- (id)initWithHeader:(UIView *)header;
- (void)configureTable:(UITableView*)tableView;

@end
