//
//  FilterBandMediaTableCell.m
//  TheFilter
//
//  Created by John Thomas on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterBandMediaTableCell.h"
#import "FilterPlayerController.h"
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@interface FilterBandMediaTableCell ()
-(void)playerChanged:(id)sender;
@end

@implementation FilterBandMediaTableCell

@synthesize bandTrack = bandTrack_;
@synthesize songTitle = songTitle_;
@synthesize songDuration = songDuration_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        // Initialization code.

//		
//		playButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 35, 36)];
//		[playButton setBackgroundImage:[UIImage imageNamed:@"band_play_button.png"] forState:UIControlStateNormal];
//		[playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//		[self.contentView addSubview:playButton];
//		
//		songTitle_ = [[UILabel alloc] initWithFrame:CGRectMake(60, 17, 180, 15)];
//		songTitle_.font = FILTERFONT(13);
//		songTitle_.textColor = LIGHT_TEXT_COLOR;
//		songTitle_.adjustsFontSizeToFitWidth = YES;
//		songTitle_.minimumFontSize = 10;
//		songTitle_.textAlignment = UITextAlignmentLeft;
//		songTitle_.backgroundColor = [UIColor clearColor];
//		[self.contentView addSubview:songTitle_];
//
//		songDuration_ = [[UILabel alloc] initWithFrame:CGRectMake(260, 18, 50, 14)];
//		songDuration_.font = FILTERFONT(12);
//		songDuration_.textColor = DARK_TEXT_COLOR;
//		songDuration_.adjustsFontSizeToFitWidth = YES;
//		songDuration_.minimumFontSize = 10;
//		songDuration_.textAlignment = UITextAlignmentRight;
//		songDuration_.backgroundColor = [UIColor clearColor];
//		[self.contentView addSubview:songDuration_];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton addTarget:self action:@selector(songButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		playButton.frame = CGRectMake(10, 7, 35, 35);
        
//        if([[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:bandTrack_.trackID]) {
//            [playButton setBackgroundImage:[UIImage imageNamed:@"hs_play_button.png"] forState:UIControlStateNormal];
//        }
//        else {
//            [playButton setBackgroundImage:[UIImage imageNamed:@"new_add_button.png"] forState:UIControlStateNormal];
//        }
//        
        [self playerChanged:nil];
        
		[self addSubview:playButton];
		
		songTitle_ = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, 210, 20)];
		songTitle_.backgroundColor = [UIColor clearColor];
		songTitle_.textColor = LIGHT_TEXT_COLOR;
		songTitle_.font = FILTERFONT(13);
		
		//songTitle.text = @"This is a song by a bro";
		
		[self addSubview:songTitle_];
		
        songDuration_ = [[UILabel alloc] initWithFrame:CGRectMake(260, 15, 40, 20)];
        songDuration_.backgroundColor = [UIColor clearColor];
        songDuration_.textAlignment = UITextAlignmentRight;
        songDuration_.textColor = DARK_TEXT_COLOR;
        songDuration_.font = FILTERFONT(12);
        
        //songTime.text = @"13:37";
        
        [self addSubview:songDuration_];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerChanged:) name:@"PlayerTrackChanged" object:nil];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)setBandTrack:(FilterTrack *)bandTrack {
    bandTrack_ = bandTrack;
    
    if([[FilterPlayerController sharedInstance] currentTrack].trackID == bandTrack_.trackID && [[FilterPlayerController sharedInstance] playerState] == kPlayerStatePlaying) {
        [playButton setBackgroundImage:[UIImage imageNamed:@"band_pause_button.png"] forState:UIControlStateNormal];
    }
    else if([[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:bandTrack_.trackID]) {
        [playButton setBackgroundImage:[UIImage imageNamed:@"band_play_button.png"] forState:UIControlStateNormal];
    }
    else {
        [playButton setBackgroundImage:[UIImage imageNamed:@"new_add_button.png"] forState:UIControlStateNormal];
    }
}

-(void)playerChanged:(id)sender {
    if([[FilterPlayerController sharedInstance] currentTrack].trackID == bandTrack_.trackID && [[FilterPlayerController sharedInstance] playerState] == kPlayerStatePlaying) {
        [playButton setBackgroundImage:[UIImage imageNamed:@"band_pause_button.png"] forState:UIControlStateNormal];
    }
    else if([[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:bandTrack_.trackID]) {
        [playButton setBackgroundImage:[UIImage imageNamed:@"band_play_button.png"] forState:UIControlStateNormal];
    }
    else {
        [playButton setBackgroundImage:[UIImage imageNamed:@"new_add_button.png"] forState:UIControlStateNormal];
    }
}


- (void)songButtonTapped:(id)sender {
    
    if([[FilterPlayerController sharedInstance] currentTrack].trackID == bandTrack_.trackID && [[FilterPlayerController sharedInstance] playerState] == kPlayerStatePlaying) {
        [[FilterPlayerController sharedInstance] pauseCurrentTrack];
    }
    else {
        BOOL shouldOverride = [[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:bandTrack_.trackID];
        
        [[FilterPlayerController sharedInstance] addTrackToPlaylist:bandTrack_ startPlaying:YES overrideCurrent:shouldOverride];
        
    }
    [self playerChanged:nil]; 
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PlayerTrackChanged" object:nil];
    
    [super dealloc];
}

@end
