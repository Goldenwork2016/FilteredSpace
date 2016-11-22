//
//  TheFilterMultimediaManager.m
//  InternetTest
//
//  Created by Eric Chapman on 12/13/09.
//

#import "TheFilterMultimediaManager.h"
#import "Common.h"
#import "Reachability.h"

#define ERROR_HANDLER \
	if(__error != nil) { \
		[self errorHandler:__error]; \
		return; \
	}

#pragma mark -
#pragma mark BPTrackStatus Definition

@implementation BPTrackStatus
@synthesize URL = _URL, fileSize = _fileSize, downloadProgress = _downloadProgress,
trackLength = _trackLength, playProgress = _playProgress, fullyLoaded = _fullyLoaded;

+ (id)objectWithUrl:(NSString *)url {
	return [[[BPTrackStatus alloc] initWithUrl:url] autorelease];
}
- (id)initWithUrl:(NSString *)url {
	if ((self = [super init])) {
		self.URL = url;
	}
	return self;
}
- (id)init {
	if ((self = [super init])) {
		_fileSize = -1;
	}
	return self;
}
- (void)dealloc {
	[_URL release], _URL = nil;
	[super dealloc];
}

@end



#pragma mark -
#pragma mark MediaOperation Definition

typedef enum {
	kBPMediaOperationTypePlay,
	kBPMediaOperationTypePrePlay,
	kBPMediaOperationTypeStop,
	kBPMediaOperationTypePause,
	kBPMediaOperationTypeScrub,
} BPMediaOperationType;

@interface BPMediaOperation : NSObject {
	NSString *url_;
	BPMediaOperationType type_;
	float parameter_;
}
@property (nonatomic, retain) NSString *url;
@property (assign) float parameter;
@property (assign) BPMediaOperationType type;

+ (BPMediaOperation *)operationWithType:(BPMediaOperationType)type
									url:(NSString *)url
							  parameter:(float)parameter;
@end

@implementation BPMediaOperation
@synthesize url = url_, type = type_, parameter = parameter_;

- (void)dealloc {
	[url_ release], url_ = nil;
	[super dealloc];
}

+ (BPMediaOperation *)operationWithType:(BPMediaOperationType)type
									url:(NSString *)url
							  parameter:(float)parameter {
	
	BPMediaOperation *newOperation = [[BPMediaOperation alloc] init];
	newOperation.type = type;
	newOperation.url = url;
	newOperation.parameter = parameter;
	return [newOperation autorelease];

}

@end


// Creating a "hidden" category allows methods to be defined in the object
// but externally they can not be seen by other objects, creating "hidden" methods.
// This is used to define methods that should not be called by external objects

@interface TheFilterMultimediaManager(hidden)

- (void)downloadProgressMain:(NSNumber *)progress;
- (void)playProgressMain:(NSNumber *)progress;
- (void)mediaStartedMain;
- (void)mediaEndedUserInvokedMain;
- (void)mediaEndedSongOverMain;
- (void)mediaErrorMain:(NSError *)error;
- (void)errorHandler:(NSError *)error;

// Methods to perform operations on main thread with blocking
- (void)performMediaOperation:(BPMediaOperation *)operation;
- (void)performOperationOnMainThreadWithBlocking:(BPMediaOperation *)operation;
- (void)internalPlay:(NSString *)url;
- (void)internalPrePlay:(NSString *)url;
- (void)internalPause;
- (void)internalStop;
- (void)internalScrub:(float)progress;

@end

@implementation TheFilterMultimediaManager(hidden)


//-------------------------------------------------------------------------
// This uses the main thread to create a queue.  The method will block until
// the audio player has been fully updated and is running smoothly
//-------------------------------------------------------------------------
- (void)performMediaOperation:(BPMediaOperation *)operation {
	
	assert([NSThread mainThread] == [NSThread currentThread]);
	
	[self performSelectorOnMainThread:@selector(performOperationOnMainThreadWithBlocking:) 
						   withObject:[operation retain] 
						waitUntilDone:NO];

}

- (void)performOperationOnMainThreadWithBlocking:(BPMediaOperation *)operation {
	
	assert([NSThread mainThread] == [NSThread currentThread]);
	
	operationInProgress_ = YES;
	
	switch (operation.type) {
		case kBPMediaOperationTypePrePlay:
			[self internalPrePlay:operation.url];
			break;
		case kBPMediaOperationTypePlay:
			[self internalPlay:operation.url];
			break;
		case kBPMediaOperationTypeStop:
			[self internalStop];
			break;
		case kBPMediaOperationTypePause:
			[self internalPause];
			break;
		case kBPMediaOperationTypeScrub:
			[self internalScrub:operation.parameter];
			break;
		default:
			break;
	}
	
	operationInProgress_ = NO;
	
	[operation release];
}

- (void)internalPlay:(NSString *)url {
	
	operationError_ = NO;
	
	//assert(multimediaPlayerState_ == kMultimediaPlayerStatePaused ||
	//	   multimediaPlayerState_ == kMultimediaPlayerStateStopped);
	
	// Start the audio driver
	NSError *__error = nil;
	[_delegateAudioDriver startStreamWithFade:YES buffering:mBuffferingTimeInS error:&__error];
	ERROR_HANDLER
	
	//-------------------------------------------------------------------------
	// Only run the following if it is a new song and not a paused song
	//-------------------------------------------------------------------------
	if(_wasPaused == NO){
		
		// Check for preloading
		if ([_currentTrack.URL isEqualToString:url] == NO) {
			[_currentTrack release];
			_currentTrack = [[BPTrackStatus alloc] initWithUrl:url];
		}
		
		_isPlaying = YES;
		_configuredStreamFileSize = NO;
		
		//-------------------------------------------------------------------------
		// Start the streaming of the song
		//-------------------------------------------------------------------------
		[_fileManager retrieveFileFromURL:_currentTrack.URL canStream:YES error:&__error];
		ERROR_HANDLER
		
	}

	//-------------------------------------------------------------------------
	// Clear the "wasPaused" flag
	//-------------------------------------------------------------------------
	_wasPaused = NO;
	
	// Wait for the audio driver to get going
	int timeout = 0;
	while ((multimediaPlayerState_ != kMultimediaPlayerStatePlaying &&
		    multimediaPlayerState_ != kMultimediaPlayerStateBuffering) &&
		   operationError_ == NO && timeout<10) {
		
		// Sleep the thread fo a short time to let the handler catch up
		[NSThread sleepForTimeInterval:0.020];
		
		timeout++;
		
	}
	
}
- (void)internalPrePlay:(NSString *)url {
	
	// Ensure we are stopped
	[self internalStop];
	
	[_currentTrack release];
	_currentTrack = [[BPTrackStatus alloc] initWithUrl:url];
	
	//-------------------------------------------------------------------------
	// Set the flags
	//-------------------------------------------------------------------------
	_isSongFullyLoaded = NO;
	_isPlaying = NO;
	_wasPaused = NO;
	
	//-------------------------------------------------------------------------
	// Start the download with streaming off (removed per customer request)
	//-------------------------------------------------------------------------
	//[_fileManager retrieveFileFromURL:url canStream:NO error:&__error];
	//ERROR_HANDLER
	
}
- (void)internalPause {
	
	//assert(multimediaPlayerState_ == kMultimediaPlayerStatePlaying ||
	//	   multimediaPlayerState_ == kMultimediaPlayerStateBuffering);
	
	NSError * __error = nil;
	
	operationError_ = NO;
	
	//-------------------------------------------------------------------------
	// Tell the audio manager to pause
	//-------------------------------------------------------------------------
	[_delegateAudioDriver pauseStream:&__error];
	ERROR_HANDLER
	
	//-------------------------------------------------------------------------
	// Set the flag
	//-------------------------------------------------------------------------
	_wasPaused = YES;
	
	// Wait for the audio driver to pause
	int timeout = 0;
	while (multimediaPlayerState_ != kMultimediaPlayerStatePaused &&
		   operationError_ == NO && timeout<10) {
		
		// Sleep the thread fo a short time to let the handler catch up
		[NSThread sleepForTimeInterval:0.020];
		
		timeout++;
	}
	
}
- (void)internalStop {
	
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// Update the flags
	//-------------------------------------------------------------------------
	_isSongFullyLoaded = NO;
	_isPlaying = NO;
	_wasPaused = NO;
	operationError_ = NO;
	
	//-------------------------------------------------------------------------
	// Let the download manager know we dont need the file anymore
	//-------------------------------------------------------------------------
	[_fileManager removeFileFromURL:_currentTrack.URL error:&__error];
	ERROR_HANDLER
	
	//-------------------------------------------------------------------------
	// Stop the audio driver
	//-------------------------------------------------------------------------
	[_delegateAudioDriver stopStreamWithFade:kUseSongFade error:&__error];
	ERROR_HANDLER
	
	// Wait for the audio driver to pause
	int timeout = 0;
	while (multimediaPlayerState_ != kMultimediaPlayerStateStopped &&
		   operationError_ == NO && timeout < 10) {
		
		// Sleep the thread fo a short time to let the handler catch up
		[NSThread sleepForTimeInterval:0.020];
		timeout++;
		
	}
	
	if (operationError_ == YES) {
		// An error was alerted, exit
		return;
	}
	
	//-------------------------------------------------------------------------
	// Clear the current song variables
	//-------------------------------------------------------------------------
	[_currentTrack release];
	_currentTrack = nil;	
	
	//-------------------------------------------------------------------------
	// Send the end event to the UI
	//-------------------------------------------------------------------------
	[self performSelectorOnMainThread:@selector(mediaEndedUserInvokedMain)
						   withObject:nil waitUntilDone:NO];
	
	
}
- (void)internalScrub:(float)progress {
	
	NSError * __error = nil;
	
	operationError_ = NO;
	
	//-------------------------------------------------------------------------
	// If we are not currently playing, we need to make the song play so that
	// we can scrub it.  Wait for the song to actually start playing before
	// we scrub
	//-------------------------------------------------------------------------
	if((!_isPlaying) && YES /*[[Reachability sharedReachability] internetConnectionStatus] != NotReachable*/) {
		
		[self internalPlay:_currentTrack.URL];
		
	} 
	/*else if ([[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
	
		__error = [NSError errorWithDomain:FileDownloadManagerErrorDomain code:DLMError1 userInfo:nil];
		ERROR_HANDLER
		
	}*/ //TODO: use the new reachability code
	
	//-------------------------------------------------------------------------
	// Ensure we have the track length and file size before we continue
	//-------------------------------------------------------------------------
	int timeout = 0;
	while (_currentTrack.trackLength <= 0 || _currentTrack.fileSize <= 0 ||
		   multimediaPlayerState_ != kMultimediaPlayerStatePlaying &&
		   multimediaPlayerState_ != kMultimediaPlayerStatePaused
		   && operationError_ == NO && timeout<10) {
		[NSThread sleepForTimeInterval:0.020];
		timeout++;
	}
	if (operationError_ == YES) {
		return;
	}
	
	// I dont like this but the audio driver switches states to buffering but is
	// not immediately ready.  I really really really do not like this.  This is
	// a hack but it will at least force synchrocity above this
	[NSThread sleepForTimeInterval:0.100];
	
	//-------------------------------------------------------------------------
	// Stop the streaming
	//-------------------------------------------------------------------------
	[_fileManager stopStreamingFileFromURL:_currentTrack.URL error:&__error];
	ERROR_HANDLER
	
	//-------------------------------------------------------------------------
	// Convert the ratio to actual song time
	//-------------------------------------------------------------------------
	float time = progress*_currentTrack.trackLength;

	//-------------------------------------------------------------------------
	// Ask the audio streamer for the byte offset
	//-------------------------------------------------------------------------
	SInt64 offset;
	[_delegateAudioDriver seek:time byteOffset:&offset error:&__error];
	ERROR_HANDLER
	
	// Wait for the audio driver to buffer
	timeout = 0;
	while (multimediaPlayerState_ != kMultimediaPlayerStateBuffering &&
		   operationError_ == NO && timeout<10) {
		// Sleep the thread fo a short time to let the handler catch up
		[NSThread sleepForTimeInterval:0.020];
		timeout++;
	}
	if (operationError_ == YES) {
		return;
	}
	
	//-------------------------------------------------------------------------
	// Set the flags
	//-------------------------------------------------------------------------
	_isSongFullyLoaded = NO;
	_isPlaying = YES;
	
	//-------------------------------------------------------------------------
	// Have the file manager start getting that portion of the file.  We get a 
	// scenario where the _currentSongLength is somehow -1.  Don't scrub in this
	// case
	//-------------------------------------------------------------------------
	[_fileManager retrieveFileOffsetFromURL:_currentTrack.URL offset:offset error:&__error];
	ERROR_HANDLER

}

- (void)errorHandler:(NSError *)error{
	if(error != nil) { 
		[self performSelectorOnMainThread:@selector(mediaErrorMain:) withObject:[error retain] waitUntilDone:NO];
	}
}

//-------------------------------------------------------------------------
// Sends the download progress to the UI
//-------------------------------------------------------------------------
- (void)downloadProgressMain:(NSNumber *)progress{
	
	assert(_delegateUI != nil);
	assert(progress != nil);
	assert([NSThread isMainThread]);
	
	if([_delegateUI respondsToSelector:@selector(downloadProgress:)])
		[_delegateUI downloadProgress:[progress floatValue]];
	
	[progress release];
}
//-------------------------------------------------------------------------
// Send the play progress to the UI
//-------------------------------------------------------------------------
- (void)playProgressMain:(NSNumber *)progress{

	assert(_delegateUI != nil);
	assert(progress != nil);
	assert([NSThread isMainThread]);
	
	[_delegateUI mediaProgress:[progress floatValue]];
	
	[progress release];
}
//-------------------------------------------------------------------------
// Send the media ended event to the UI
//-------------------------------------------------------------------------
- (void)mediaEndedSongOverMain{

	assert(_delegateUI != nil);
	assert([NSThread isMainThread]);
	
	[_delegateUI mediaEnded:YES];
}
//-------------------------------------------------------------------------
// Send the media ended event to the UI
//-------------------------------------------------------------------------
- (void)mediaEndedUserInvokedMain{
	
	assert(_delegateUI != nil);
	assert([NSThread isMainThread]);
	
	[_delegateUI mediaEnded:NO];
}
//-------------------------------------------------------------------------
// Send the media ended event to the UI
//-------------------------------------------------------------------------
- (void)mediaPausedMain{
    
	assert(_delegateUI != nil);
	assert([NSThread isMainThread]);
	
	[_delegateUI mediaPaused];
}
//-------------------------------------------------------------------------
// Send the media started event to the UI
//-------------------------------------------------------------------------
- (void)mediaStartedMain{

	assert(_delegateUI != nil);
	assert([NSThread isMainThread]);
	
	[_delegateUI mediaStarted];
}
//-------------------------------------------------------------------------
// Send the media error event to the UI
//-------------------------------------------------------------------------
- (void)mediaErrorMain:(NSError *)error{

	assert(_delegateUI != nil);
	assert([NSThread isMainThread]);
	
	[_delegateUI mediaError:error];
	
	[error release];
}
@end

@implementation TheFilterMultimediaManager
@synthesize delegateUI = _delegateUI;
@synthesize delegateAudioDriver = _delegateAudioDriver;
@synthesize currentTrack = _currentTrack;
@synthesize wasPaused = _wasPaused;
@synthesize isPlaying = _isPlaying;


/////////////////////////////////////////////////////////////////
// Constructor/Destructor methods
/////////////////////////////////////////////////////////////////

- (id)init{
	if(!(self = [super init])){return nil;}
	
	// Set Flags
	_isSongFullyLoaded = NO;
	_wasPaused = NO;
	_isPlaying = NO;
	
	// Init file manager
	_fileManager = [[FileDownloadManager alloc] init];
	_fileManager.delegate = self;
	
	// Init current track
	_currentTrack = nil;
	
	return self;
}

- (void)dealloc{
	[_currentTrack release];
	[_fileManager release];
	[super dealloc];
}

/////////////////////////////////////////////////////////////////
// These methods are all intended to be called by the UI
/////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------
// Causes a pause event
//-------------------------------------------------------------------------
- (void)pause {
	
	assert(_delegateAudioDriver != nil);
	assert(_fileManager != nil);
	
	[self performMediaOperation:[BPMediaOperation operationWithType:kBPMediaOperationTypePause
																url:nil
														  parameter:-1]];

}

//-------------------------------------------------------------------------
// Causes a stop event
//-------------------------------------------------------------------------
- (void)stop { 
	
	assert(_delegateAudioDriver != nil);
	assert(_fileManager != nil);
	
	[self performMediaOperation:[BPMediaOperation operationWithType:kBPMediaOperationTypeStop
																url:nil
														  parameter:-1]];
}

//-------------------------------------------------------------------------
// This method will start downloading the song
//-------------------------------------------------------------------------
- (void)prePlayURL:(NSString *)url {
	
	assert(_delegateAudioDriver != nil);
	assert(_fileManager != nil);
	
	[self performMediaOperation:[BPMediaOperation operationWithType:kBPMediaOperationTypePrePlay
																url:url
														  parameter:-1]];
	 
}

- (void)playURL:(NSString *)url {
	
	assert(_delegateAudioDriver != nil);
	assert(_fileManager != nil);
	
	[self performMediaOperation:[BPMediaOperation operationWithType:kBPMediaOperationTypePlay
																url:url
														  parameter:-1]];
	 
}

//-------------------------------------------------------------------------
// This method handles the scrubbing of the song
//-------------------------------------------------------------------------
- (void)scrubbingProgress:(float)progress {
	
	assert(_delegateAudioDriver != nil);
	assert(_fileManager != nil);
	
	[self performMediaOperation:[BPMediaOperation operationWithType:kBPMediaOperationTypeScrub
																url:nil
														  parameter:progress]];

}
//////////////////////////////////////////////////////////
// FileCacheManagerDelegate
// These events are from the file manager.
//////////////////////////////////////////////////////////

- (void) FileCacheManagerFile:(NSString *)url data:(NSData *)data{
	
	assert(_delegateAudioDriver != nil);
	assert(_delegateUI != nil);
	
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// This makes sure that this data is a part of the currently playing song.
	// pass the information to main
	//-------------------------------------------------------------------------
	if(_currentTrack.URL && [_currentTrack.URL isEqualToString:url]){
		
		//-------------------------------------------------------------------------
		// If the song is not fully loaded and is playing, pass it to the audio manager
		//-------------------------------------------------------------------------
		if(!_isSongFullyLoaded && _isPlaying) {
			
			//-------------------------------------------------------------------------
			//  We need to let give the audio driver the total size of the file.
			//  We only want ot do this when we start downloading the entire song
			//  and not a scrubbed portion.
			//-------------------------------------------------------------------------
			if (_configuredStreamFileSize == NO) {
				_configuredStreamFileSize = YES;
				[_delegateAudioDriver setStreamAudioDataSizeInBytes:[data length]];
			}
			
			//-------------------------------------------------------------------------
			// Pass the song
			//-------------------------------------------------------------------------
			[_delegateAudioDriver streamData:data byteOffset:0 error:&__error];
			ERROR_HANDLER
			
			//-------------------------------------------------------------------------
			// Set the song to stop playing when it is done since we have given
			// the audio manager all of the data
			//-------------------------------------------------------------------------
			[_delegateAudioDriver stopStreamOnIdle:YES error:&__error];
			ERROR_HANDLER
		}
		
	}
	
	_isSongFullyLoaded = YES;
	
}

- (void)FileCacheManagerStreamStart:(NSString *)url data:(NSData *)data size:(float)size offset:(SInt64)offset{
	
	assert(_delegateAudioDriver != nil);
	assert(_delegateUI != nil);
	assert(offset>=0);
	
	//NSLog(@"FCM : Streaming Started URL: %@",url);
	
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// This makes sure that this data is a part of the currently playing song.
	// pass the information to main
	//-------------------------------------------------------------------------
	if(_currentTrack.URL && [_currentTrack.URL isEqualToString:url]){
		
		//-------------------------------------------------------------------------
		//  We need to let give the audio driver the total size of the file.
		//  We only want ot do this when we start downloading the entire song
		//  and not a scrubbed portion.
		//-------------------------------------------------------------------------
		if (_configuredStreamFileSize == NO) {
			_configuredStreamFileSize = YES;
			[_delegateAudioDriver setStreamAudioDataSizeInBytes:size];
		}
		//-------------------------------------------------------------------------
		// Send the data to the audio driver if the song is playing
		//-------------------------------------------------------------------------
		if(!_isSongFullyLoaded && _isPlaying) {
			float pOffset = offset;
		//	NSLog(@"Gave Data To Audio Player offset : %f",pOffset);
			[_delegateAudioDriver streamData:data byteOffset:offset error:&__error];
			ERROR_HANDLER
		}
		
	}
	
}


- (void)FileCacheManagerStreamUpdate:(NSString *)url data:(NSData *)data size:(float)size offset:(SInt64)offset{
	
	assert(_delegateAudioDriver != nil);
	assert(_delegateUI != nil);
	assert(offset>=0);
	
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// This makes sure that this data is a part of the currently playing song.
	// pass the information to main
	//-------------------------------------------------------------------------
	if(_currentTrack.URL && [_currentTrack.URL isEqualToString:url]){
		
		//-------------------------------------------------------------------------
		// Send the data to the audio driver
		//-------------------------------------------------------------------------
		if(!_isSongFullyLoaded && _isPlaying){
			[_delegateAudioDriver streamData:data byteOffset:offset error:&__error];
			ERROR_HANDLER
		}
		
	}

}


- (void) FileCacheManagerStreamEnd:(NSString *)url{
	
	assert(_delegateUI != nil);
	
	NSDebug(@"FCM : %d Streaming Ended URL: %@",self, url);
	
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// This makes sure that this data is a part of the currently playing song.
	// pass the information to main
	//-------------------------------------------------------------------------
	if(_currentTrack.URL &&[_currentTrack.URL isEqualToString:url]){
		
		//-------------------------------------------------------------------------
		// We got the end of the stream, tell the audio driver to stop when it is
		// done playing this chunk
		//-------------------------------------------------------------------------
		[_delegateAudioDriver stopStreamOnIdle:YES error:&__error];
		ERROR_HANDLER
		
	}
	
	//-------------------------------------------------------------------------
	// Set the fully loaded flag
	//-------------------------------------------------------------------------
	_isSongFullyLoaded = YES;
	
}
- (void) FileCacheManagerError:(NSString *)url error:(NSError *)error {
	
	//-------------------------------------------------------------------------
	// Something bad happened, get to a known state
	//-------------------------------------------------------------------------
	//[_currentSongURL release];
	//_currentSongURL = nil;
	
	//-------------------------------------------------------------------------
	// Send the error to the UI
	//-------------------------------------------------------------------------
	[self performSelectorOnMainThread:@selector(mediaErrorMain:) withObject:[error retain] waitUntilDone:NO];
	
}

- (void) FileCacheManagerProgress:(NSString *)url byteCount:(float)byteCount 
					   totalBytes:(float)totalBytes {
	
	//-------------------------------------------------------------------------
	// This makes sure that this data is a part of the currently playing song.
	// pass the information to main
	//-------------------------------------------------------------------------
	if(_currentTrack.URL &&[_currentTrack.URL isEqualToString:url]){
		
		//-------------------------------------------------------------------------
		// Set the song size
		//-------------------------------------------------------------------------
		if(_currentTrack.fileSize <= 0) {
			_currentTrack.fileSize = totalBytes;
		}
		
		//-------------------------------------------------------------------------
		// Update the download progress on the UI
		//-------------------------------------------------------------------------
		if(_currentTrack.fileSize == totalBytes)
			_currentTrack.downloadProgress = byteCount/totalBytes;
			[self performSelectorOnMainThread:@selector(downloadProgressMain:)
								   withObject:[[NSNumber numberWithFloat:_currentTrack.downloadProgress] retain] waitUntilDone:NO];
		
	}
	
}

//////////////////////////////////////////////////////////
// StreamingAudioPlayerDelegate
//////////////////////////////////////////////////////////
- (void) stateChangedFrom:(MultimediaPlayerState)oldState 
				  toState:(MultimediaPlayerState)newState 
					error:(NSError **)error {
	
	//NSLog(@"Changed State from %d to %d",oldState,newState);
	
	
	//-------------------------------------------------------------------------
	// If we went from playing or buffering to stopped
	//-------------------------------------------------------------------------
	if(newState == kMultimediaPlayerStateStopped && 
	   (oldState == kMultimediaPlayerStatePlaying || 
		oldState == kMultimediaPlayerStateBuffering)) {
		   
		   //-------------------------------------------------------------------------
		   // Set the flags
		   //-------------------------------------------------------------------------
		   _isPlaying = NO;
		   _wasPaused = NO;
		   _isSongFullyLoaded = NO;
		   
		   //-------------------------------------------------------------------------
		   // Stop the streaming of the file
		   //-------------------------------------------------------------------------
		   [_fileManager stopStreamingFileFromURL:_currentTrack.URL error:error];
		   
		   //-------------------------------------------------------------------------
		   // Send the event to the delegate
		   //-------------------------------------------------------------------------
		   if (operationInProgress_ == NO) {
			   [self performSelectorOnMainThread:@selector(mediaEndedSongOverMain)
									  withObject:nil waitUntilDone:NO];
			   
		   }
		   
	   }
	//-------------------------------------------------------------------------
	// If the state went from buffering or stopped to playing
	//-------------------------------------------------------------------------
	else if(newState == kMultimediaPlayerStatePlaying && 
			(oldState == kMultimediaPlayerStateStopped || 
			 oldState == kMultimediaPlayerStateBuffering)){
				
				//-------------------------------------------------------------------------
				// Send the song start event
				//-------------------------------------------------------------------------
				[self performSelectorOnMainThread:@selector(mediaStartedMain) 
									   withObject:nil waitUntilDone:NO];
				
			}
	
    else if(newState == kMultimediaPlayerStatePaused && 
            (oldState == kMultimediaPlayerStatePlaying|| 
             oldState == kMultimediaPlayerStateBuffering)) {
				//-------------------------------------------------------------------------
				// Send the song pause event
				//-------------------------------------------------------------------------
				[self performSelectorOnMainThread:@selector(mediaPausedMain) 
									   withObject:nil waitUntilDone:NO];
                
				_wasPaused = YES;
			}
	
	multimediaPlayerPrevState_ = multimediaPlayerState_;
	multimediaPlayerState_ = newState;
	
}

static int updateTime = 0;

- (void) updatePlaybackTime:(float)time totalTime:(float)totalTime{
	
    //-------------------------------------------------------------------------
	// Sometimes the manager will stop before the player moves to the stop
    // state. (since we support fade out). During this fade out, we should
    // ignore any updates to the playback time since we have already reset these
    // flags during the stop.
    //
    // Specifically we we do not want to update _currentSongLength after we had
    // already set it to -1 during the stop call
	//-------------------------------------------------------------------------
    if (!_isPlaying) {
        return;
    }
    
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// Set the song length
	//-------------------------------------------------------------------------
	_currentTrack.trackLength = totalTime;
	_currentTrack.playProgress = time/totalTime;
	if (_currentTrack.playProgress > 1.0) {
		_currentTrack.playProgress = 1.0;
	}
	
	if (multimediaPlayerPrevState_ == kMultimediaPlayerStatePaused &&
		(multimediaPlayerState_ == kMultimediaPlayerStatePlaying ||
		 multimediaPlayerState_ == kMultimediaPlayerStateBuffering)) {
			[self performSelectorOnMainThread:@selector(playProgressMain:)
								   withObject:[[NSNumber numberWithFloat:_currentTrack.playProgress] retain] waitUntilDone:NO];
	}
	
	//-------------------------------------------------------------------------
	// If the progress is 0 and the song is playing, send a tiny progress that
	// is not 0.  This will enable the slider for scrubbing
	//-------------------------------------------------------------------------
	else if(abs(time) == 0 && [_delegateAudioDriver getState:&__error] == kMultimediaPlayerStatePlaying ) {
		[self performSelectorOnMainThread:@selector(playProgressMain:)
							   withObject:[[NSNumber numberWithFloat:.001] retain] waitUntilDone:NO];
				
	}
	
	//-------------------------------------------------------------------------
	// Only send the update every 250 ms
	//-------------------------------------------------------------------------
	else if(abs(updateTime - time) > .25 ) {
		[self performSelectorOnMainThread:@selector(playProgressMain:)
							   withObject:[[NSNumber numberWithFloat:_currentTrack.playProgress] retain] waitUntilDone:NO];
		updateTime = time;
	}
}

- (void) audioStreamEncounteredError:(NSError *)error {
	
	operationError_ = YES;
	
	///-------------------------------------------------------------------------
	// Send the error to the UI
	//-------------------------------------------------------------------------
	[self performSelectorOnMainThread:@selector(mediaErrorMain:) withObject:[error retain] waitUntilDone:NO];
}

@end
