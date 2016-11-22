//
//  FilterPlayerController.m
//  TheFilter
//
//  Created by Ben Hine on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterPlayerController.h"
#import "FilterPlayerSeekBar.h"
#import "Common.h"

#import "TheFilterMultimediaManager.h"
#import "StreamingAudioDriver.h"
#import "FilterToolbar.h"
#import "FilterPlayerButton.h"
#import "FilterPlayerTableCell.h"
#import "FilterAPIOperationQueue.h"
#import "FilterPlayerSlideshowTableContainer.h"
#import "FilterGlobalImageDownloader.h"
#import "FilterAPIOperationQueue.h"

#define PLAYERVIEWFRAME CGRectMake(320, 20, 320, 460)

@interface FilterPlayerController ()

-(void)updateCurrentTrack:(FilterTrack*)track;

@end

@implementation FilterPlayerController

@synthesize playlistTracks = playlistTracks_;
@synthesize playerState = playerState_;
@synthesize currentTrack = currentTrack_;

static FilterPlayerController *singleton = nil;

#pragma mark -
#pragma mark Singleton Methods
//NOTE: this is following the apple recommended design pattern for singletons - so don't freak out about the memory stuff

+(id)sharedInstance {
	
	@synchronized(self) {
		
		if(singleton == nil) {
			singleton = [[FilterPlayerController alloc] initWithFrame:PLAYERVIEWFRAME];
		}
		return singleton;
	}
}

-(id)initWithFrame:(CGRect)frame {
	
	self = [super initWithFrame:(CGRect)frame];
	if(self) {
		
		playerState_ = kPlayerStateStopped;
		
		mediaManager_ = [[TheFilterMultimediaManager alloc] init];
		mediaManager_.delegateUI = singleton; //TODO: make this player controller
		
		audioDriver_ = [[StreamingAudioDriver alloc] init];
		//bidirectional protocols yay!
		audioDriver_.delegate = mediaManager_;
		mediaManager_.delegateAudioDriver = audioDriver_;
		playlistTracks_ = [[NSMutableArray alloc] init];
		
		bottomBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"music_player_control_bkg.png"]];
		bottomBackgroundView.frame = CGRectMake(0, 334, 320, 106);
		[self addSubview:bottomBackgroundView];
		
		seekBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[seekBackButton setBackgroundImage:[UIImage imageNamed:@"music_previous_button.png"] forState:UIControlStateNormal];
		[seekBackButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_music_previous_button.png"] forState:UIControlStateHighlighted];
		seekBackButton.frame = CGRectMake(78, 390, 36, 36);
		[seekBackButton addTarget:self action:@selector(prevTrack:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:seekBackButton];
		seekBackButton.enabled = NO;
		
		seekForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[seekForwardButton setBackgroundImage:[UIImage imageNamed:@"music_next_button.png"] forState:UIControlStateNormal];
		[seekForwardButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_music_next_button.png"] forState:UIControlStateHighlighted];
		seekForwardButton.frame = CGRectMake(206, 390, 36, 36);
		[seekForwardButton addTarget:self action:@selector(nextTrack:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:seekForwardButton];
		seekForwardButton.enabled = NO;

		playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[playPauseButton setBackgroundImage:[UIImage imageNamed:@"music_play_button.png"] forState:UIControlStateNormal];
		[playPauseButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_music_play_button.png"] forState:UIControlStateHighlighted];
		[playPauseButton setBackgroundImage:[UIImage imageNamed:@"music_pause_button.png"] forState:UIControlStateSelected];
		[playPauseButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_music_pause_button.png"] forState:(UIControlStateHighlighted | UIControlStateSelected)];
		[playPauseButton addTarget:self action:@selector(playPausePushed:) forControlEvents:UIControlEventTouchUpInside];
		playPauseButton.frame = CGRectMake(134, 381, 53, 53);
		playPauseButton.enabled = NO;
		[self addSubview:playPauseButton];
        
		
        indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(134, 381, 21, 21) andType:kPlayerIndicator];
        
		actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[actionButton setImage:[UIImage imageNamed:@"sm_share_icon.png"] forState:UIControlStateNormal];
		[actionButton setImage:[UIImage imageNamed:@"pressed_down_sm_share_icon.png"] forState:UIControlStateHighlighted];
		//actionButton.frame = CGRectMake(19, 390, 36, 36);
        actionButton.frame = CGRectMake(270, 390, 36, 36);
		actionButton.enabled = NO;
		[actionButton addTarget:self action:@selector(actionPushed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:actionButton];
    
//		rateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		[rateButton setImage:[UIImage imageNamed:@"sm_like_icon.png"] forState:UIControlStateNormal];
//		[rateButton setImage:[UIImage imageNamed:@"pressed_down_sm_like_icon.png"] forState:UIControlStateHighlighted];
//		
//		rateButton.frame = CGRectMake(270, 390, 36, 36);
//		[rateButton addTarget:self action:@selector(ratePushed:) forControlEvents:UIControlEventTouchUpInside];
//		rateButton.enabled = NO;
//		[self addSubview:rateButton];
		
		seekBar = [[FilterPlayerSeekBar alloc] initWithFrame:CGRectMake(0, 345, 320, 40)];
		[self addSubview:seekBar];
		seekBar.enabled = NO;
		
		contentContainer = [[FilterPlayerSlideshowTableContainer alloc] initWithFrame:CGRectMake(0, 25, 320, 319)];
		contentContainer.tableView.delegate = self;
		contentContainer.tableView.dataSource = self;
		contentContainer.layer.zPosition = -5;
		[self addSubview:contentContainer];
		[self sendSubviewToBack:contentContainer];
		
		//this is probably not necessary
		/*
		CATransform3D tran = self.layer.transform;
		tran.m34 = -1/800;
		self.layer.sublayerTransform = tran;
		*/
	}
	return self;
	
}

#pragma mark - 
#pragma mark Singleton pattern

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - 
#pragma mark Methods

-(void)performFlipTransition {
	[contentContainer performFlipTransition];
}



-(BOOL)isTrackInPlaylistWithID:(NSInteger)trackID {
	
	for(FilterTrack *aTrack in playlistTracks_) {
		if(aTrack.trackID == trackID) {
			return YES;
		}
	}
	return NO;
}


-(void)pauseCurrentTrack {

	//TODO: change some states
	[mediaManager_ pause];
	playerState_ = kPlayerStatePaused;
}

- (void)stopCurrentTrack {
    [mediaManager_ stop];
    [seekBar resetBar];
    [self updateCurrentTrack:nil];
    playerState_ = kPlayerStateStopped;
}


-(void)addTrackToPlaylist:(FilterTrack*)aTrack startPlaying:(BOOL)playing overrideCurrent:(BOOL)override {

	if(!aTrack) { return; } //error bail out
	
	playPauseButton.enabled = YES;
	seekBackButton.enabled = YES;
	seekForwardButton.enabled = YES;
	actionButton.enabled = YES;
	//rateButton.enabled = YES;
	
	seekBar.enabled = YES;
	
	NSInteger playlistIndex = -1;
	

	for(FilterTrack *track in playlistTracks_) {
		if(track.trackID == aTrack.trackID) {
			playlistIndex = [playlistTracks_ indexOfObject:aTrack];
			
			
			//[contentContainer.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:playlistIndex inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
			
			break;
		}
	}
	
	if(playlistIndex >= 0) {
		
		for(int i = playlistIndex; i < [playlistTracks_ count] - 1; i++) {
			
			[playlistTracks_ exchangeObjectAtIndex:i withObjectAtIndex:i+1];
			
		}
		
		[contentContainer.tableView reloadData];
		[contentContainer.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[playlistTracks_ count] - 1 inSection:1] 
												animated:NO 
										  scrollPosition:UITableViewScrollPositionNone];
		
	} else {
        [playlistTracks_ addObject:aTrack];
	}   
    
    [contentContainer.tableView reloadData];
    if (playing) {
        [contentContainer.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[playlistTracks_ count] - 1 inSection:1] 
                                                animated:NO 
                                          scrollPosition:UITableViewScrollPositionNone];
    }

	if((!mediaManager_.isPlaying && playing) || override) {
		if(aTrack.trackID != currentTrack_.trackID) {
			[mediaManager_ stop];
		}
			
		[mediaManager_ playURL:aTrack.urlString];
		playerState_ = kPlayerStatePlaying;
		[self updateCurrentTrack:aTrack];
	}
	
	
	if (!aTrack.trackBand && aTrack.bandID) {
        NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:aTrack.bandID] forKey:@"bandID"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandDetails andCallback:self];
	}
	
	//[contentContainer.tableView reloadData];
	
	// NSLog(@"PLAYLIST: %@", [playlistTracks_ description]);
}

-(void)updateCurrentTrack:(FilterTrack*)track {
	
    if (track == nil) {
        contentContainer.imageViewer.image = [UIImage imageNamed:@""];
        currentTrack_ = nil;
        
        FilterToolbar *shared = [FilterToolbar sharedInstance];
        [shared showLogo];
        
        return;
    }
    
	currentTrack_ = track;
	
	if (track.trackBand) {
		contentContainer.imageViewer.image = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:track.trackBand.profilePicLargeURL object:contentContainer selector:@selector(imageFinished:)];
	} else {
        NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:track.bandID] forKey:@"bandID"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandDetails andCallback:self];
        
	}
	
	if(self.frame.origin.x == 0) {
        
		FilterToolbar *shared = [FilterToolbar sharedInstance];
		[shared showPrimaryLabel:track.trackArtist];
		[shared showSecondaryLabel:track.trackTitle];
        
		NSInteger currentIndex = [playlistTracks_ indexOfObject:currentTrack_];        
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
        
        [contentContainer.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionNone];
	}
}


-(void)configureToolbar {
	FilterToolbar *shared = [FilterToolbar sharedInstance];
	[shared showPlayerButton:NO];
	
	[shared setRightButtonWithType:kToolbarButtonTypePlaylistList]; 
	
	[shared setLeftButtonWithType:kToolbarButtonTypeBackButton];
	
	[shared showSecondaryToolbar:kSecondaryToolbar_None];
	
	
	if(currentTrack_) {
	[shared showPrimaryLabel:currentTrack_.trackArtist];
	[shared showSecondaryLabel:currentTrack_.trackTitle];
	}
}

- (void)setEditing:(BOOL)editing {
    [contentContainer setEditing:editing];
}

-(void)userFinishedScrubbing {
	[mediaManager_ scrubbingProgress:seekBar.currentProgress / seekBar.totalLength];
}

-(void)playPausePushed:(id)sender {
	
	if(playPauseButton.selected) {
		[mediaManager_ pause];
		playerState_ = kPlayerStatePaused;
		
	} else {
        if(currentTrack_ != nil) {
            [mediaManager_ playURL:currentTrack_.urlString];
            //playPauseButton.hidden = YES;
            playerState_ = kPlayerStatePlaying;
            [indicator startAnimating];
            [self addSubview:indicator];
            
            [playPauseButton setEnabled:NO];
        }
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerTrackChanged" object:nil];
	
}


-(void)nextTrack:(id)sender {
	
	if(mediaManager_.isPlaying && currentTrack_) {
		
		NSInteger currentIndex = [playlistTracks_ indexOfObject:currentTrack_];
		
		if (currentIndex + 1 < [playlistTracks_ count]) {
			[self updateCurrentTrack:[playlistTracks_ objectAtIndex:currentIndex + 1]];
			[mediaManager_ stop];
			[mediaManager_ playURL:currentTrack_.urlString];
			playerState_ = kPlayerStatePlaying;
			[contentContainer.tableView reloadData];
			[seekBar resetBar];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerTrackChanged" object:nil];
		} else { //TODO: rollover?
			
		}
		
	}
	
	
}


-(void)prevTrack:(id)sender {
	
	
	if(mediaManager_.isPlaying && currentTrack_) {
		
		if(mediaManager_.currentTrack.playProgress <= 0.01) { //TODO: tune this value to mean 1 or 2 seconds instead of just 1% of the track
			//go to previous track
			NSInteger index = [playlistTracks_ indexOfObject:currentTrack_];
			
			if(index > 0) {
				[self updateCurrentTrack:[playlistTracks_ objectAtIndex:index - 1]];
				[mediaManager_ stop];
				[mediaManager_ playURL:currentTrack_.urlString];
				[contentContainer.tableView reloadData];
				return;
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerTrackChanged" object:nil];
		}
		
	
		[mediaManager_ scrubbingProgress:0];
		
		//TODO: update player progress
		
	}
	
	
}



#pragma mark -
#pragma mark StreamMediaUIDelegate

- (void)mediaEnded:(BOOL)songOver {
	
	//TODO: reset buttons and do playlist management
	if(songOver) {
		playPauseButton.selected = NO;
		FilterToolbar *shared = [FilterToolbar sharedInstance];
		
		shared.playerButton.selected = NO;
		
		
		NSInteger index = [playlistTracks_ indexOfObject:currentTrack_];
		if(index + 1 < [playlistTracks_ count]) { //TODO: also support repeat
			
			[self updateCurrentTrack:[playlistTracks_ objectAtIndex:index + 1]];
			[mediaManager_ playURL:currentTrack_.urlString];
			
			
			
		} else if (contentContainer.repeatButton.selected) {
			[self updateCurrentTrack:[playlistTracks_ objectAtIndex:0]];
			[mediaManager_ playURL:currentTrack_.urlString];
			[contentContainer.tableView reloadData];
		}
		
		

	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerTrackChanged" object:nil];
		
}
- (void)mediaStarted {
	[indicator stopAnimatingAndRemove];
    
    [playPauseButton setEnabled:YES];
	playPauseButton.selected = YES;
	//playPauseButton.hidden = NO;
	CGFloat length = [currentTrack_.durationSeconds floatValue];
	seekBar.totalLength = length;
	
	FilterToolbar *shared = [FilterToolbar sharedInstance];
	
	shared.playerButton.selected = YES;
	
}
- (void)mediaPaused {
	playPauseButton.selected = NO;
	
	FilterToolbar *shared = [FilterToolbar sharedInstance];
	
	shared.playerButton.selected = NO;
}
- (void)mediaProgress:(float)progress {
	
	//playPauseButton.hidden = NO;
	//[indicator stopAnimatingAndRemove];
    
	if(!seekBar.scrubbing) {
		seekBar.currentProgress = progress * seekBar.totalLength; 
	}
}


- (void)mediaError:(NSError *)error {
    NSString *title;
    NSString *message;

    title = [error domain];
    message = [error description];
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle: title
							   message: message
							   delegate:self
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}



- (void)downloadProgress:(float)progress {
	seekBar.downloadProgress = progress * seekBar.totalLength;
}





#pragma mark -
#pragma mark UITableViewDelegate/dataSource

-(void)clearPushed:(id)sender {
	[playlistTracks_ removeAllObjects];
    if([contentContainer.tableView numberOfSections] != 0)
        [contentContainer.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
        //[contentContainer.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
    
    [self stopCurrentTrack];
    
    playPauseButton.enabled = NO;
    seekBackButton.enabled = NO;
    seekForwardButton.enabled = NO;
    actionButton.enabled = NO;
    seekBar.enabled = NO;

    [contentContainer setEditing:NO];
    
	//TODO: also clear out player
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if([playlistTracks_ count] > 0) {
	return 1;
	}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [playlistTracks_ count];
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FilterPlayerTableCell *cell = (FilterPlayerTableCell*)[tableView dequeueReusableCellWithIdentifier:@"queueCell"];
	
	if(!cell) {
		cell = [[[FilterPlayerTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"queueCell"] autorelease];
	}
				
	cell.numberLabel.text = [NSString stringWithFormat:@"%d.", indexPath.row + 1];
	
	
	
	/* this code might work once we're getting back stuff from the api - also we might want to consider having the cell own a track object and just passing that over
	 */
	FilterTrack *aTrack = [playlistTracks_ objectAtIndex:indexPath.row];
	cell.trackLabel.text = aTrack.trackTitle;
	cell.artistLabel.text = aTrack.trackArtist;
	cell.lengthLabel.text = [NSString stringWithFormat:@"%d:%02d", [aTrack.durationSeconds intValue] / 60, [aTrack.durationSeconds intValue] % 60];
	if (aTrack == currentTrack_) {
		[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		
	} else {
		
	}
				
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 46;
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FilterTrack *track = [playlistTracks_ objectAtIndex:indexPath.row];

	if(track == currentTrack_ && mediaManager_.isPlaying) {//do nothing - you just selected the currently playing track
		if(mediaManager_.wasPaused) {
			[mediaManager_ playURL:currentTrack_.urlString];
            
            [indicator startAnimating];
            [self addSubview:indicator];
            
            [playPauseButton setEnabled:NO];
		}
		return;
	}
    
    [indicator startAnimating];
    [self addSubview:indicator];
    
    [playPauseButton setEnabled:NO];
    
	[self updateCurrentTrack:track];
		
	
	if(mediaManager_.isPlaying) {
		[mediaManager_ stop];
	}
	
	[mediaManager_ playURL:track.urlString];
	
	
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	//FilterTrack *trackToMove = [playlistTracks_ objectAtIndex:fromIndexPath.row];

	
	
	int j = (int)toIndexPath.row; //index paths are unsigned - that is bad newz for trying to get negatives so we'll cast them
	int k = (int)fromIndexPath.row;
	NSInteger sign = ((j - k) > 0) ? 1 : (-1);
	int i = fromIndexPath.row;
	
	
	while (i != toIndexPath.row) {
		[playlistTracks_ exchangeObjectAtIndex:i withObjectAtIndex:i + sign];
		i += sign;
	}
	
	
	
	[tableView reloadData];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	NSInteger idx = (NSInteger)indexPath.row;
	
    if (currentTrack_ == [playlistTracks_ objectAtIndex:idx]) {
        [self stopCurrentTrack];
    }
    
    [playlistTracks_ removeObjectAtIndex:idx];
    
    if ([playlistTracks_ count] == 0) {
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
        playPauseButton.enabled = NO;
        seekBackButton.enabled = NO;
        seekForwardButton.enabled = NO;
        actionButton.enabled = NO;
        seekBar.enabled = NO;
        
        [contentContainer setEditing:NO];
    }
    else {
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        
        if (idx < [playlistTracks_ count]) {
            [self updateCurrentTrack:[playlistTracks_ objectAtIndex:idx]];
        }
        else {
            [self updateCurrentTrack:[playlistTracks_ objectAtIndex:0]];
        }
    }
	
	
}


-(void)actionPushed:(id)sender {
	
	NSString *followString = (currentTrack_.trackBand.following) ? @"Unfollow band" : @"Follow band";
	
	UIActionSheet *axnSheet = [[[UIActionSheet alloc] initWithTitle:@""
														   delegate:self 
												  cancelButtonTitle:@"Cancel" 
											 destructiveButtonTitle:nil otherButtonTitles:followString, nil] autorelease];
  /*  UIActionSheet *axnSheet = [[[UIActionSheet alloc] initWithTitle:@""
														   delegate:self
												  cancelButtonTitle:@"Cancel"
											 destructiveButtonTitle:nil otherButtonTitles:followString,@"Download song", nil] autorelease];*/
	axnSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[axnSheet showInView:self];
	
	
}

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata; {
	
	
	
	
	switch(filterop.type) {
		case kFilterAPITypeBandFollow:
			//I don't like this but we'll need to be pushing this stuff to the cache to deal with it properly - HACK
			for(FilterTrack *aTrack in playlistTracks_) {
				if (aTrack.bandID == currentTrack_.bandID) {
					aTrack.trackBand.following = YES;
				}
			}
			
			
			break;
		case kFilterAPITypeBandUnfollow:
			//I don't like this but we'll need to be pushing this stuff to the cache to deal with it properly - HACK
			for(FilterTrack *aTrack in playlistTracks_) {
				if (aTrack.bandID == currentTrack_.bandID) {
					aTrack.trackBand.following = NO;
				}
			}
			break;
		case kFilterAPITypeBandDetails:
		{
			FilterBand *newBand = (FilterBand*)data;
	
			for(FilterTrack *aTrack in playlistTracks_) {
				if(aTrack.bandID == newBand.bandID) {
					aTrack.trackBand = newBand;
			
				}
			}
	
			if(currentTrack_.bandID == newBand.bandID) {
				contentContainer.imageViewer.image = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:newBand.profilePicLargeURL object:contentContainer selector:@selector(imageFinished:)];
			}
			break;	
		}
		case kFilterAPITypeDownloadTrack:
			//TODO: show alert view
			break;
		default:
			break;
	}
			
}

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFailWithError:(NSError*)err; {
	
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case 0: //Follow/unfollow
			if(currentTrack_.trackBand.following) {
                NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:currentTrack_.trackBand.bandID] forKey:@"bandID"];
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandUnfollow andCallback:self];
			} else {
                NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:currentTrack_.trackBand.bandID] forKey:@"bandID"];
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandFollow andCallback:self];
			}
			break;

		case 1:
   /*     //Download
        {
            NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:currentTrack_.trackID] forKey:@"trackID"];
            [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeDownloadTrack andCallback:self];
        }
			break;
        
		case 2:
    */
        //Cancel
            
			break;
		default:
			break;
	}
}


@end
