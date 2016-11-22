//
//  FilterSearchShowsToolbar.m
//  TheFilter
//
//  Created by John Thomas on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterSearchShowsToolbar.h"
#import "FilterToolbarButton.h"

#define LEFTBUTTONFRAME CGRectMake(10, 7, 37, 31)
#define RIGHTBUTTONFRAME CGRectMake(258, 7, 52, 31)

@implementation FilterSearchShowsToolbar

@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		backgroundView.image = [UIImage imageNamed:@"sub_navigation_bar.png"];
		[self addSubview:backgroundView];
		[self sendSubviewToBack:backgroundView];
		
//        filterButton = [[FilterToolbarButton alloc] initWithFrame:LEFTBUTTONFRAME];
//        filterButton.toolbarButtonType = kToolbarButtonTypeSearchShowsFilterButton;
//        [filterButton setBackgroundImage:[UIImage imageNamed:@"filter_button.png"] forState:UIControlStateNormal];
//        [filterButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_filter_button.png"] forState:UIControlStateHighlighted];
//        [filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:filterButton];
		
        mapButton = [[FilterToolbarButton alloc] initWithFrame:LEFTBUTTONFRAME];
        mapButton.toolbarButtonType = kToolbarButtonTypeUpcomingShowsMapButton;
        [mapButton setBackgroundImage:[UIImage imageNamed:@"map_button.png"] forState:UIControlStateNormal];
        [mapButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_map_button.png"] forState:UIControlStateHighlighted];
        [mapButton addTarget:self action:@selector(mapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mapButton];
        
//        [rightButton_ setBackgroundImage:[UIImage imageNamed:@"cancel_edit_button.png"] forState:UIControlStateNormal];
//        [rightButton_ setBackgroundImage:[UIImage imageNamed:@"pressed_down_cancel_edit_button.png"] forState:UIControlStateHighlighted];
//        rightButton_.frame = RIGHTBUTTONFRAMELRG;
//        rightButton_.titleLabel.font = FILTERFONT(12);
//        [rightButton_ setTitle:@"Done" forState:UIControlStateNormal];
//        [rightButton_ setTitleColor:[UIColor colorWithRed:97 green:.96 blue:.96 alpha:1.0] forState:UIControlStateNormal];
//        
//        rightButton_.toolbarButtonType = type;
//        [self addSubview:rightButton_];
        
		searchBar = [[FilterSearchBar alloc] initWithFrame:CGRectMake(70, 7, 240, 30) withSearchButton:NO];
		searchBar.delegate = self;
		[self addSubview:searchBar];
        
        cancelButton = [[FilterToolbarButton alloc] initWithFrame:CGRectMake(320, 7, 52, 31)];
        cancelButton.toolbarButtonType = kToolbarButtonTypeUpcomingShowsMapButton;
        cancelButton.titleLabel.font = FILTERFONT(12);
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithRed:97 green:.96 blue:.96 alpha:1.0] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_edit_button.png"] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_cancel_edit_button.png"] forState:UIControlStateHighlighted];
        [cancelButton addTarget:searchBar action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.alpha = 0.0;
        [self addSubview:cancelButton];
	}
    return self;
}

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
#pragma mark private methods

- (void) mapButtonPressed:(id)sender {
    [self.delegate FilterSearchShowsButtonPressedWithButton:sender];
}

- (void) filterButtonPressed:(id)sender {
	
	[self.delegate FilterSearchShowsButtonPressedWithButton:sender];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{ 
        searchBar.frame = CGRectMake(10, 7, 240, 30);
        mapButton.alpha = 0.0;
        cancelButton.alpha = 1.0;
        cancelButton.frame = RIGHTBUTTONFRAME;
    }];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{ 
        searchBar.frame = CGRectMake(70, 7, 240, 30);
        mapButton.alpha = 1.0;
        cancelButton.alpha = 0.0;
        cancelButton.frame = CGRectMake(320, 7, 52, 31);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	[textField resignFirstResponder];
    
    [self.delegate FilterSearchShowsReturned:[textField text]];
    //[self filterButtonPressed:textField];
    
	return NO;
}

@end
