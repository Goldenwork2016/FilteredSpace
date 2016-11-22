//
//  FilterShowDetailsTableCell.h
//  TheFilter
//
//  Created by John Thomas on 2/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FilterShowDetailsTableCell : UITableViewCell {

	UILabel *primaryLabel_, *secondaryLabel_, *tertiaryLabel_, *lineupLabel_;
	UIImageView *chevronView_;
}

@property (nonatomic, retain) UILabel *primaryLabel, *secondaryLabel, *tertiaryLabel, *lineupLabel;
@property (nonatomic, retain) UIImageView *chevronView;

- (void)showChevron:(BOOL)show;

@end
