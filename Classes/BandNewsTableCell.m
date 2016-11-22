///
//  BandNewsTableCell.m
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BandNewsTableCell.h"
#import "FilterGlobalImageDownloader.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1]

@implementation BandNewsTableCell
@synthesize artistImage = artistImage_;
@synthesize primaryLabel = primaryLabel_;
@synthesize bodyLabel = bodyLabel_;
@synthesize timestampLabel = timestampLabel_;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		artistImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 48, 48)];
		artistImage_.layer.cornerRadius = 5;
		artistImage_.backgroundColor = [UIColor clearColor];
        artistImage_.image = [UIImage imageNamed:@"sm_no_image.png"];
		artistImage_.clipsToBounds = YES;
		[self addSubview:artistImage_];
		
		
		primaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(64,10,240,18)];
		primaryLabel_.backgroundColor = [UIColor clearColor];
		primaryLabel_.font = FILTERFONT(14);
		primaryLabel_.textColor = LIGHT_TEXT_COLOR;
		primaryLabel_.numberOfLines = 0;
		[self addSubview:primaryLabel_];

		bodyLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(64,29,240,24)];
		bodyLabel_.backgroundColor = [UIColor clearColor];
		bodyLabel_.font = FILTERFONT(11);
		bodyLabel_.textColor = DARK_TEXT_COLOR;
		bodyLabel_.numberOfLines = 0;
		[self addSubview:bodyLabel_];
		
		timestampLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(64, 54, 240, 15)];
		timestampLabel_.backgroundColor = [UIColor clearColor];
		timestampLabel_.textColor = DARK_TEXT_COLOR;
		timestampLabel_.font = FILTERFONT(10);
		[self addSubview:timestampLabel_];
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)resetImage {
	artistImage_.image = nil;
}

- (void)setImageURL:(NSString*)url {
	
	if (url != nil)
		artistImage_.image = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:url object:self selector:@selector(posterImageDownloaded:)];
}

- (void)adjustCellFrames:(CGSize)labelSize {
	
	// set the body label to the new height
	CGRect newFrame = bodyLabel_.frame;
	newFrame.size.height = labelSize.height;
	bodyLabel_.frame = newFrame;
	
	// move the timestamp labe accordingly
    if (newFrame.size.height > 25) {
        newFrame = timestampLabel_.frame;
        newFrame.origin.y =  bodyLabel_.frame.origin.y + bodyLabel_.frame.size.height + 1;
        timestampLabel_.frame = newFrame;
    }
}

-(void)posterImageDownloaded:(id)sender {
	artistImage_.image = [(NSNotification*)sender image];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end
