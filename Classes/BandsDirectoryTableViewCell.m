//
//  BandsDirectoryTableViewCell.m
//  TheFilter
//
//  Created by Patrick Hernandez on 3/9/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import "BandsDirectoryTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FilterGlobalImageDownloader.h"
#import "Common.h"

@implementation BandsDirectoryTableViewCell

@synthesize genreLabel = genreLabel_;
@synthesize artistLabel = artistLabel_;
@synthesize artistImage = artistImage_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		self.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		
		artistImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 48, 48)];
		artistImage_.image = [UIImage imageNamed:@"sm_no_image.png"];
		artistImage_.layer.cornerRadius = 5;
		artistImage_.clipsToBounds = YES;
		artistImage_.backgroundColor = [UIColor clearColor];
		[self addSubview:artistImage_];
		
		artistLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(65, 18, 200, 25)];
		artistLabel_.backgroundColor = [UIColor clearColor];
		artistLabel_.font = FILTERFONT(16);
		artistLabel_.textColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1];
		
		[self addSubview:artistLabel_];
		
    }
    return self;
}

-(void)resetImage {
	artistImage_.image = [UIImage imageNamed:@"sm_no_image.png"];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)setImageURL:(NSString*)url {
	
	if (url != nil)
		artistImage_.image = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:url object:self selector:@selector(posterImageDownloaded:)];
}

-(void)posterImageDownloaded:(id)sender {
	artistImage_.image = [(NSNotification*)sender image];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end
