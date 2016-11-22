//
//  FilterAllShowsTableCell.h
//  TheFilter
//
//  Created by John Thomas on 2/21/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterDataObjects.h"
#import "FilterPosterView.h"

@interface FilterAllShowsTableCell : UITableViewCell {

	FilterShow *show_;
	UIImageView *dateView, *chevronView;
    FilterPosterView *posterView_;
    
	UIButton *bookmarkButton, *addBookmarkButton;
	//UILabel *dayOfWeekLabel_, *dayOfMonthLabel_, *attendingLabel_;
    
	UILabel *showLabel_, *venueLabel_, *bandsLabel_;
    UIImageView *bookmark;
}

@property (nonatomic, retain) FilterShow* show;
//@property (readonly, retain) UILabel *dayOfWeekLabel, *dayOfMonthLabel, *attendingLabel;
@property (nonatomic, retain) FilterPosterView *posterView;
@property (readonly, retain) UILabel *showLabel, *venueLabel, *bandsLabel;

//- (void)setAddBookmarkButton;
//- (void)setBookmarkButton;
- (void)setBookmark;
- (void)removeBookmark;

@end
