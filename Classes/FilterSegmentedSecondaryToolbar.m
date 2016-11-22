//
//  FilterSegmentedSecondaryToolbar.m
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterSegmentedSecondaryToolbar.h"
#import "FilterToolbarButton.h"

#define	LEFTSEGMENTBUTTONFRAME CGRectMake(   78, 7, 82, 31)
#define	RIGHTSEGMENTBUTTONFRAME CGRectMake( 160, 7, 82, 31)

@implementation FilterSegmentedSecondaryToolbar


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		backgroundView.image = [UIImage imageNamed:@"sub_navigation_bar.png"];
		[self addSubview:backgroundView];
		[self sendSubviewToBack:backgroundView];
		
		leftSegmentButton = [[FilterToolbarButton alloc] initWithFrame:LEFTSEGMENTBUTTONFRAME];
		leftSegmentButton.toolbarButtonType = kToolbarButtonTypeUpcomingShowsLeftSegmentButton;
		leftSegmentButton.titleLabel.font = FILTERFONT(12);
		[leftSegmentButton setTitle:@"Bands" forState:UIControlStateNormal];
		[leftSegmentButton setTitleColor:[UIColor colorWithRed:.61 green:.6 blue:.6 alpha:1.0] forState:UIControlStateNormal];
		[leftSegmentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
		[leftSegmentButton setBackgroundImage:[UIImage imageNamed:@"unselected_left_seg_button.png"] forState:UIControlStateNormal]; // unselected and unhighlighted
		[leftSegmentButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_unselected_left_seg_button.png"] forState:UIControlStateHighlighted]; // unselected and highlighted
		[leftSegmentButton setBackgroundImage:[UIImage imageNamed:@"selected_left_seg_button.png"] forState:(UIControlStateSelected | UIControlStateNormal)]; // selected and unhighlighted
		[leftSegmentButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_selected_left_seg_button.png"] forState:(UIControlStateSelected | UIControlStateHighlighted)]; // selected and highlighted
		[leftSegmentButton addTarget:self action:@selector(leftSegmentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		leftSegmentButton.selected = YES;
		[self addSubview:leftSegmentButton];
		
		rightSegmentButton = [[FilterToolbarButton alloc] initWithFrame:RIGHTSEGMENTBUTTONFRAME];
		rightSegmentButton.toolbarButtonType = kToolbarButtonTypeUpcomingShowsRightSegmentButton;
		rightSegmentButton.titleLabel.font = FILTERFONT(12);
		[rightSegmentButton setTitle:@"Friends" forState:UIControlStateNormal];
		[rightSegmentButton setTitleColor:[UIColor colorWithRed:.61 green:.6 blue:.6 alpha:1.0] forState:UIControlStateNormal];
		[rightSegmentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
		[rightSegmentButton setBackgroundImage:[UIImage imageNamed:@"unselected_right_seg_button.png"] forState:UIControlStateNormal];
		[rightSegmentButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_unselected_right_seg_button.png"] forState:UIControlStateHighlighted];
		[rightSegmentButton setBackgroundImage:[UIImage imageNamed:@"selected_right_seg_button.png"] forState:(UIControlStateSelected | UIControlStateNormal)];
		[rightSegmentButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_selected_right_seg_button.png"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
		[rightSegmentButton addTarget:self action:@selector(rightSegmentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:rightSegmentButton];
		
		
		
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


-(void)leftSegmentButtonPressed:(id)sender {
	
}

-(void)rightSegmentButtonPressed:(id)sender {
	
}


@end
