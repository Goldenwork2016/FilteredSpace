//
//  FilterBandVideoTableController.h
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//@class YouTubeViewController;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterDataObjects.h"
#import "FilterStackController.h"
@class FilterTrack;

@interface FilterBandVideoTableController : NSObject <UITableViewDelegate, UITableViewDataSource> {

	UIView *headerView;
    FilterBand *bandProfile_;
    UITableView *videoTable_;
    
    NSMutableArray *bandVideos_;
    
	FilterStackController *stackController;
    
    FilterTrack *currentTrack_;
    
}

@property (nonatomic, retain) FilterStackController *stackController;

@property (nonatomic, retain) FilterBand *bandProfile;
@property (nonatomic, retain) UITableView *videoTable;
@property (nonatomic, retain) NSMutableArray *bandVideos;
@property (nonatomic, retain) UIView *youTubeView;
@property (nonatomic, retain) FilterTrack *currentTrack;

- (id)initWithHeader:(UIView *)header;
- (void)configureTable:(UITableView*)tableView;

@end
