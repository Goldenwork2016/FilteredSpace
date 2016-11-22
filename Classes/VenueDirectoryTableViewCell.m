//
//  VenueDirectoryTableViewCell.m
//  TheFilter
//
//  Created by John Thomas on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueDirectoryTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"

@implementation VenueDirectoryTableViewCell

@synthesize venueImage = venueImage_;
@synthesize venueName = venueName_;
@synthesize venueAddress = venueAddress_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

		self.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		
//		venueImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 48, 48)];
//		venueImage_.image = [UIImage imageNamed:@"venue_image_avatar.png"];
//		venueImage_.layer.cornerRadius = 5;
//		[self addSubview:venueImage_];
        
        venueImage_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [venueImage_ setFrame:CGRectMake(10, 6, 48, 48)];
        [venueImage_ setImage:[UIImage imageNamed:@"sm_venue_image_avatar.png"] forState:UIControlStateNormal];
		[self addSubview:venueImage_];
        
		venueName_ = [[UILabel alloc] initWithFrame:CGRectMake(68, 10, 200, 25)];
		venueName_.backgroundColor = [UIColor clearColor];
		venueName_.font = FILTERFONT(16);
		venueName_.textColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1];		
		[self addSubview:venueName_];
		
		venueAddress_ = [[UILabel alloc] initWithFrame:CGRectMake(68, 30, 200, 25)];
		venueAddress_.backgroundColor = [UIColor clearColor];
		venueAddress_.font = FILTERFONT(12);
		venueAddress_.textColor = [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1];
		[self addSubview:venueAddress_];
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

@end
