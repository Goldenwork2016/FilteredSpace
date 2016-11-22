//
//  FilterToolbar.h
//  TheFilter
//
//  Created by Ben Hine on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterSearchShowsToolbar.h"
#import "FilterUpcomingShowsToolbar.h"
#import "Common.h"

@class FilterPlayerButton, FilterToolbarButton, FilterSegmentedSecondaryToolbar;

@protocol FilterToolbarDelegate 

// primary toolbar
-(void)FilterToolbarDelegatePlayerButtonPressed;
-(void)FilterToolbarDelegateRightButtonPressedWithButton:(id)button;
-(void)FilterToolbarDelegateLeftButtonPressedWithButton:(id)button;

// secondary toolbar passthrough
-(void)ForwardUpcomingShowsButtonPressedWithButton:(id)button;
-(void)ForwardSearchShowsButtonPressedWithButton:(id)button;
-(void)ForwardShowsSearchReturn:(NSString *)searchString;

// DEBUG
- (void)serverButtonPushed:(id)sender;

@end



@interface FilterToolbar : UIView <FilterUpcomingShowsToolbarDelegate, FilterSearchShowsToolbarDelegate> {

	UIImageView *backgroundView;
	
	UIImageView *logoText;
	
	UILabel *primaryLabel_;
	UILabel *secondaryLabel_;
	
	FilterToolbarButton *leftButton_;
	FilterToolbarButton *rightButton_;
    
	FilterPlayerButton *playerButton;
	
	UIView *secondaryToolbar_;
	SecondaryToolbarType currentSecondaryToolbarType;
	FilterSearchShowsToolbar *searchShowsToolbar;
	FilterUpcomingShowsToolbar *upcomingShowsToolbar;
	
	FilterSegmentedSecondaryToolbar *segmentSecondaryToolbar;
	
	
	id<FilterToolbarDelegate> delegate_;
	
	
	//Debugging - interal object ONLY
	UIButton *serverSwitchButton;
}

@property (nonatomic, readonly, retain) UILabel *primaryLabel, *secondaryLabel;
@property (nonatomic, assign) id<FilterToolbarDelegate> delegate;
@property (nonatomic, retain) FilterPlayerButton *playerButton;

+(id)sharedInstance;
-(void)showPlayerButton:(BOOL)hideShow;
-(void)showLogo;

-(void)setRightButtonWithType:(ToolbarButtonType)type;
-(void)setLeftButtonWithType:(ToolbarButtonType)type;

- (void) showSecondaryToolbar:(SecondaryToolbarType)toolbarType withLabel:(NSString *)string;
- (void) showSecondaryToolbar:(SecondaryToolbarType)toolbarType;
- (void) showUpcomingShowsMapButton:(BOOL)showMapButton;

-(void)showPrimaryLabel:(NSString*)string;
-(void)showSecondaryLabel:(NSString*)string;


@end
