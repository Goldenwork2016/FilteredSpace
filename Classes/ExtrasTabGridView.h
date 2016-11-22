//
//  ExtrasTabGridView.h
//  TheFilter
//
//  Created by Ben Hine on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"

@class ExtrasGridItem;

@interface ExtrasTabGridView : FilterView {

	NSMutableArray *gridItems_;
	
}

-(void)addGridItem:(ExtrasGridItem *)item;
-(void)addGridItem:(ExtrasGridItem *)item withFrame:(CGRect)frame;


@end
