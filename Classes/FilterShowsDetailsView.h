//
//  FilterShowsDetailsView.h
//  TheFilter
//
//  Created by John Thomas on 2/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterPosterView.h"
#import "LoadingIndicator.h"

@class FilterShow;

@interface FilterShowsDetailsView : FilterView <UITableViewDelegate, UITableViewDataSource, FilterAPIOperationDelegate> {

	UIImageView *posterImage;
	UILabel *venueLabel, *bandLabel, *attendingLabel, *showLabel;
	
	UITableView *showDetailsTable;
	
	FilterShow *show;
	NSNumber *showID_;
    UIButton *attendingButton, *shareButton;
	
	NSDateFormatter *dayFormat_, *timeFormat_;
	
    UIButton *checkInButton;
    
    UIImageView *toolBar;
    
    LoadingIndicator *attendingIndicator;
    LoadingIndicator *indicator;
    
}

@property (nonatomic, retain) NSNumber *showID;
@end
