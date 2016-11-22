//
//  FilterShowsPosterView.h
//  TheFilter
//
//  Created by John Thomas on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterScrollView.h"
#import "Common.h"

@interface FilterShowsPosterView : FilterView <FilterAPIOperationDelegate, UIScrollViewDelegate> {

	NSMutableArray *posterShows_;
	FilterScrollView *posterScrollView;
}

@end
