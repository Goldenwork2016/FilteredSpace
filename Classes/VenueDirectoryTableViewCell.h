//
//  VenueDirectoryTableViewCell.h
//  TheFilter
//
//  Created by John Thomas on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueDirectoryTableViewCell : UITableViewCell {

	UILabel *venueName_, *venueAddress_;
	
	UIButton *venueImage_;
	
}

@property (nonatomic, readonly, retain) UILabel *venueName, *venueAddress;
@property (nonatomic, readonly, retain) UIButton *venueImage;

@end