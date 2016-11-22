//
//  FeaturedSongView.m
//  TheFilter
//
//  Created by Ben Hine on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeaturedSongView.h"
#import "Common.h"
#import "FilterToolbar.h"
#import "FilterPlayerController.h"
#import "FilterAPIOperationQueue.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1];
#define BACKGROUND_COLOR [UIColor clearColor]

@interface FeaturedSongView () 
- (void)updateToolbarLabels;
@end

@implementation FeaturedSongView

@synthesize track = track_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		songInfo = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 30)];
		songInfo.backgroundColor = [UIColor clearColor];
		songInfo.textColor = LIGHT_TEXT_COLOR;
		songInfo.font = FILTERFONT(18);
		songInfo.shadowColor = [UIColor blackColor];
		songInfo.shadowOffset = CGSizeMake(0, 1);
		songInfo.text = @"Song Info";
		[self addSubview:songInfo];
		
		UIView *backgroundSection = [[[UIView alloc] initWithFrame:CGRectMake(10, 35, 300, 150)] autorelease];
		backgroundSection.layer.borderColor = [[UIColor blackColor] CGColor];
		backgroundSection.layer.borderWidth = 1;
		backgroundSection.layer.cornerRadius = 10;
		backgroundSection.layer.backgroundColor = [[UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1] CGColor];
		[self addSubview:backgroundSection];
		
		NSArray *categories = [NSArray arrayWithObjects:@"Title:", @"Album:", @"Artist:", @"Year:", @"Duration:", nil];
		for(int i = 0; i < 5; i++) {
			categoryLabel[i] = [[UILabel alloc] initWithFrame:CGRectMake(15, 40 + (30 * i), 70, 20)];
			categoryLabel[i].textColor = [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1];
			categoryLabel[i].backgroundColor = BACKGROUND_COLOR;
			categoryLabel[i].font = FILTERFONT(13);
			categoryLabel[i].text = [categories objectAtIndex:i];
			//categoriesLabel[i].numberOfLines = 0;
			[self addSubview:categoryLabel[i]];
		}		
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 40, 210, 20)];
		titleLabel.textColor = LIGHT_TEXT_COLOR;
		titleLabel.font = FILTERFONT(13);
		titleLabel.backgroundColor = BACKGROUND_COLOR;
		
		[self addSubview:titleLabel];
		
		albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 70, 210, 20)];
		albumLabel.textColor = LIGHT_TEXT_COLOR;
		albumLabel.font = FILTERFONT(13);
		albumLabel.backgroundColor = BACKGROUND_COLOR;
		[self addSubview:albumLabel];
		
		artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 100, 210, 20)];
		artistLabel.textColor = LIGHT_TEXT_COLOR;
		artistLabel.font = FILTERFONT(13);
		artistLabel.backgroundColor = BACKGROUND_COLOR;
		[self addSubview:artistLabel];
		
		yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 130, 210, 20)];
		yearLabel.textColor = LIGHT_TEXT_COLOR;
		yearLabel.font = FILTERFONT(13);
		yearLabel.backgroundColor = BACKGROUND_COLOR;
		[self addSubview:yearLabel];
		
		durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 160, 210, 20)];
		durationLabel.textColor = LIGHT_TEXT_COLOR;
		durationLabel.font = FILTERFONT(13);
		durationLabel.backgroundColor = BACKGROUND_COLOR;
		[self addSubview:durationLabel];
				
		likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likeButton.frame = CGRectMake(10, 205, 147, 45);
		likeButton.titleLabel.font = FILTERFONT(17);
		
		[likeButton setTitle:@"Play" forState:UIControlStateNormal];
		
		[likeButton setBackgroundImage:[UIImage imageNamed:@"song_info_button.png"] forState:UIControlStateNormal];
		[likeButton addTarget:self action:@selector(likePushed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:likeButton];
		/*
		downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
		downloadButton.frame = CGRectMake(10, 265, 300, 45);
		downloadButton.titleLabel.font = FILTERFONT(17);
		[downloadButton setTitle:@"Download Song" forState:UIControlStateNormal];
		[downloadButton setBackgroundImage:[UIImage imageNamed:@"wide_button.png"] forState:UIControlStateNormal];
		[downloadButton addTarget:self action:@selector(downloadPushed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:downloadButton];
		*/
		shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shareButton.frame = CGRectMake(165, 205, 147, 45);
		shareButton.titleLabel.font = FILTERFONT(17);
		[shareButton setTitle:@"Add to Queue" forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
		[shareButton setBackgroundImage:[UIImage imageNamed:@"song_info_button.png"] forState:UIControlStateNormal];
		[shareButton addTarget:self action:@selector(sharePushed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:shareButton];
		
		/*
		profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profileButton.frame = CGRectMake(165, 265, 147, 45);
		profileButton.titleLabel.font = FILTERFONT(17);
		[profileButton setTitle:@"View Profile" forState:UIControlStateNormal];
		[profileButton setBackgroundImage:[UIImage imageNamed:@"song_info_button.png"] forState:UIControlStateNormal];
		[profileButton addTarget:self action:@selector(profilePushed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:profileButton];
		*/
		
		
    }
    return self;
}
-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
		
	[self updateToolbarLabels];
}

- (void)updateToolbarLabels {
	
	[[FilterToolbar sharedInstance] showPrimaryLabel:track_.trackTitle];
	[[FilterToolbar sharedInstance] showSecondaryLabel:track_.trackArtist];
}

- (void)refreshData {
    if([[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:track_.trackID]) {
		shareButton.enabled = NO;
	}
	else {
        shareButton.enabled = YES;
    }
}

- (void)setTrack:(FilterTrack*)trackObj {

	track_ = trackObj;
	[titleLabel setText:track_.trackTitle];
	[albumLabel setText:track_.trackAlbum];
	[artistLabel setText:track_.trackArtist];
	[yearLabel setText:track_.trackYear];
	[durationLabel setText:[NSString stringWithFormat:@"%d:%02d", [track_.durationSeconds intValue] / 60, [track_.durationSeconds intValue] % 60]];
	
	if(track_.trackID == [[FilterPlayerController sharedInstance] currentTrack].trackID) {
		[likeButton setTitle:@"Pause" forState:UIControlStateNormal];
	}
	
	if([[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:track_.trackID]) {
		shareButton.enabled = NO;
	}
	
	
	[self updateToolbarLabels];
}

-(void)likePushed {
	if([likeButton.titleLabel.text isEqualToString:@"Play"]) {
		[[FilterPlayerController sharedInstance] addTrackToPlaylist:self.track startPlaying:YES overrideCurrent:YES];
		[likeButton setTitle:@"Pause" forState:UIControlStateNormal];
	} else {
		[[FilterPlayerController sharedInstance] pauseCurrentTrack];
		[likeButton setTitle:@"Play" forState:UIControlStateNormal];
	}
}

-(void)downloadPushed {
    NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:track_.trackID] forKey:@"trackID"];
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeDownloadTrack andCallback:self];
}

-(void)sharePushed {
	[[FilterPlayerController sharedInstance] addTrackToPlaylist:self.track startPlaying:NO overrideCurrent:NO];
	shareButton.enabled = NO;
}

-(void)profilePushed {
	
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata; {

	//TODO: alert view
	
}


-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFailWithError:(NSError*)err; {
	
	
}





@end
