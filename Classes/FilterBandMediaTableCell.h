//
//  FilterBandMediaTableCell.h
//  TheFilter
//
//  Created by John Thomas on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterDataObjects.h"

@interface FilterBandMediaTableCell : UITableViewCell {

	FilterTrack* bandTrack_;
	
	UIButton *playButton;
	
	UILabel *songTitle_;
	UILabel *songDuration_;
}

@property (nonatomic, retain) FilterTrack *bandTrack;
@property (readonly, retain) UILabel *songTitle;
@property (readonly, retain) UILabel *songDuration;

@end
