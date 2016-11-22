//
//  FilterPlayerController.h
//  TheFilter
//
//  Created by Ben Hine on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheFilterMultimediaManagerProtocols.h"
#import "FilterView.h"
#import "FilterDataObjects.h"
#import "LoadingIndicator.h"

@class FilterPlayerSeekBar;
@class TheFilterMultimediaManager, StreamingAudioDriver;
@class FilterPlayerSlideshowTableContainer;


typedef enum {
	
	kPlayerStatePlaying,
	kPlayerStatePaused,
	kPlayerStateStopped,

} PlayerState;



@interface FilterPlayerController : FilterView <StreamMediaUI, UITableViewDelegate, UITableViewDataSource, FilterAPIOperationDelegate, UIActionSheetDelegate> {

	
	PlayerState playerState_;
	
	
	UIButton *clearQueueButton;
	
	NSMutableArray *playlistTracks_;
	
	FilterTrack *currentTrack_;
	
	UIImageView *bottomBackgroundView;
	
	FilterPlayerSlideshowTableContainer *contentContainer;
	
	//TODO: make this a class that loads and transitions its own images
	UIImageView *imageViewer;
	
	UIButton *seekBackButton, *seekForwardButton, *playPauseButton;
	UIButton *actionButton, *rateButton;
	
	FilterPlayerSeekBar *seekBar;
	
	TheFilterMultimediaManager *mediaManager_;
	StreamingAudioDriver *audioDriver_;
	
    LoadingIndicator *indicator;
	
}

@property (nonatomic, retain) NSMutableArray *playlistTracks;
@property (nonatomic, readonly, assign) PlayerState playerState;
@property (nonatomic, readonly, retain) FilterTrack *currentTrack;

+ (id)sharedInstance;

- (void)addTrackToPlaylist:(FilterTrack*)aTrack startPlaying:(BOOL)playing overrideCurrent:(BOOL)override;
- (void)pauseCurrentTrack;
- (BOOL)isTrackInPlaylistWithID:(NSInteger)trackID;
- (void)performFlipTransition;
- (void)setEditing:(BOOL)editing;
- (void)userFinishedScrubbing;

@end
