//
//  TheFilterMultimediaManager.h
//  InternetTest
//
//  Created by Eric Chapman on 12/13/09.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "FileCacheManager.h"
#import "FileDownloadManager.h"
#import "StreamingAudioDriver.h"

@interface BPTrackStatus : NSObject {
	NSString *_URL;
	float _fileSize;
	float _downloadProgress;
	float _trackLength;
	float _playProgress;
}

@property (nonatomic, retain) NSString *URL;
@property (assign) float fileSize;
@property (assign) float downloadProgress;
@property (assign) float trackLength;
@property (assign) float playProgress;
@property (readonly) BOOL fullyLoaded;

- (id)initWithUrl:(NSString *)url;
+ (id)objectWithUrl:(NSString *)url;

@end

@interface TheFilterMultimediaManager : NSObject <StreamMediaManager,
StreamingAudioPlayerDelegate,FileManagerDelegate> {
	
	// GUI Delegate
	id<StreamMediaUI> _delegateUI;
	
	// Audio Driver Delegate
	id _delegateAudioDriver;

	// Current playing song information
	BPTrackStatus *_currentTrack;
	
	// File manager instance
	FileDownloadManager * _fileManager;
	
	// Current state of the ,ultimedia player
	MultimediaPlayerState multimediaPlayerState_;
	MultimediaPlayerState multimediaPlayerPrevState_;
	
	// Flags
	BOOL operationError_;				// There was an error during the operation
	BOOL operationInProgress_;			// Is a operation (play,stop,etc.) in progress
	BOOL _isPlaying;					// Is the system playing currently
	BOOL _wasPaused;					// Was the system paused before
	BOOL _configuredStreamFileSize;		// Has the size been set in the audio driver
	BOOL _isSongFullyLoaded;			// Has the audio driver received all of hte data
	
}
@property (assign) id<StreamMediaUI> delegateUI;
@property (assign) id delegateAudioDriver;

@property (readonly) BPTrackStatus *currentTrack;
@property (readonly) BOOL wasPaused;
@property (readonly) BOOL isPlaying;

@end
