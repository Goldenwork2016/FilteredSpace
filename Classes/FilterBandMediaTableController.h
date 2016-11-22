//
//  FilterBandMediaTableController.h
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterDataObjects.h"
#import "FilterStackController.h"
#import "FilterAPIOperationQueue.h"

@interface FilterBandMediaTableController : NSObject <UITableViewDelegate, UITableViewDataSource,
                                                      FilterAPIOperationDelegate>
{

	UIView *headerView;
    UIView *background;
    UITableView *tracksTable_;

	FilterBand *bandProfile_;

	NSMutableArray *bandTracks_;
    FilterPaginator *pager_;

	FilterStackController *stackController;
}

@property (nonatomic, retain) FilterStackController *stackController;
@property (nonatomic, retain) NSMutableArray *bandTracks;
@property (nonatomic, retain) FilterPaginator *pager;
@property (nonatomic, retain) UITableView *tracksTable;
@property (nonatomic, retain) FilterBand *bandProfile;


- (id)initWithHeader:(UIView *)header;
- (void)configureTable:(UITableView*)tableView;

@end
