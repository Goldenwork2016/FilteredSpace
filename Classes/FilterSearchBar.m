//
//  FilterSearchBar.m
//  TheFilter
//
//  Created by John Thomas on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterSearchBar.h"
#import "Common.h"

#define SAVEDSEARCHFRAME CGRectMake(0, 0, 35, 25)

@implementation FilterSearchBar

@synthesize searchDelegate = searchDelegate_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		self.backgroundColor = [UIColor clearColor];
		
		if (frame.size.width > 240)
			self.background = [UIImage imageNamed:@"wide_search_bar.png"];
		else
			self.background = [UIImage imageNamed:@"search_bkg.png"];
		
		self.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
		self.textColor = [UIColor blackColor];
		self.placeholder = @"Search upcoming shows";
		self.returnKeyType = UIReturnKeySearch;
		
		magnifiyingGlassImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_icon.png"]];
		magnifiyingGlassImage.frame = CGRectMake(0, 0, 15, 16);
		
		self.leftView = magnifiyingGlassImage;
		self.leftViewMode = UITextFieldViewModeAlways;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withSearchButton:(BOOL)useSearchButton {
	
	self = [self initWithFrame:frame];
	if (self) {

		if (useSearchButton == YES) { //this isn't used currently - perhaps we'll have saved searches in version 2
			
			savedSearchesButton = [[UIButton alloc] initWithFrame:SAVEDSEARCHFRAME];
			[savedSearchesButton setBackgroundImage:[UIImage imageNamed:@"saved_searchs_icon.png"] forState:UIControlStateNormal];
			[savedSearchesButton addTarget:self action:@selector(savedSearchesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			
			self.rightView = savedSearchesButton;
			self.rightViewMode = UITextFieldViewModeAlways;
		}
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

- (void)dealloc {
    [super dealloc];
}

- (CGRect) leftViewRectForBounds:(CGRect)boundingRect {
	// just to make sure the icon fits well in the field
	return CGRectMake(5, 8, 15, 16);
}

- (CGRect) rightViewRectForBounds:(CGRect)boundingRect {
	// just to make sure the icon fits well in the field
	return CGRectMake(self.frame.size.width-40, 3, 35, 25);	
}

- (CGRect) placeholderRectForBounds:(CGRect)boundingRect {
	return CGRectMake(25,								// left side icon
					  7,								// shift by a few pixels to center the text vertically
					  boundingRect.size.width-40-25,	// field's bounding width minus the two icons
					  boundingRect.size.height);		// field's bounding height
}

- (CGRect)textRectForBounds:(CGRect)boundingRect {
	return CGRectMake(25,
					  7,
					  boundingRect.size.width-40-25,
					  boundingRect.size.height);	
}

- (CGRect) editingRectForBounds:(CGRect)boundingRect {
	return CGRectMake(25,
					  7,
					  boundingRect.size.width-40-25,
					  boundingRect.size.height);
}

#pragma mark -
#pragma mark private methods

- (void) savedSearchesButtonPressed:(id)sender {
	
	[self.searchDelegate FilterSearchBarSavedSearchesPressed];
}

@end
