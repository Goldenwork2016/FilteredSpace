//
//  ReviewView.h
//  TheFilter
//
//  Created by Patrick Hernandez on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterAPIOperationQueue.h"

@interface ReviewView : FilterView <UITableViewDelegate, UITableViewDataSource,
									FilterAPIOperationDelegate>
{
	
	UITableView *tableView_;
	UIButton *starsButtons[5];
	UIToolbar *keyboardToolbar;
	NSInteger currentRow;
}

- (void) setUpTableHeader;
- (void) setUpTableFooter;

@end
