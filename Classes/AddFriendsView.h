//
//  AddFriendsView.h
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterSearchBar.h"

@interface AddFriendsView : FilterView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{

	FilterSearchBar *searchBar_;
	UITableView *friendsTable;
	
	NSMutableArray *profileArray_;
}

@property (nonatomic, retain) NSMutableArray *profileArray;

@end
