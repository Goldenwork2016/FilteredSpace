//
//  FilterShowsUpcomingToolbar.h
//  TheFilter
//
//  Created by John Thomas on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterToolbarButton;

@protocol FilterUpcomingShowsToolbarDelegate 

- (void)FilterUpcomingShowsButtonPressedWithButton:(id)button;

@end


@interface FilterUpcomingShowsToolbar : UIView {

	id<FilterUpcomingShowsToolbarDelegate> delegate_;

	UIImageView *backgroundView;
	
	
	UILabel *leftSegmentLabel;
	UILabel *rightSegmentLabel;
    
    UILabel *primaryLabel_;
	
	FilterToolbarButton *mapButton;
	FilterToolbarButton *showListButton;
	
	FilterToolbarButton *leftSegmentButton;
	FilterToolbarButton *rightSegmentButton;
	
	FilterToolbarButton *allShowsButton;
    FilterToolbarButton *refeshButton;
}

@property (nonatomic, assign) id<FilterUpcomingShowsToolbarDelegate> delegate;
@property (nonatomic, retain) UILabel *primaryLabel;
- (void)setMapButton;
- (void)setShowListButton;
//- (void)setPosterGridButton;

@end
