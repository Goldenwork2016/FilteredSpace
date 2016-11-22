//
//  FilterSearchShowsToolbar.h
//  TheFilter
//
//  Created by John Thomas on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterSearchBar.h"

@class FilterToolbarButton;

@protocol FilterSearchShowsToolbarDelegate 

- (void)FilterSearchShowsButtonPressedWithButton:(id)button;
- (void)FilterSearchShowsReturned:(NSString*)searchString;

@end

@interface FilterSearchShowsToolbar : UIView <UITextFieldDelegate> {

	id<FilterSearchShowsToolbarDelegate> delegate_;
    
	UIImageView *backgroundView;
	
	
	FilterToolbarButton *filterButton, *mapButton, *cancelButton;
	FilterSearchBar *searchBar;

}

@property (nonatomic, assign) id<FilterSearchShowsToolbarDelegate> delegate;

@end
