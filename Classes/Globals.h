 //
//  Globals.h
//  BeatPort
//
//  Created by Ben Hine on 1/27/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kMultimediaPlayerStateStopped = 0,
	kMultimediaPlayerStatePlaying = 1,
	kMultimediaPlayerStatePaused = 2,
	kMultimediaPlayerStateBuffering = 3,
} MultimediaPlayerState;

typedef struct {
	AudioFileID audioFile;
	int32_t     currentPacket;
	ExtAudioFileRef fileRef;
} AudioFilePlayerInfo;

static const BOOL kUseSongFade = YES;

// Define debug NSLog
#ifdef _DEBUG_BPMULTIMEDIA_
#define NSDebug(...) NSLog(@“[%s:%d]: %@”, FILE, LINE, [NSString stringWithFormat:VA_ARGS])
#else
#define NSDebug(...) do { } while(0)
#endif

// Buffering time before the streaming audio driver will
// being playing.
#define mBuffferingTimeInS 1


//Shortcut for font
#define FILTERFONT(size_) [UIFont fontWithName:@"Futura-Medium" size:(CGFloat)size_]

// Keychain defines
#define KEYCHAIN_SERVICENAME @"FilteredSpace"
#define USERNAME_KEY @"FSusername"

// NOTE: enum values and strings from kFilterAPIURLS must be in identical order
typedef enum {
	
	kFilterAPITypeCreateCheckin = 0,
	kFilterAPITypeGeoGetEvents,
	kFilterAPITypeGeoGetBands,
	kFilterAPITypeGeoGetFeaturedBands,
	kFilterAPITypeGetGenres,
	kFilterAPITypeBandDetails,
    kFilterAPITypeBandVideos,
	kFilterAPITypeBandShows,
	kFilterAPITypeBandTracks,
	kFilterAPITypeBandSearch,
    kFilterAPITypeBandFollow,
    kFilterAPITypeBandUnfollow,
	kFilterAPITypeShowDetails,
	kFilterAPITypeSearchShows,
	kFilterAPITypeVenueSearch,
    kFilterAPITypeVenueDetails,
    kFilterAPITypeVenueShows,
	kFilterAPITypeAccountDetails,
    kFilterAPITypeGetAccount,
	kFilterAPITypeAccountCreate,
    kFilterAPITypeAccountModify,
    kFilterAPITypeAccountChangePassword,
	kFilterAPITypeAccountBands,
	kFilterAPITypeAccountCheckins,
	kFilterAPITypeAccountShows,
    kFilterAPITypeAccountGetGenres,
	kFilterAPITypeAccountAddGenres,
    kFilterAPITypeAccountNews,
	kFilterAPITypeAccountProfilePicture,
	kFilterAPITypeAccountDeleteProfilePicture,
	kFilterAPITypeShowBookmark,
	kFilterAPITypeShowUnbookmark,
	kFilterAPITypeDownloadTrack,
    kFilterAPITypeLogin,
    kFilterAPITypeGeoGetVenues,
	
} FilterAPIType;

typedef enum {
	
	kToolbarButtonTypeNone,
	kToolbarButtonTypePlaylistList,
	kToolbarButtonTypeBackButton,
	kToolbarButtonTypeDone,
	kToolbarButtonTypeCancel,
	kToolbarButtonTypeNext,
	kToolbarButtonTypeCreateAccount,
	kToolbarButtonTypeLogin,
	
	kToolbarButtonTypeUpcomingShowsMapButton,
	kToolbarButtonTypeUpcomingShowsPosterButton,
	kToolbarButtonTypeUpcomingShowsLeftSegmentButton,
	kToolbarButtonTypeUpcomingShowsRightSegmentButton,
	kToolbarButtonTypeUpcomingShowsAllShowsButton,
	
	kToolbarButtonTypeSearchShowsFilterButton,
	
	//TODO: etc
	
} ToolbarButtonType;

typedef enum {
	
    kSecondaryToolbar_None = 0,
    kSecondaryToolbar_SearchShows,
    kSecondaryToolbar_UpcomingShows,
	kSecondaryToolbar_NewsFeed,
	
} SecondaryToolbarType;