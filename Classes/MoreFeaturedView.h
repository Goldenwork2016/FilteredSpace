//
//  MoreFeaturedView.h
//  TheFilter
//
//  Created by Ben Hine on 2/25/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterDataObjects.h"
#import "FilterAPIOperationQueue.h"

@interface MoreFeaturedView : FilterView <UITableViewDelegate, UITableViewDataSource, FilterAPIOperationDelegate> {

	UITableView *featuredTable_;
	
	NSMutableArray *trackArray;
	
}

@end
