//
//  FilterShowsUpcomingToolbar.m
//  TheFilter
//
//  Created by John Thomas on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterUpcomingShowsToolbar.h"
#import "FilterToolbarButton.h"
#import "Common.h"

#define LEFTBUTTONFRAME CGRectMake(  10, 7, 37, 31)
#define RIGHTBUTTONFRAME CGRectMake(273, 7, 37, 31)

#define	LEFTSEGMENTBUTTONFRAME CGRectMake(   78, 7, 82, 31)
#define	RIGHTSEGMENTBUTTONFRAME CGRectMake( 160, 7, 82, 31)

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation FilterUpcomingShowsToolbar

@synthesize delegate = delegate_;
@synthesize primaryLabel = primaryLabel_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		
		backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		backgroundView.image = [UIImage imageNamed:@"sub_navigation_bar.png"];
		[self addSubview:backgroundView];
		[self sendSubviewToBack:backgroundView];
		

		mapButton = [[FilterToolbarButton alloc] initWithFrame:LEFTBUTTONFRAME];
		mapButton.toolbarButtonType = kToolbarButtonTypeUpcomingShowsMapButton;
		[mapButton setBackgroundImage:[UIImage imageNamed:@"map_button.png"] forState:UIControlStateNormal];
		[mapButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_map_button.png"] forState:UIControlStateHighlighted];
		[mapButton addTarget:self action:@selector(mapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:mapButton];

		showListButton = [[FilterToolbarButton alloc] initWithFrame:LEFTBUTTONFRAME];
		showListButton.toolbarButtonType = kToolbarButtonTypeUpcomingShowsPosterButton;
		[showListButton setBackgroundImage:[UIImage imageNamed:@"show_list_button.png"] forState:UIControlStateNormal];
		[showListButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_show_list_button.png"] forState:UIControlStateHighlighted];
		[showListButton addTarget:self action:@selector(showListButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		
//		leftSegmentButton = [[FilterToolbarButton alloc] initWithFrame:LEFTSEGMENTBUTTONFRAME];
//		leftSegmentButton.toolbarButtonType = kToolbarButtonTypeUpcomingShowsLeftSegmentButton;
//		leftSegmentButton.titleLabel.font = FILTERFONT(12);
//		[leftSegmentButton setTitle:@"Today" forState:UIControlStateNormal];
//		[leftSegmentButton setTitleColor:[UIColor colorWithRed:.61 green:.6 blue:.6 alpha:1.0] forState:UIControlStateNormal];
//		[leftSegmentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//		[leftSegmentButton setBackgroundImage:[UIImage imageNamed:@"unselected_left_seg_button.png"] forState:UIControlStateNormal]; // unselected and unhighlighted
//		[leftSegmentButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_unselected_left_seg_button.png"] forState:UIControlStateHighlighted]; // unselected and highlighted
//		[leftSegmentButton setBackgroundImage:[UIImage imageNamed:@"selected_left_seg_button.png"] forState:(UIControlStateSelected | UIControlStateNormal)]; // selected and unhighlighted
//		[leftSegmentButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_selected_left_seg_button.png"] forState:(UIControlStateSelected | UIControlStateHighlighted)]; // selected and highlighted
//		[leftSegmentButton addTarget:self action:@selector(leftSegmentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//		leftSegmentButton.selected = YES;
//		[self addSubview:leftSegmentButton];
//
//		rightSegmentButton = [[FilterToolbarButton alloc] initWithFrame:RIGHTSEGMENTBUTTONFRAME];
//		rightSegmentButton.toolbarButtonType = kToolbarButtonTypeUpcomingShowsRightSegmentButton;
//		rightSegmentButton.titleLabel.font = FILTERFONT(12);
//		[rightSegmentButton setTitle:@"Bookmarked" forState:UIControlStateNormal];
//		[rightSegmentButton setTitleColor:[UIColor colorWithRed:.61 green:.6 blue:.6 alpha:1.0] forState:UIControlStateNormal];
//		[rightSegmentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//		[rightSegmentButton setBackgroundImage:[UIImage imageNamed:@"unselected_right_seg_button.png"] forState:UIControlStateNormal];
//		[rightSegmentButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_unselected_right_seg_button.png"] forState:UIControlStateHighlighted];
//		[rightSegmentButton setBackgroundImage:[UIImage imageNamed:@"selected_right_seg_button.png"] forState:(UIControlStateSelected | UIControlStateNormal)];
//		[rightSegmentButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_selected_right_seg_button.png"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
//		[rightSegmentButton addTarget:self action:@selector(rightSegmentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:rightSegmentButton];
		
//		allShowsButton = [[FilterToolbarButton alloc] initWithFrame:RIGHTBUTTONFRAME];
//		allShowsButton.toolbarButtonType = kToolbarButtonTypeUpcomingShowsAllShowsButton;
//		[allShowsButton setBackgroundImage:[UIImage imageNamed:@"all_shows_button.png"] forState:UIControlStateNormal];
//		[allShowsButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_all_shows_button.png"] forState:UIControlStateHighlighted];
//		[allShowsButton addTarget:self action:@selector(allShowsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:allShowsButton];
        
        primaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(50, 8, 210, 30)];
        primaryLabel_.font = FILTERFONT(15);
        primaryLabel_.textColor = LIGHT_TEXT_COLOR;
        primaryLabel_.text = @"";
        primaryLabel_.backgroundColor = [UIColor clearColor];
        primaryLabel_.shadowColor = [UIColor blackColor];
        primaryLabel_.shadowOffset = CGSizeMake(0, -1);
        primaryLabel_.textAlignment = UITextAlignmentCenter;
        [self addSubview:primaryLabel_];
        
		/*
        refeshButton = [[FilterToolbarButton alloc] initWithFrame:RIGHTBUTTONFRAME];
		refeshButton.toolbarButtonType = kToolbarButtonTypeSearchShowsFilterButton;
		[refeshButton setBackgroundImage:[UIImage imageNamed:@"refresh_button.png"] forState:UIControlStateNormal];
		[refeshButton setBackgroundImage:[UIImage imageNamed:@"pressed_refresh_button.png"] forState:UIControlStateHighlighted];
		[refeshButton addTarget:self action:@selector(refreshButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:refeshButton];
		 */
    }
	
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
- (UIView *)hitTest:(CGPoint)point 
		  withEvent:(UIEvent *)event
{
	UIView *hitView = [super hitTest:point withEvent:event];
	if( self == hitView ) {
		return nil;
	} else {
		
		
		return hitView;
	}
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark instance methods

- (void)setMapButton {
	if(!mapButton.superview) {
		[self addSubview:mapButton];
		
		[showListButton removeFromSuperview];
	}	
}

- (void)setShowListButton {
	if(!showListButton.superview) {
		[self addSubview:showListButton];
		
		[mapButton removeFromSuperview];
	}		
}

#pragma mark -
#pragma mark private methods

- (void)mapButtonPressed:(id)sender {
	
	[self.delegate FilterUpcomingShowsButtonPressedWithButton:sender];
}

- (void)showListButtonPressed:(id)sender {
	
	[self.delegate FilterUpcomingShowsButtonPressedWithButton:sender];
}

- (void)leftSegmentButtonPressed:(id)sender {
	
	[self.delegate FilterUpcomingShowsButtonPressedWithButton:sender];
}

- (void)rightSegmentButtonPressed:(id)sender {
	
	[self.delegate FilterUpcomingShowsButtonPressedWithButton:sender];
}

- (void)allShowsButtonPressed:(id)sender {
	
	[self.delegate FilterUpcomingShowsButtonPressedWithButton:sender];
}

- (void)refreshButtonPressed:(id)sender {
    
    [self.delegate FilterUpcomingShowsButtonPressedWithButton:sender];
}
@end
