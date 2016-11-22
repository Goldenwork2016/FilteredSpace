//
//  FilterBandBioTableController.h
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterDataObjects.h"

@interface FilterBandBioTableController : NSObject <UITableViewDelegate, UITableViewDataSource> {

	UIView *headerView;
	
    NSArray *bandInfo_;
}

@property (nonatomic, retain) NSArray *bandInfo;

- (id)initWithHeader:(UIView *)header;
- (void)configureTable:(UITableView*)tableView;

@end
