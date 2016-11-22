//
//  FilterShowsExpandedPosterView.h
//  TheFilter
//
//  Created by John Thomas on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterShowsPosterScrollView.h"

@class FilterShowsPosterScrollView;

@interface FilterShowsExpandedPosterView : FilterView <FilterShowsPosterScrollViewDelegate> {

	FilterShowsPosterScrollView *posterScrollView;

    UIImageView *posterView;
    
	UIButton *expandButton;
	UIButton *checkInButton;
    UIButton *infoButton;
    
    UIImageView *toolBar;
}

- (void)setPosterDataArray:(NSArray *)array startingAtIndex:(NSInteger)idx;
- (void)updateToolbarLabelsWithShow:(FilterShow*)showData;

@end
