//
//  FeaturedTrackTableCell.m
//  TheFilter
//
//  Created by Ben Hine on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeaturedTrackTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"
#import "FilterPlayerController.h"
#import "FilterGlobalImageDownloader.h"

@implementation FeaturedTrackTableCell

@synthesize trackLabel = trackLabel_;
@synthesize artistLabel = artistLabel_;
@synthesize artistImage = artistImage_;
@synthesize featuredTrack = featuredTrack_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		self.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		
		artistImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 48, 48)];
		artistImage_.image = [UIImage imageNamed:@"sm_no_image.png"];
		artistImage_.layer.cornerRadius = 5;
		artistImage_.backgroundColor = [UIColor clearColor];
		[self addSubview:artistImage_];
		
		trackLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, 200, 25)];
		trackLabel_.backgroundColor = [UIColor clearColor];
		trackLabel_.font = FILTERFONT(16);
		trackLabel_.textColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1];
	
		[self addSubview:trackLabel_];
		
		
		artistLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(65, 30, 200, 25)];
		artistLabel_.backgroundColor = [UIColor clearColor];
		artistLabel_.font = FILTERFONT(12);
		artistLabel_.textColor = [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1];
		
		[self addSubview:artistLabel_];
		 
		
		addPlaylistButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
		[addPlaylistButton_ setImage:[UIImage imageNamed:@"round_add_button.png"] forState:UIControlStateNormal];
		addPlaylistButton_.frame = CGRectMake(265, 6, 48, 48);
		[addPlaylistButton_ addTarget:self action:@selector(addPlaylistButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:addPlaylistButton_];
		
		//TODO: add button action/target - probably in tableviewdelegate
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
	
	
    
    // Configure the view for the selected state.
}

- (void)addPlaylistButtonTapped:(id)sender {
	[[FilterPlayerController sharedInstance] addTrackToPlaylist:featuredTrack_ startPlaying:YES overrideCurrent:NO];
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
