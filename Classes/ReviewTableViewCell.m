//
//  ReviewTableViewCell.m
//  TheFilter
//
//  Created by Patrick Hernandez on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReviewTableViewCell.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h>

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1]

#define BACKGROUND_COLOR [UIColor clearColor]

@implementation ReviewTableViewCell

@synthesize nameLabel;
@synthesize voteButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
			// Set up the seperator
		UIView *seperator;
		UIView *seperatorShadow;
		
		seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 1)];
		seperatorShadow = [[UIView alloc] initWithFrame:CGRectMake(10, 1, 300, 1)];
		
		[seperator setBackgroundColor:[UIColor blackColor]];
		
		[seperatorShadow setBackgroundColor:[UIColor grayColor]];
		[seperatorShadow setAlpha:0.2];
		
		[self addSubview:seperator];
		[self addSubview:seperatorShadow];
	
		// Set up the name label
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 225, 20)];
		[nameLabel setBackgroundColor:BACKGROUND_COLOR];
		[nameLabel setTextColor:LIGHT_TEXT_COLOR];
		[nameLabel setFont:FILTERFONT(18)];
		[nameLabel setShadowColor:[UIColor blackColor]];
		[nameLabel setShadowOffset:CGSizeMake(0, 1)];
		
		[self addSubview:nameLabel];
		
		// Set up the vote button
		voteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[voteButton setFrame:CGRectMake(240, 10, 69, 69)];
		[voteButton setImage:[UIImage imageNamed:@"tap_to_vote_button.png"] forState:UIControlStateNormal];
		[voteButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_tap_to_vote.png"] forState:UIControlStateHighlighted];
		
		[self addSubview:voteButton];
		
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[voteButton release];
	[nameLabel release];
    [super dealloc];
}


@end
