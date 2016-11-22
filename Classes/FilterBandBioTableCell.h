//
//  FilterBandBioTableCell.h
//  TheFilter
//
//  Created by John Thomas on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FilterBandBioTableCell : UITableViewCell {

	UILabel *cellTitle_;
	UILabel *cellContent_;
	
	UIView *cellContentBackground;
}

@property (readonly, retain) UILabel *cellTitle;
@property (readonly, retain) UILabel *cellContent;

- (void)adjustCellFrames:(CGSize)labelSize;

@end
