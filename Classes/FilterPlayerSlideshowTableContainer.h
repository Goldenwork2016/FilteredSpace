//
//  FilterPlayerSlideshowTableContainer.h
//  TheFilter
//
//  Created by Ben Hine on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FilterPlayerSlideshowTableContainer : UIView {

	//TODO: make this a class that loads and transitions its own images
	UIImageView *imageViewer_;
	
	UITableView *tableView_;
	
	UIView *contentView_;
	UIButton *editButton;
	UIButton *clearButton;
	
	UIButton *repeatButton;
	
	NSIndexPath *selectedIndex;
}



@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, readonly, retain) UIButton *repeatButton;
@property (nonatomic, retain) UIImageView *imageViewer;

- (void)setHeaderEnabled:(BOOL)enable;
- (void)performFlipTransition;
- (void)setEditing:(BOOL)editing;

@end
