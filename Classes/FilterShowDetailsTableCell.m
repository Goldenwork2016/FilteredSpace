//
//  FilterShowDetailsTableCell.m
//  TheFilter
//
//  Created by John Thomas on 2/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterShowDetailsTableCell.h"
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]

@implementation FilterShowDetailsTableCell

@synthesize primaryLabel = primaryLabel_;
@synthesize secondaryLabel = secondaryLabel_;
@synthesize tertiaryLabel = tertiaryLabel_;
@synthesize lineupLabel = lineupLabel_;
@synthesize chevronView = chevronView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		//self.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1.0];
        self.backgroundColor = [UIColor blackColor];

		primaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 260, 15)];
		primaryLabel_.font = FILTERFONT(13);
		primaryLabel_.textColor = LIGHT_TEXT_COLOR;
		primaryLabel_.textAlignment = UITextAlignmentLeft;
		primaryLabel_.backgroundColor = [UIColor clearColor];
		[self addSubview:primaryLabel_];
		
		secondaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, 260, 15)];
		secondaryLabel_.font = FILTERFONT(13);
		secondaryLabel_.textColor = LIGHT_TEXT_COLOR;
		secondaryLabel_.textAlignment = UITextAlignmentLeft;
		secondaryLabel_.backgroundColor = [UIColor clearColor];
		[self addSubview:secondaryLabel_];

		tertiaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(20, 38, 260, 15)];
		tertiaryLabel_.font = FILTERFONT(13);
		tertiaryLabel_.textColor = LIGHT_TEXT_COLOR;
		tertiaryLabel_.textAlignment = UITextAlignmentLeft;
		tertiaryLabel_.backgroundColor = [UIColor clearColor];
		[self addSubview:tertiaryLabel_];

		lineupLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 260, 15)];
		lineupLabel_.font = FILTERFONT(13);
		lineupLabel_.textColor = LIGHT_TEXT_COLOR;
		lineupLabel_.textAlignment = UITextAlignmentLeft;
		lineupLabel_.backgroundColor = [UIColor clearColor];
		[self addSubview:lineupLabel_];
		
		chevronView_ = [[UIImageView alloc] initWithFrame:CGRectMake(290, 14, 9, 14)];
		chevronView_.image = [UIImage imageNamed:@"chevron.png"];
		chevronView_.hidden = YES;		// hidden by default
		[self addSubview:chevronView_];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}

- (void)showChevron:(BOOL)show {
	chevronView_.hidden = !show;
}


@end
