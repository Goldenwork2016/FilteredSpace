//
//  FilterFeaturedSongView.h
//  TheFilter
//
//  Created by Ben Hine on 3/22/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterTrack;

@interface FilterFeaturedSongView : UIView {

	UILabel *songTitle_;
	UILabel *songTime_;
    
	UIButton *playButton_;
	
	FilterTrack *currentTrack_;
}


@property (nonatomic, retain) FilterTrack *currentTrack;
@property (nonatomic, retain) UILabel *songTitle;
@property (nonatomic, retain) UILabel *songTime;
@property (nonatomic, retain, readonly) UIButton *playButton;

@end
