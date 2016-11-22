//
//  FilterFeaturedSongView.m
//  TheFilter
//
//  Created by Ben Hine on 3/22/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "FilterFeaturedSongView.h"
#import "FilterPlayerController.h"
#import "Common.h"
#import "FilterDataObjects.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation FilterFeaturedSongView

@synthesize currentTrack = currentTrack_;
@synthesize playButton = playButton_;
@synthesize songTitle = songTitle_;
@synthesize songTime = songTime_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		playButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton_ addTarget:self action:@selector(songButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		playButton_.frame = CGRectMake(0, 7, 35, 35);
        
		[self addSubview:playButton_];
		
		songTitle_ = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, 210, 20)];
		songTitle_.backgroundColor = [UIColor clearColor];
		songTitle_.textColor = LIGHT_TEXT_COLOR;
		songTitle_.font = FILTERFONT(13);
		
		[self addSubview:songTitle_];
		
        songTime_ = [[UILabel alloc] initWithFrame:CGRectMake(260, 15, 40, 20)];
        songTime_.backgroundColor = [UIColor clearColor];
        songTime_.textAlignment = UITextAlignmentRight;
        songTime_.textColor = DARK_TEXT_COLOR;
        songTime_.font = FILTERFONT(12);
        
        [self addSubview:songTime_];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerChanged:) name:@"PlayerTrackChanged" object:nil];
        
    }
    return self;
}

- (void) setCurrentTrack:(FilterTrack *)aTrack {
    currentTrack_ = aTrack;
    
    if([[FilterPlayerController sharedInstance] currentTrack].trackID == currentTrack_.trackID && [[FilterPlayerController sharedInstance] playerState] == kPlayerStatePlaying) {
        [playButton_ setBackgroundImage:[UIImage imageNamed:@"hs_pause_button.png"] forState:UIControlStateNormal];
    }
    else if([[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:currentTrack_.trackID]) {
        [playButton_ setBackgroundImage:[UIImage imageNamed:@"hs_play_button.png"] forState:UIControlStateNormal];
    }
    else {
        [playButton_ setBackgroundImage:[UIImage imageNamed:@"new_add_button.png"] forState:UIControlStateNormal];
    }
}

-(void)playerChanged:(id)sender {
    if([[FilterPlayerController sharedInstance] currentTrack].trackID == currentTrack_.trackID && [[FilterPlayerController sharedInstance] playerState] == kPlayerStatePlaying) {
        [playButton_ setBackgroundImage:[UIImage imageNamed:@"hs_pause_button.png"] forState:UIControlStateNormal];
    }
    else if([[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:currentTrack_.trackID]) {
        [playButton_ setBackgroundImage:[UIImage imageNamed:@"hs_play_button.png"] forState:UIControlStateNormal];
    }
    else {
        [playButton_ setBackgroundImage:[UIImage imageNamed:@"new_add_button.png"] forState:UIControlStateNormal];
    }
}


- (void)songButtonTapped:(id)sender {
    
    if([[FilterPlayerController sharedInstance] currentTrack].trackID == currentTrack_.trackID && [[FilterPlayerController sharedInstance] playerState] == kPlayerStatePlaying) {
        [[FilterPlayerController sharedInstance] pauseCurrentTrack];
    }
    else {
        BOOL shouldOverride = [[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:currentTrack_.trackID];
        
        [[FilterPlayerController sharedInstance] addTrackToPlaylist:currentTrack_ startPlaying:YES overrideCurrent:shouldOverride];
               
    }
    [self playerChanged:nil]; 
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PlayerTrackChanged" object:nil];
    [songTitle_ release];
    [songTime_ release];
    
    [super dealloc];
}


@end
