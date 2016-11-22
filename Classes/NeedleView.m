//
//  NeedleView.m
//  TheFilter
//
//  Created by Ben Hine on 2/23/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "NeedleView.h"

@implementation NeedleView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
		self.backgroundColor = [UIColor clearColor];
		radius = frame.size.height;
		currentEndpoint = CGPointMake(37, 50);
		
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
	CGContextRef cxt = UIGraphicsGetCurrentContext();

	CGContextClipToRect(cxt, CGRectMake(0, 0, rect.size.width, rect.size.height - 7));

	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint(path, NULL, self.center.x - 10, self.center.y);
	
	CGPathAddLineToPoint(path, NULL, currentEndpoint.x, currentEndpoint.y);
	CGPathAddLineToPoint(path, NULL, self.center.x + 10, self.center.y);
	CGPathCloseSubpath(path);
	CGContextAddPath(cxt, path);
	
	CGContextSetFillColorWithColor(cxt, [[UIColor colorWithRed:0.141 green:0.463 blue:0.694 alpha:1] CGColor]);
	
	CGContextFillPath(cxt);
    
    CFRelease(path);
}


- (void)dealloc {
    [super dealloc];
}


@end
