//
//  FilterVideoPlayView.m
//  TheFilter
//
//  Created by Jerry on 9/26/13.
//
//

#import "FilterVideoPlayView.h"
#import "FilterYoutubeView.h"
#import "FilterToolbar.h"
#import "FilterPlayerController.h"

@implementation FilterVideoPlayView

@synthesize youTubeView = youTubeView_;
@synthesize ytVideo;
@synthesize currentTrack = currentTrack_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.youTubeView.backgroundColor = [UIColor blackColor];
        toolBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btm_bar.png"]];
        toolBar.frame = CGRectMake(0, 410, 320, 51);
        toolBar.userInteractionEnabled = YES;
        [self addSubview:toolBar];
        [UIApplication sharedApplication].statusBarHidden = YES;
        
    }
    return self;
}

- (void)dealloc {
    // HACK
    if ([UIApplication sharedApplication].statusBarHidden) {
        [UIApplication sharedApplication].statusBarHidden = NO;

        [[FilterToolbar sharedInstance] setAlpha:1.0];

    }
    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait animated:NO];
    
    currentTrack_ = [[FilterPlayerController sharedInstance] currentTrack];
    BOOL shouldOverride = [[FilterPlayerController sharedInstance] isTrackInPlaylistWithID:currentTrack_.trackID];
    
    [[FilterPlayerController sharedInstance] addTrackToPlaylist:currentTrack_ startPlaying:YES overrideCurrent:shouldOverride];
    
    [super dealloc];
}

- (void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	// make sure the main toolbar displays the correct subtoolbar
	if (newSuperview == nil){
        //self.clipsToBounds = YES;
        [self.stackController.delegate setWantsFullScreenLayout:NO];
        //[UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutToolbars) object:nil];
        [UIApplication sharedApplication].statusBarHidden = YES;
        [[FilterToolbar sharedInstance] setAlpha:1.0];
        [toolBar setAlpha:1.0];
        //	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
    }
	else {
        //self.clipsToBounds = YES;
        [self.stackController.delegate setWantsFullScreenLayout:NO];
        [UIApplication sharedApplication].statusBarHidden = YES;
       // [self performSelector:@selector(fadeOutToolbars) withObject:nil afterDelay:1.0];
	}
}


- (void) didMoveToSuperview {
    // HACK
    if ([UIApplication sharedApplication].statusBarHidden) {
        [UIApplication sharedApplication].statusBarHidden = YES;
        [[FilterToolbar sharedInstance] setAlpha:1.0];
        [toolBar setAlpha:1.0];
        
    }
}


- (void)setVideoData:(FilterVideo *) video
{
    self.ytVideo = video;
    // Init the webview with the video...
    FilterYoutubeView *iwebView = [[FilterYoutubeView alloc] initWithStringAsURL:self.ytVideo.id frame:CGRectMake(0, 50, 320, 420)];
    iwebView.mediaPlaybackRequiresUserAction = NO;
    iwebView.opaque = NO;
    iwebView.backgroundColor = [UIColor blackColor];
    
    [self addSubview:iwebView];
}


@end
