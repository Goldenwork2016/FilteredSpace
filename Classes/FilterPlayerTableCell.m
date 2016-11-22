//
//  FilterPlayerTableCell.m
//  TheFilter
//
//  Created by Ben Hine on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterPlayerTableCell.h"
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]

@implementation FilterPlayerTableCell

@synthesize numberLabel = numberLabel_;
@synthesize trackLabel = trackLabel_;
@synthesize artistLabel = artistLabel_;
@synthesize lengthLabel = lengthLabel_;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		self.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		
		numberLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(5, 8, 25, 30)];
		numberLabel_.font = FILTERFONT(13);
		numberLabel_.textColor = LIGHT_TEXT_COLOR;
		//numberLabel_.adjustsFontSizeToFitWidth = YES;
		//numberLabel_.minimumFontSize = 10;
		numberLabel_.textAlignment = UITextAlignmentLeft;
		numberLabel_.backgroundColor = [UIColor clearColor];
		[self addSubview:numberLabel_];
		
		
		trackLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(67, 3, 200, 20)];
		trackLabel_.font = FILTERFONT(15);
		//trackLabel_.adjustsFontSizeToFitWidth = YES;
		//trackLabel_.minimumFontSize = 14;
		trackLabel_.textColor = LIGHT_TEXT_COLOR;
		trackLabel_.backgroundColor = [UIColor clearColor];
		[self addSubview:trackLabel_];
		
		artistLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(67, 23, 200, 20)];
		artistLabel_.font = FILTERFONT(13);
		artistLabel_.textColor = DARK_TEXT_COLOR;
		//artistLabel_.adjustsFontSizeToFitWidth = YES;
		//artistLabel_.minimumFontSize = 12;
		artistLabel_.backgroundColor = [UIColor clearColor];
		[self addSubview:artistLabel_];
		
		lengthLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(270, 13, 45, 20)];
		lengthLabel_.font = FILTERFONT(13);
		lengthLabel_.textColor = LIGHT_TEXT_COLOR;
		//lengthLabel_.adjustsFontSizeToFitWidth = YES;
		//lengthLabel_.minimumFontSize = 12;
		lengthLabel_.backgroundColor = [UIColor clearColor];
		lengthLabel_.textAlignment = UITextAlignmentRight;
		[self addSubview:lengthLabel_];
		
		
		playingCarat = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_play_icon.png"]];
		playingCarat.frame = CGRectMake(38, 18, 11, 11);
		
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	lengthLabel_.hidden = editing;
	//numberLabel_.highlighted = editing;
	numberLabel_.hidden = editing;
	
}


- (void)setSelected:(BOOL)select animated:(BOOL)animated {
    
    [super setSelected:select animated:animated];
	
	if(select) {
		[self.contentView addSubview:playingCarat];
	} else {
		[playingCarat removeFromSuperview];
	}
	
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
