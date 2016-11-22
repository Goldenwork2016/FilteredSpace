//
//  FollowBandTableCell.m
//  TheFilter
//
//  Created by Ben Hine on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FollowBandTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"
#import "FilterGlobalImageDownloader.h"

@implementation FollowBandTableCell

@synthesize nameLabel = nameLabel_;
@synthesize profileImage = profileImage_;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, 210, 50)];
		nameLabel_.backgroundColor = [UIColor clearColor];
		nameLabel_.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1];
		nameLabel_.font = FILTERFONT(16);
		nameLabel_.text = @"...And You Will Know Us By The Trail Of Dead";
		nameLabel_.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		nameLabel_.numberOfLines = 0;
		
		
		profileImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 48, 48)];
		profileImage_.layer.cornerRadius = 5;
		profileImage_.clipsToBounds = YES;
		//testing
		profileImage_.image = [UIImage imageNamed:@"sm_no_image.png"];
		profileImage_.backgroundColor = [UIColor clearColor];
		[self addSubview:profileImage_];
		
		
		[self addSubview:nameLabel_];
		

		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

-(void)resetImage {
	profileImage_.image = [UIImage imageNamed:@"sm_no_image.png"];
}

- (void)setImageURL:(NSString*)url {
	
	if (url != nil) {
		
		UIImage *img = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:url object:self selector:@selector(posterImageDownloaded:)];
		
		if(img) {
			
			profileImage_.image = img;
		}
	}
}

-(void)posterImageDownloaded:(id)sender {
	profileImage_.image = [(NSNotification*)sender image];
}

@end
