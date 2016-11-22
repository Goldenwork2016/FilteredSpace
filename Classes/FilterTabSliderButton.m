//
//  FilterTabSliderControl.m
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterTabSliderButton.h"


@implementation FilterTabSliderButton

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		unselectedSliderImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
		unselectedSliderImage.backgroundColor = [UIColor clearColor];
		[self addSubview:unselectedSliderImage];
		
		selectedSliderImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
		selectedSliderImage.image = [UIImage imageNamed:@"tab_silder.png"];
		selectedSliderImage.contentMode = UIViewContentModeTop;
		
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

- (void)setSelected:(BOOL)select {
	
	if(select && select != self.selected) {
		
		[unselectedSliderImage removeFromSuperview];
		[self addSubview:selectedSliderImage];
		
	} else if (select != self.selected) {
		
		[selectedSliderImage removeFromSuperview];
		[self addSubview:unselectedSliderImage];
		
	}
	
	[super setSelected:select];
}

@end
