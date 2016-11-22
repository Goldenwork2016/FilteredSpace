//
//  FilterCheckInCommentField.m
//  TheFilter
//
//  Created by John Thomas on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterCheckInCommentView.h"


@implementation FilterCheckInCommentView

@synthesize commentView = commentView_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.

		self.backgroundColor = [UIColor clearColor];
		
		UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkin_comment_box.png"]];
		[self addSubview:img];
		
		commentView_ = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		commentView_.font = FILTERFONT(13);
		commentView_.textColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:1.0];
		commentView_.backgroundColor = [UIColor clearColor];
		[self addSubview:commentView_];
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
