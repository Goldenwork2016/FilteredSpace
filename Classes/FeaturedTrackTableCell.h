//
//  FeaturedTrackTableCell.h
//  TheFilter
//
//  Created by Ben Hine on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterDataObjects.h"

@interface FeaturedTrackTableCell : UITableViewCell {

	
	UILabel *trackLabel_, *artistLabel_;
	
	UIImageView *artistImage_;
	UIButton *addPlaylistButton_;
	
	FilterTrack *featuredTrack_;
	
}

@property (nonatomic, readonly, retain) UILabel *trackLabel, *artistLabel;
@property (nonatomic, readonly, retain) UIImageView *artistImage;

@property (nonatomic, retain) FilterTrack *featuredTrack;

- (void)setImageURL:(NSString*)url;

@end
