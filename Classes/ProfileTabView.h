//
//  ProfileTabView.h
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterDataObjects.h"
#import "Common.h"
#import "LoadingIndicator.h"

@class ProfileShowsView;

@interface ProfileTabView : FilterView <FilterAPIOperationDelegate, UIScrollViewDelegate,
										UITableViewDelegate, UITableViewDataSource>
{

	BOOL isSelf_;
	
	UIImageView *profilePic_;
	
	UIButton *followButton_;
	
	UILabel *nameLabel_;
	
	NSArray *segmentButtonArray_;
	
    BOOL bandListInitialized_;
    BOOL showListInitialized_;
    BOOL checkinListInitialized_;
    FilterPaginator *bandPager_;	
    FilterPaginator *showPager_;	
    FilterPaginator *checkinPager_;	
    
	UITableView *bandTable_;    
	ProfileShowsView *showScroll_;
	ProfileShowsView *checkinScroll_;
	
	FilterFanAccount *fanAccount_;
	
	NSMutableArray *bandArray_;
	LoadingIndicator *indicator;
    
}

@property (nonatomic, retain) UIImageView *profilePic;
@property (nonatomic, readonly, retain) UILabel *nameLabel;
@property (nonatomic, retain) NSArray *segmentButtonArray;
@property (assign) BOOL isSelf;
@property (nonatomic, retain) FilterFanAccount *fanAccount;


@end
