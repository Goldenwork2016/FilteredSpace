//
//  SubtitleButton.m
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubtitleButton.h"
#import "Common.h"

@implementation SubtitleButton
@synthesize primaryLabel = primaryLabel_;
@synthesize secondaryLabel = secondaryLabel_;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		primaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 60, 20)];
		primaryLabel_.backgroundColor = [UIColor clearColor];
		primaryLabel_.font = FILTERFONT(18);
		primaryLabel_.textAlignment = UITextAlignmentCenter;
		primaryLabel_.shadowOffset = CGSizeMake(0, 1);
		primaryLabel_.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.29];
		[self addSubview:primaryLabel_];
		
		
		secondaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 60, 20)];
		secondaryLabel_.backgroundColor = [UIColor clearColor];
		secondaryLabel_.font = FILTERFONT(12);
		secondaryLabel_.textAlignment = UITextAlignmentCenter;
		secondaryLabel_.shadowOffset = CGSizeMake(0, 1);
		secondaryLabel_.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.29];
		[self addSubview:secondaryLabel_];
		
		primaryLabel_.textColor = [UIColor colorWithRed:0.61 green:0.6 blue:0.6 alpha:1];
		secondaryLabel_.textColor = [UIColor colorWithRed:0.61 green:0.6 blue:0.6 alpha:1];
		
    }
    return self;
}

-(void)setSelected:(BOOL)select {
	[super setSelected:select];
	if(select) {
		
		primaryLabel_.textColor = [UIColor whiteColor];
		secondaryLabel_.textColor = [UIColor whiteColor];
		
	} else {
		
		primaryLabel_.textColor = [UIColor colorWithRed:0.61 green:0.6 blue:0.6 alpha:1];
		secondaryLabel_.textColor = [UIColor colorWithRed:0.61 green:0.6 blue:0.6 alpha:1];
	}
	
	
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
