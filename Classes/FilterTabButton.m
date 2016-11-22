//
//  FilterTabButton.m
//  TheFilter
//
//  Created by Ben Hine on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterTabButton.h"


@implementation FilterTabButton

@synthesize unselectedImage = unselectedImage_, selectedImage = selectedImage_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		
		
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

-(void)setUnselectedImage:(UIImageView*)img {
	unselectedImage_ = img;
	if(!self.selected) {
		[self addSubview:unselectedImage_];
	}
}

-(void)setSelectedImage:(UIImageView*)img {
	selectedImage_ = img;
	
	if(self.selected) {
		[self addSubview:selectedImage_];
	}
}


-(void)setSelected:(BOOL)select {
	
	if(select && select != self.selected) {
		
		[unselectedImage_ removeFromSuperview];
		[self addSubview:selectedImage_];
		
	} else if (select != self.selected) {
		
		[selectedImage_ removeFromSuperview];
		[self addSubview:unselectedImage_];
		
	}
	[super setSelected:select];
	
}

//We're not calling super here because it'll muck up the behavior we want



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if(self.isSelected) { //we only want to take the selected action on touchUpInside
		disableTap = NO;
		return;
	}
	
	disableTap = YES;
	self.selected = YES;
	[self sendActionsForControlEvents:UIControlEventTouchDown];
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if(!disableTap && CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), [[touches anyObject] locationInView:self])) {
		
		[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
	
}


- (void)dealloc {
    [super dealloc];
}





@end
