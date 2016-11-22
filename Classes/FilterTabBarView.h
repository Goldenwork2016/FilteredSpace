//
//  FilterTabBarView.h
//  TheFilter
//
//  Created by Ben Hine on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterTabButton;

@protocol FilterTabBarDelegate

@required
-(void)filterTabBarSelectedWithIndex:(NSInteger)idx;
-(void)filterTabBarSelectedTabTappedWithIndex:(NSInteger)idx;

@end


@interface FilterTabBarView : UIView {

	
	UIImageView *backgroundImage;
	NSMutableArray *tabButtons;
	
	id<FilterTabBarDelegate> delegate_;
}

@property (nonatomic, assign) id<FilterTabBarDelegate> delegate;

-(void)setSelectedTabWithIndex:(NSInteger)idx;

@end
