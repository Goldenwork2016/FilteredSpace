//
//  FilterSearchBar.h
//  TheFilter
//
//  Created by John Thomas on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol FilterSearchBarDelegate 

- (void)FilterSearchBarSavedSearchesPressed;

@end

@interface FilterSearchBar : UITextField	{

	id<FilterSearchBarDelegate> searchDelegate_;
	
	UIButton *savedSearchesButton;
	UIImageView *magnifiyingGlassImage;
}

- (id)initWithFrame:(CGRect)frame withSearchButton:(BOOL)useSearchButton;

@property (nonatomic, assign) id<FilterSearchBarDelegate> searchDelegate;

@end
