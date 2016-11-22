//
//  FilterPlayerButton.m
//  TheFilter
//
//  Created by Ben Hine on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterPlayerButton.h"


@implementation FilterPlayerButton


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		//we want explicit control over these
		//self.adjustsImageWhenHighlighted = NO;
		self.adjustsImageWhenDisabled = NO;
		
		//NOTE: we're using the selected state here to indicate that music is playing
		
		[self setBackgroundImage:[UIImage imageNamed:@"disabled_music_button.png"] forState:UIControlStateNormal]; //unhighlighted & unselected
		[self setBackgroundImage:[UIImage imageNamed:@"music_button.png"] forState:(UIControlStateSelected | UIControlStateNormal)]; //unhighlighted & selected
		[self setBackgroundImage:[UIImage imageNamed:@"pressed_down_disabled_music_button.png"] forState:UIControlStateHighlighted ]; //highlighted and unselected
		[self setBackgroundImage:[UIImage imageNamed:@"pressed_down_blue_music_button.png"] forState:(UIControlStateHighlighted | UIControlStateSelected)]; //highlighted and selected
    }
    return self;
}

//TODO: make the selected state depend on whether music is playing or not.

- (void)dealloc {
    [super dealloc];
}


@end
