//
//  FilterBandBioTableCell.m
//  TheFilter
//
//  Created by John Thomas on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterBandBioTableCell.h"
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation FilterBandBioTableCell

@synthesize cellTitle = cellTitle_;
@synthesize cellContent = cellContent_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		cellContentBackground = [[UIImageView alloc] initWithFrame:CGRectMake(10, 40, 300, 35)];
		cellContentBackground.layer.cornerRadius = 10;
		cellContentBackground.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		[cellContentBackground.layer setBorderWidth: 1.0];
		[cellContentBackground.layer setBorderColor: [[UIColor blackColor] CGColor]];
		[self.contentView addSubview:cellContentBackground];
		
		cellTitle_ = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 24)];
		cellTitle_.font = FILTERFONT(18);
		cellTitle_.textColor = LIGHT_TEXT_COLOR;
		cellTitle_.textAlignment = UITextAlignmentLeft;
		cellTitle_.backgroundColor = [UIColor clearColor];
		cellTitle_.shadowColor = [UIColor blackColor];
		cellTitle_.shadowOffset = CGSizeMake(0, 1);
		[self.contentView addSubview:cellTitle_];
		
		cellContent_ = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 280, 15)];
		cellContent_.font = FILTERFONT(13);
		cellContent_.textColor = LIGHT_TEXT_COLOR;
		cellContent_.lineBreakMode = UILineBreakModeWordWrap;
		cellContent_.numberOfLines = 0;
		cellContent_.textAlignment = UITextAlignmentLeft;
		cellContent_.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:cellContent_];
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

- (void)adjustCellFrames:(CGSize)labelSize {
	
	// set the content label to the new height
	CGRect newFrame = self.cellContent.frame;
	newFrame.size.height = labelSize.height;
	self.cellContent.frame = newFrame;
	
	// re-frame the bg view
	newFrame = cellContentBackground.frame;
	newFrame.size.height = self.cellContent.frame.size.height + 20;
	cellContentBackground.frame = newFrame;
}

@end
