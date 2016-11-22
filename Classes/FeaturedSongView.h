//
//  FeaturedSongView.h
//  TheFilter
//
//  Created by Ben Hine on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterDataObjects.h"

@interface FeaturedSongView : FilterView <UIActionSheetDelegate, FilterAPIOperationDelegate> {

	UILabel *categoryLabel[5], *songInfo;
	
	UILabel *titleLabel, *albumLabel, *artistLabel, *yearLabel, *durationLabel;
	
	UIButton *likeButton, *downloadButton, *shareButton, *profileButton;
	
	FilterTrack *track_;
}

@property (nonatomic, retain) FilterTrack *track;

@end
