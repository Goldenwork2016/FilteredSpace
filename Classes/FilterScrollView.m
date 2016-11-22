//
//  FilterScrollView.m
//  TheFilter
//
//  Created by John Thomas on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterScrollView.h"


@implementation FilterScrollView


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

- (void)dealloc {
    [super dealloc];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
	return YES;
}

@end
