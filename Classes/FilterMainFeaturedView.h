//
//  FilterMainFeaturedView.h
//  TheFilter
//
//  Created by Ben Hine on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterDataObjects.h"
#import "FilterFeaturedSongView.h"
#import "LoadingIndicator.h"
@class FeaturedImageButton, RockMeter;

@interface FilterMainFeaturedView : FilterView <UIActionSheetDelegate, FilterAPIOperationDelegate> {

	FilterBand *featuredObj_;
	FilterShow *featuredShow_;
	NSArray *featuredTracks_;
	
	@private
    
	UILabel *featureName;
	UILabel *featureNameSecondary;
	
	UILabel *featureNameTertiary;
	//UILabel *featureTrackSecondary;
	//UILabel *featureTrackTertiary;
	
	UIImageView *playPauseImage;
	
	FeaturedImageButton *featuredImage;

	
	RockMeter *rockMeter;
	//UIButton *moreButton;
	UIButton *followingButton, *profileButton;

	
	//UILabel *bottomSectionHeader;
	//UILabel *bottomSectionPrimary;
	//UILabel *bottomSectionSecondary;
	//UILabel *bottomSectionTertiary;
	
	//UIButton *bookmarkButton;
	
	
	
	//UILabel *featuredSectionHeader;
	//UILabel *songsSectionHeader;
	
    FilterFeaturedSongView *track[2];
	
    LoadingIndicator *indicator;
}

- (void)setInfoWithData:(FilterBand *)data;
- (void)updateRockMeter;

@property (nonatomic, retain) FilterDataObject *featuredObj;
@property (nonatomic, retain) FilterShow *featuredShow;
@property (nonatomic, retain) NSArray *featuredTracks;

@end
