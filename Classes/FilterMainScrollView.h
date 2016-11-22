//
//  FilterMainScrollView.h
//  TheFilter
//
//  Created by Patrick Hernandez on 3/24/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterView.h"
#import "LoadingIndicator.h"

@interface FilterMainScrollView : FilterView <UIScrollViewDelegate, FilterAPIOperationDelegate> {
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSMutableArray *featured;
    NSMutableArray *featuredViews;
    LoadingIndicator *indicator;
}

@end
