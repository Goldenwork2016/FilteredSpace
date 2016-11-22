//
//  FilterShowsPosterScrollView.h
//  TheFilter
//
//  Created by John Thomas on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterScrollView.h"
#import "FilterDataObjects.h"

@protocol FilterShowsPosterScrollViewDelegate

- (void)ExpandedPosterTapped:(id)poster;
- (void)ScrollingStoppedOnShow:(FilterShow*)filterShow;

@end

@interface FilterShowsPosterScrollView : UIView <UIScrollViewDelegate> {

	FilterScrollView *posterScrollView;
	
	NSInteger posterIndex_;
	NSMutableArray *expandedPosterShows_;
	
	id<FilterShowsPosterScrollViewDelegate> delegate_;
}

@property (nonatomic, assign) id<FilterShowsPosterScrollViewDelegate> delegate;
@property (nonatomic, assign) NSInteger posterIndex;

- (void)setPosterDataArray:(NSArray *)array startingAtIndex:(NSInteger)idx;

- (FilterShow*)getCurrentShow;


@end
