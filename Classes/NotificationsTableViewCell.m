//
//  NotificationsTableViewCell.m
//  TheFilter
//
//  Created by Patrick Hernandez on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotificationsTableViewCell.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h>

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1]

#define BACKGROUND_COLOR [UIColor clearColor]

@implementation NotificationsTableViewCell

@synthesize leftImageView;
@synthesize notificationLabel;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

		// Set up the review/follow button
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		//[followButton addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];
		[button setBackgroundImage:[UIImage imageNamed:@"unselected_cell_button.png"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"selected_cell_button.png"] forState:UIControlStateHighlighted];
		[button setFrame:CGRectMake(230, 17, 70, 31)];
		[[button titleLabel] setFont:FILTERFONT(14)];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		[self addSubview:button];
		
		// Set up the left image view
		leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 48, 48)];
		[leftImageView setContentMode:UIViewContentModeScaleToFill];
		[leftImageView setBackgroundColor:[UIColor magentaColor]];
		[[leftImageView layer] setMasksToBounds:YES];
		[[leftImageView layer] setCornerRadius:5.0];
		
		[self addSubview:leftImageView];
		
		// Set up the name label
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(68, 5, 150, 15)];
		[nameLabel setFont:FILTERFONT(13)];
		[nameLabel setBackgroundColor:[UIColor clearColor]];
		[nameLabel setTextColor:LIGHT_TEXT_COLOR];
		
		[self addSubview:nameLabel];
		
		// Set up the notification label
		notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(68, 20, 150, 12)];
		[notificationLabel setFont:FILTERFONT(11)];
		[notificationLabel setBackgroundColor:[UIColor clearColor]];
		[notificationLabel setTextColor:LIGHT_TEXT_COLOR];
		
		[self addSubview:notificationLabel];
	
		// Set up the location label
		locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(68, 32, 150, 12)];
		[locationLabel setFont:FILTERFONT(10)];
		[locationLabel setBackgroundColor:[UIColor clearColor]];
		[locationLabel setTextColor:DARK_TEXT_COLOR];
		
		[self addSubview:locationLabel];
		
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[leftImageView release];
	[notificationLabel release];
	[nameLabel release];
	[locationLabel release];
	[button release];
	
    [super dealloc];
}


@end
