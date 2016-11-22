//
//  VenueProfileTableViewCell.m
//  TheFilter
//
//  Created by Patrick Hernandez on 5/23/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import "VenueProfileTableViewCell.h"
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation VenueProfileTableViewCell

@synthesize contentLabel = contentLabel_;
@synthesize background = background_;
@synthesize label = label_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        background_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 24)];
        background_.layer.cornerRadius = 10;
        background_.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1.0];
        [background_.layer setBorderWidth: 1.0];
        [background_.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [self.contentView addSubview:background_];
        
        contentLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 2)];
        [contentLabel_ setFont:FILTERFONT(13)];
        [contentLabel_ setTextColor:LIGHT_TEXT_COLOR];
        [contentLabel_ setBackgroundColor:[UIColor clearColor]];
        [contentLabel_ setTextAlignment:UITextAlignmentLeft];
        [contentLabel_ setLineBreakMode:UILineBreakModeWordWrap];
        [contentLabel_ setNumberOfLines:0];
        [self.contentView addSubview:contentLabel_];
        
        label_ = [[UILabel alloc] initWithFrame:CGRectMake(240, 19, 60, 20)];
        label_.backgroundColor = [UIColor clearColor];
        label_.font = FILTERFONT(13);
        label_.textColor = LIGHT_TEXT_COLOR;
        label_.textAlignment = UITextAlignmentRight;
        [self.contentView addSubview:label_];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)adjustCellFrames:(CGSize)labelSize {
	
	// set the content label to the new height
	CGRect newFrame = contentLabel_.frame;
	newFrame.size.height = labelSize.height;
	contentLabel_.frame = newFrame;
	
	// re-frame the bg view
	newFrame = background_.frame;
	newFrame.size.height = contentLabel_.frame.size.height + 20;
	background_.frame = newFrame;
}

- (void)dealloc
{
    [background_ release];
    [contentLabel_ release];
    
    [super dealloc];
}

@end
