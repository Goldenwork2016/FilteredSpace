//
//  FilterSegmentedSecondaryToolbar.h
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterToolbarButton;

@interface FilterSegmentedSecondaryToolbar : UIView {

	
	UIImageView *backgroundView;
	
	
	UILabel *leftSegmentLabel;
	UILabel *rightSegmentLabel;

	
	FilterToolbarButton *leftSegmentButton;
	FilterToolbarButton *rightSegmentButton;

	
}

@end
