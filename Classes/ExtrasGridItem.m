//
//  ExtrasGridItem.m
//  TheFilter
//
//  Created by Ben Hine on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExtrasGridItem.h"


@implementation ExtrasGridItem

@synthesize itemType = itemType_;

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


@end
