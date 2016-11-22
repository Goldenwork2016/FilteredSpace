//
//  NotificationsView.h
//  TheFilter
//
//  Created by Patrick Hernandez on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"

@interface NotificationsView : FilterView <UITableViewDelegate, UITableViewDataSource>{

	UITableView *tableView_;
	
}

@end
