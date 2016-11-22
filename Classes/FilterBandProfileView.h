//
//  FilterBandProfileView.h
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FilterView.h"
#import "FilterAPIOperationQueue.h"
#import "FilterDataObjects.h"
#import "LoadingIndicator.h"

typedef enum {

	BandMediaTableController = 0,
	BandVideoTableController,
	BandShowsTableController,
    BandBioTableController
	
} FilterBandTableControllerType;

@interface FilterBandProfileView : FilterView <UITableViewDelegate, UITableViewDataSource, 
											   FilterAPIOperationDelegate, UIScrollViewDelegate> 
{

	UIImageView *backgroundImage;
	
	UIImageView *profileSlider;
	NSMutableArray *sliderButtons;
	NSInteger currentSliderIndex;
	
	UIImageView *profileHeaderView;		// container for all the header objects, passed off to the tableview controllers
	UIImageView *bandProfileImage;
	UILabel *bandLabel;
	UILabel *bandLocationLabel;
	UIButton *followButton;
	
	UITableView *profileTable;
	NSMutableArray *profileTableControllers;
												   
	FilterBand *bandProfile_;
	NSNumber *bandID;
	
	UIView *headerContainer;
    
    LoadingIndicator *followIndicator;
    LoadingIndicator *indicator;
    
    BOOL mediaLoaded, showsLoaded, detailsLoaded, videosLoaded;
    
    UIView *cellsBackground;
}

@property (nonatomic, retain) FilterBand *bandProfile;

- (id)initWithFrame:(CGRect)frame andID:(NSNumber *)bandID;
- (void)updateToolbarLabels;

@end
