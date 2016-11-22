//
//  FilterPlayerTableCell.h
//  TheFilter
//
//  Created by Ben Hine on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FilterPlayerTableCell : UITableViewCell {

	UILabel *numberLabel_, *trackLabel_, *artistLabel_, *lengthLabel_;
	UIImageView *playingCarat;
	
}

@property (readonly,retain) UILabel *numberLabel, *trackLabel, *artistLabel, *lengthLabel;


@end
