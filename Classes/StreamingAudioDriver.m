//
//  StreamingAudioDriver.m
//  TheFilter
//
//  Created by Chris Green on 12/13/09.
//

#import "StreamingAudioDriver.h"
#define _DEBUG_STREAMINGAUDIO_ 0

static NSString *BPPlayerRunLoopMode = @"BPDontHateThePlayerHateTheGame";
//-----------------------------------------------
// Private Methods 
//-----------------------------------------------
@interface StreamingAudioDriver (hidden)

/**
 * @function startStreamInternal
 * @description Method that setups and starts an audio stream. This method run in a separate loop
 * @description which monitors and controls the stream. 
 */
- (void) startStreamInternal;

/**
 * @function processStreamTimeoutInternal
 * @description Handles the streams internal monitoring timeout 
 */
- (void) processStreamTimerInternal;

/**
 * @function streamDataInternal
 * @description Method that monitors to see when data is available and sends it to the audio stream. 
 */
- (void) streamDataInternal;

/**
 * @function updateDelegateStateInternal
 * @description Method that updates the delegate of the state change 
 * @input (NSArray *)parameterArray - parameters that are parsed to send to the delegate.
 */
- (void) updateDelegateStateInternal:(NSArray *)parameterArray;

/**
 * @function updateStreamProgressInternal
 * @description Method that updates the delegate with the current progress 
 */
- (void) updateStreamProgressInternal;

/**
 * @function changeState
 * @description Method that updates the state of the audio stream and takes appropiate action.
 * @input (InternalStreamState)newState - new state to update the stream to.
 */
- (void) changeState:(InternalStreamState)newState;

/**
 * @function waitForFreeBuffer
 * @description Method that will wait for a audio buffer to become available
 */
- (void) waitForFreeBuffer;

/**
 * @function enqueueBuffer
 * @description Method that will enqueue a buffer in the audio queue
 */
- (void) enqueueBuffer;

- (BOOL) isStopped;
- (BOOL) isBuffering;
- (BOOL) isPlaying;
- (void) enqueueBuffer;
- (BOOL) isSeekingSupported;
- (MultimediaPlayerState) mapInternalStateToPublicState:(InternalStreamState)state;

//--------------------------------------------------------------------
// The following methods get wrapped by C style static methods that
// are needed to interface with the audio queue and audio file stream
// APIs. 
//--------------------------------------------------------------------
- (void) audioOutputCallbackInternal:(AudioQueueRef) outAQ
									:(AudioQueueBufferRef) outBuffer;

- (void) audioQueuePropertyListenerCallbackInternal:(AudioQueueRef)inAQ 
												   :(AudioQueuePropertyID)inID;

- (void) audioFileStream_ProperyListnerInternal:(AudioFileStreamID)inAudioFileStream
								               :(AudioFileStreamPropertyID)inPropertyID
									           :(UInt32 *)ioFlags;

- (void) audioFileStream_PacketsProcInternal:(UInt32)inNumberBytes
                                            :(UInt32)inNumberPackets
                                            :(const void *)inInputData
                                            :(AudioStreamPacketDescription *)inPacketDescriptions;

- (void) audioSessionInterruptListnerInternal:(UInt32)inInterruptionState;

@end

@implementation StreamingAudioDriver

//--------------------------------------------------------------------
//  Values used by apple's example, we can tweak this as needed for 
//  performance
//--------------------------------------------------------------------
const unsigned int kNumAQBufs = 4;           // number of audio queue buffers we allocate
const size_t kAQBufSize = 128 * 1024;        // number of bytes in each audio queue buffer
const size_t kAQMaxPacketDescs = 512;        // number of packet descriptions in our array

@synthesize delegate = _delegate;
@synthesize streamAudioDataSizeInBytes = _streamAudioDataSizeInBytes;

// Audio Queue Buffer Callback
void AudioOutputCallback(void* inUserData,
						 AudioQueueRef outAQ,
						 AudioQueueBufferRef outBuffer);

// Audio Queue Property Listener
void AudioQueuePropertyListenerCallback(void *inUserData, 
										AudioQueueRef inAQ, 
										AudioQueuePropertyID inID);

// Audio Stream Property Listner
void AudioFileStream_ProperyListner(void                        *inClientData,
									AudioFileStreamID           inAudioFileStream,
								    AudioFileStreamPropertyID   inPropertyID,
									UInt32                      *ioFlags);

// Audio Stream Data Callback
void audioFileStream_PacketsProc(void                          *inClientData,
                                 UInt32                        inNumberBytes,
                                 UInt32                        inNumberPackets,
                                 const void                    *inInputData,
                                 AudioStreamPacketDescription  *inPacketDescriptions);

// Audio Session Interrupt Listener
void audioSessionInterruptionListener(void     *inClientData,
								      UInt32   inInterruptionState);

- (id) init {
	if ((self = [super init])) {
		//-----------------------------------------------
		// Initialize our objects
		//-----------------------------------------------
		_state = kInternalStreamStateUninitialized;
		
		//----------------------------------------------------------------
		//  This persists between stops and starts of the audio driver, 
		//  so we need to initialize it here instead of the startStreamInternal
		//----------------------------------------------------------------
		_volume = 1.0; 
		
		
		pthread_mutex_init(&_streamStateLock, NULL);
		pthread_mutex_init(&_bufferLock, NULL);
		pthread_cond_init(&_bufferAvailable, NULL);
		pthread_cond_init(&_audioQueueStopped, NULL);
		pthread_cond_init(&_audioFileStreamStarted, NULL);
		pthread_cond_init(&_audioFileStreamFadeOutComplete, NULL);
		pthread_cond_init(&_dataStreamIdleSignal, NULL);
		
		//-----------------------------------------------
		//  We must initialize our audio session before 
		//  we can get/set any of the properties on the
		//  session.
		//
		//  For this app, we need to configure the session
		//  kAudioSessionCategory_MediaPlayback to give
		//  us the desired default behavior when streaming
		//  audio.
		//-----------------------------------------------
		AudioSessionInitialize (NULL, NULL,	audioSessionInterruptionListener, self);
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (sessionCategory),&sessionCategory);
		
		//-----------------------------------------------
		//  We need to activate our audio session here
		//  so we have it active throughout the lifetime 
		//  of our streaming driver. Mainly this is needed 
		//  to so we can control the device's volume instead
		//  of just the ringer volume.
		//  Also this will allow us to receive callbacks/notifications 
		//  and have the device use our audio session settings
		//-----------------------------------------------
		AudioSessionSetActive(true);
	}
	return self;
}	

- (void)dealloc{
	//-----------------------------------------------
	// Cleanup our objects
	//-----------------------------------------------
	pthread_mutex_destroy(&_streamStateLock);
	pthread_mutex_destroy(&_bufferLock);
	pthread_cond_destroy(&_bufferAvailable);
	pthread_cond_destroy(&_audioQueueStopped);
	pthread_cond_destroy(&_audioFileStreamStarted);
	pthread_cond_destroy(&_audioFileStreamFadeOutComplete);
	pthread_cond_destroy(&_dataStreamIdleSignal);
	
    [super dealloc];
}

- (void) startStreamWithFade:(BOOL)fadeIn buffering:(float)bufferingTimeInS error:(NSError **)error {	
	//--------------------------------------------------------
	// Anytime we are checking our streaming state, we need to
	// ensure we have the lock while we are taking an action
	// based of if that state
	//--------------------------------------------------------
	pthread_mutex_lock(&_streamStateLock);
	if (_state == kInternalStreamStatePaused) {
		[self changeState:kInternalStreamStateWaitingForData];
	}
	else {
		if (_fadeSongOut == YES || _state == kInternalStreamStateStopped) {
			//--------------------------------------------------------
			//  The previously playing song has been stopped with 
			//  a fade out. Lets wait for it to finsh.
			//--------------------------------------------------------
			while (_state != kInternalStreamStateUninitialized){
				pthread_cond_wait(&_audioFileStreamFadeOutComplete, &_streamStateLock);
			}
		}
		if (_state == kInternalStreamStateUninitialized) {
			_bufferingDelayInS = bufferingTimeInS;
			_fadeSongIn = fadeIn;
			
			[self changeState:kInternalStreamStateInitializing];
			[NSThread detachNewThreadSelector:@selector(startStreamInternal) toTarget:self withObject:nil];
			while (_state == kInternalStreamStateInitializing && !_errorOccurred)
				pthread_cond_wait(&_audioFileStreamStarted, &_streamStateLock);
			if (_errorOccurred) *error = _error;
            
		}
		else {
			*error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError1 userInfo:nil];
		}
	}
	pthread_mutex_unlock(&_streamStateLock); 
}

- (void) seek:(float)seekTime byteOffset:(SInt64 *)byteOffset error:(NSError **)error {
	pthread_mutex_lock(&_streamStateLock);
	if ([self isStopped]  || !_readyForAudioData || _fadeSongOut) {
		//-----------------------------------------------------
		//  Since fade song out can only be set with an option to the
		//  stop method, we do not allow seeking while fading out.
		//  In the future, it may be desirable to change this if,
		//  for example, we allow the fading to be set separately 
		//  from calling stop, in which case, scrubbing may be valid
		//  and we would want to "turn off" the fade and not error.
		//-----------------------------------------------------
		*error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError2 userInfo:nil];
		pthread_mutex_unlock(&_streamStateLock);
		return;
	}
	
	if (![self isSeekingSupported]) {
		*error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError6 userInfo:nil];
		pthread_mutex_unlock(&_streamStateLock);
		return;
	}
	
	//-----------------------------------------------------
	//  Update our internal flags to reflect seeking has begun.
	//  These must be set before we make the call to wait 
	//  on the _audioQueueStopped since that will release
	//  our state lock.
	//-----------------------------------------------------
	_discontinuous = YES;
	_seeking = YES;
	_disableOnIdle = NO;
	//-----------------------------------------------------
	//  Convert the seek time to a packet and get the byte
	//  offset of that packet.
	//-----------------------------------------------------
	_audioData.bytePacketTranslation.mPacket = seekTime / _secondsPerPacket;
	UInt32 ioFlags = 0;
	AudioFileStreamSeek(_audioData.audioFileStream, _audioData.bytePacketTranslation.mPacket, &_audioData.bytePacketTranslation.mByte, &ioFlags);
	*byteOffset = _audioData.bytePacketTranslation.mByte;
	
	if (_audioData.audioQueueRunning) {
		//-----------------------------------------------------
		//  Stop the stream which will reset and clear out the 
		//  audio queue buffers
		//-----------------------------------------------------
		AudioQueueStop(_audioData.queue, YES);
		pthread_cond_wait(&_audioQueueStopped, &_streamStateLock);
	}
	
	[self changeState:kInternalStreamStateWaitingForData];
	
	[self updateStreamProgressInternal];
	
	pthread_mutex_unlock(&_streamStateLock);
	
	
}

- (BOOL) isSeekingSupported {
	
	if (_audioData.description.mFormatID != kAudioFormatMPEGLayer3) {
		return NO;
	}
	
	return YES;
}

- (void) updateVolume:(float)volume error:(NSError **)error {
	
	//-----------------------------------------------------
	//  Volume must be <= 1 or >= 0
	//-----------------------------------------------------
	assert ((volume <= 1) && (volume >= 0));
	
	pthread_mutex_lock(&_streamStateLock);
	
	_volume = volume;
	if (![self isStopped] && _readyForAudioData ) {
		//-----------------------------------------------------
		//  Only update the Audio Queue when we know it is valid
		//  to do so, which is when we are not in the stopped 
		//  state and when we are _readyForAudioData. 
		//-----------------------------------------------------
		OSStatus err = AudioQueueSetParameter(_audioData.queue, kAudioQueueParam_Volume, _volume);
		assert(!err);
		if (err) {
			*error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError4 userInfo:nil];
		}
	}
	pthread_mutex_unlock(&_streamStateLock);
}


- (void) startStreamInternal {
    
	pthread_mutex_lock(&_streamStateLock);
	assert (_state == kInternalStreamStateInitializing);
	
	//-----------------------------------------------
	// We need to create our own autorelease pool since
	// the stream runs in it's own thread
	//-----------------------------------------------
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//-----------------------------------------------
	// Initialize all the stream flags/indicators that
	// are used while the stream is running
	//-----------------------------------------------
	_streamData = [[NSMutableData alloc] init];
	_readyForAudioData = NO;    // Will be set to true after we parse the header info and are ready for audio
	_processingAudioData = YES; // We need to default this to yes so we know that the streamingData thread is the one that set it to no
	_errorOccurred = NO;
	_error = nil;
	_disableOnIdle = NO; 
	_disableOnIdleAfterPlaying = NO;
	_duration = -1.0;
	_seeking = NO;
	_bufferedPackets = 0;
	_streamAudioDataSizeInBytes = 0;
	_fadeSongOut = NO;
	_audoResumeAfterInterruption = NO;
	
	_audioData.bytesFilled = 0;
	_audioData.fillBufferIndex = 0;
	_audioData.packetsFilled = 0;
	_audioData.bytePacketTranslation.mByte = 0;
	_audioData.bytePacketTranslation.mPacket = 0;
	_audioData.audioQueueRunning = 0;
	//-----------------------------------------------
	// Open and initialze the stream
	//-----------------------------------------------
	OSStatus err = AudioFileStreamOpen(self, AudioFileStream_ProperyListner, audioFileStream_PacketsProc, 
									   0 , &_audioData.audioFileStream);
	if (err) {
		_errorOccurred = YES;
		_error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError3 userInfo:nil];
		[self changeState:kInternalStreamStateUninitialized];
		pthread_cond_signal(&_audioFileStreamStarted);
		pthread_mutex_unlock(&_streamStateLock);
		return;
	}
    
	//-----------------------------------------------
	//  Create and run the internal streaming thread.
    //  This thread is responsible for monitoring 
	//  when data is available and then passing that
	//  data to the audio stream session. This is need
	//  so callers of streamData:: do not end up block
	//  while the audio data is parsed.
	//-----------------------------------------------
	_dataStreamThread = [[NSThread alloc] initWithTarget:self selector:@selector(streamDataInternal) object:nil];
	[_dataStreamThread start];
	
	//-----------------------------------------------
	//  The stream is configured and is ready to start 
	//  receiveing data
	//-----------------------------------------------
	[self changeState:kInternalStreamStateWaitingForData];
	pthread_cond_signal(&_audioFileStreamStarted);
	pthread_mutex_unlock(&_streamStateLock);
	
	//-----------------------------------------------
	//  Run the main monitoring loop for the stream
	//
	//  For this loop, we need to maintain a run loop
	//  so we get the proper callbacks from the audio
	//  file stream services. In addition, we need to
	//  have a monitoring timer fire every 250ms so we
	//  can check the state of the steam and update the
	//  playback time.
	//-----------------------------------------------
	NSTimer * internalTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(processStreamTimerInternal) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:internalTimer forMode:BPPlayerRunLoopMode];
	
	while (_state != kInternalStreamStateStopped) {
		NSDate * runDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0.5];
		[[NSRunLoop currentRunLoop] runMode:BPPlayerRunLoopMode beforeDate:runDate];
		[runDate release];
	}
	
    //----------------------------------------------------------------
	//  Cleanup
	//----------------------------------------------------------------
	
	//----------------------------------------------------------------
	//  Stop and remove the timer from this run loops
	//----------------------------------------------------------------
	[internalTimer invalidate];
	
	//----------------------------------------------------------------
	//  If we had an error, update the delegate with this error. Currently
	//  we need to do this before releasing our autio release pool AND
	//  before stopping the _dataStream thread since this error could be 
	//  in either of those autorelease pools.
	//  it so we don't have to worry about this.
	//----------------------------------------------------------------
	if (_errorOccurred) {
		assert (_error != nil); 
		NSDebug(@"[StreamingAudioDriver] Audio Stream Stopped due to Error = %d", [_error code]);
		[_delegate audioStreamEncounteredError:_error];
		_errorOccurred = NO;
		_error = nil;
	}
	//----------------------------------------------------------------
	//  Before we close the stream, we need to wait for our dataStream 
	//  thread to stop. This is important since nothing can access the audio
	//  file stream once we have closed.
	//
	//----------------------------------------------------------------
	if ([_dataStreamThread isExecuting]) {
		[_dataStreamThread cancel];
		//----------------------------------------------------------------
		//  To ensure that we do not get into a state where we are blocking
		//  waiting for the _dataStreamThread to stop and it is blocking wait
		//  to get signaled, we need to have this handshake where we grab
		//  the lock, signal, and release. In addition, the _dataStreamThread
		//  must check to see if it has been cancelled before waiting on the 
		//  condition.
		//----------------------------------------------------------------
		pthread_mutex_lock(&_streamStateLock);
		pthread_cond_signal(&_dataStreamIdleSignal);
		pthread_mutex_unlock(&_streamStateLock);
		
		while ([_dataStreamThread isExecuting]) 
			[NSThread sleepForTimeInterval:.005];
	}
	[_dataStreamThread release];
    _dataStreamThread = nil;
	
	
	pthread_mutex_lock(&_streamStateLock);
	
    AudioFileStreamClose(_audioData.audioFileStream);
	_audioData.audioFileStream = nil;
	
	
	//----------------------------------------------------------------
	//  Free all our our audio buffers
	//----------------------------------------------------------------
	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		AudioQueueFreeBuffer(_audioData.queue, _audioData.buffers[i]);
	}
    AudioQueueDispose(_audioData.queue, true);
	_audioData.queue = nil;
	
	[self changeState:kInternalStreamStateUninitialized];
	
	[pool drain];
	
	//----------------------------------------------------------------
	//  Signal anything that may be waiting on this thread to complete.
	//----------------------------------------------------------------
	pthread_cond_signal(&_audioQueueStopped);
	pthread_cond_signal(&_audioFileStreamFadeOutComplete);
	
	pthread_mutex_unlock(&_streamStateLock);
	
}

- (void) processStreamTimerInternal {
	pthread_mutex_lock(&_streamStateLock);
	
	if (_errorOccurred == YES) {
		[self changeState:kInternalStreamStateStopped];
		if (_audioData.audioQueueRunning) {
			//-----------------------------------------------------
			//  Stop the stream which will reset and clear out the 
			//  audio queue buffers
			//-----------------------------------------------------
			AudioQueueStop(_audioData.queue, YES);
			pthread_cond_wait(&_audioQueueStopped, &_streamStateLock);
		}
		pthread_mutex_unlock(&_streamStateLock);
		return;
	}
	
	//-----------------------------------------------
	//  Check to see if all the buffers are empty. If
	//  it is empty, we may need to transition to the 
	//  stopped state or the waitingForData state depeding
	//  on the current state and the _disableOnIdle flag
	//-----------------------------------------------
	pthread_mutex_lock(&_bufferLock);
	BOOL buffersInUse = NO;
	for (uint32_t i = 0; i < kNumAQBufs; ++i) {
		buffersInUse |= _audioData.bufferInUse[i];
	}
	pthread_mutex_unlock(&_bufferLock);
	
	if (!buffersInUse && !_processingAudioData) {
		if (![self isStopped] && (_disableOnIdle == YES) && [_streamData length] == 0) {
			[self changeState:kInternalStreamStateStopped];
			AudioQueueStop(_audioData.queue, false);
		}
		else if (![self isStopped] && _state == kInternalStreamStatePlaying)
			[self changeState:kInternalStreamStateWaitingForData];
	}
	else {
		//-----------------------------------------------
		//  Update the delegate with our progress when 
		//  we are playing
        //  
        //  (CG 9.3.2010) Note: We need to continuously update the
        //  playback progress anytime we are waiting for
        //  data and are ready to stream audio data. (meaining we already parsed the header).
        //  This happens since there is a chance that if 
        //  we get paused, we may go into the kInternalStreamStateWaitingForData
        //  state for awhile if our buffer are already full and it
        //  may take us some time to empty them and transition
        //  to the playing state.
		//-----------------------------------------------
		if(_state == kInternalStreamStatePlaying || (_state == kInternalStreamStateWaitingForData && _readyForAudioData)) {
			[self updateStreamProgressInternal];
			if (_fadeSongOut == YES) {
				if (_playbackProgressInS >= _fadeSongOutTimeInS) {
					//-----------------------------------------------
					//  If we have passed out fade time, we need to 
					//  initiate shutdown of the streaming audio
					//-----------------------------------------------
					[self changeState:kInternalStreamStateStopped];
					AudioQueueStop(_audioData.queue, true);
				}
				else {
					//----------------------------------------------------------------
					//  Set the current volume
					//----------------------------------------------------------------
					AudioQueueSetParameter(_audioData.queue, kAudioQueueParam_Volume, ((_fadeSongOutTimeInS - _playbackProgressInS)/mFadeOutTimeInS)*_volume);
				}
			}
			else if (_fadeSongIn == YES) {
				if (_playbackProgressInS >= mFadeInTimeInS) {
					AudioQueueSetParameter(_audioData.queue, kAudioQueueParam_Volume, _volume);
					_fadeSongIn = NO;
				}
				else {
					AudioQueueSetParameter(_audioData.queue, kAudioQueueParam_Volume, (1 - (mFadeInTimeInS - _playbackProgressInS)/mFadeInTimeInS)*_volume);
				}
			}
		}
	}	
	pthread_mutex_unlock(&_streamStateLock);
}

- (void) streamData:(NSData *)data byteOffset:(SInt64)byteOffset error:(NSError **)error {
	
	pthread_mutex_lock(&_streamStateLock);
	NSDebug(@"[StreamingAudioDriver] streamData data size = %d offset = %qi", [data length], byteOffset);
	//----------------------------------------------------------------
	//  If we are in a state where we can stream data (not stopped) then
	//  we can copy this data buffer. However we do have to check the seeking flag 
	//  in case the stream is seeking for a particular byte offset. If
	//  are seeking and this data doesn't begin at that byte offset, then
	//  we can't append the data.
	//----------------------------------------------------------------
	if (![self isStopped]) {
		if (_seeking == NO || (_seeking == YES && byteOffset == _audioData.bytePacketTranslation.mByte)) {
			_seeking = NO;
			[_streamData appendData:data];
			//----------------------------------------------------------------
			//  Signal the wait condition that the data streaming thread uses
			//  since there is data available for it to wake up and process.
			//----------------------------------------------------------------
			pthread_cond_signal(&_dataStreamIdleSignal);
		}
	}
	pthread_mutex_unlock(&_streamStateLock);
}

- (void) pauseStream:(NSError **)error {
	pthread_mutex_lock(&_streamStateLock);
	if ([self isStopped])
		*error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError5 userInfo:nil];
	else
		[self changeState:kInternalStreamStatePaused];
	pthread_mutex_unlock(&_streamStateLock);
}

- (void) updateStreamProgressInternal {
	//-----------------------------------------------
	//  Report the playback progress
	//-----------------------------------------------
	AudioTimeStamp queueTime;
	Boolean discontinuity;
	AudioQueueGetCurrentTime(_audioData.queue, NULL, &queueTime, &discontinuity);		
	_playbackProgressInS = queueTime.mSampleTime / _audioData.description.mSampleRate;
	if (_playbackProgressInS < 0.0) {
		_playbackProgressInS = 0.0;
	}
	_playbackProgressInS += _audioData.bytePacketTranslation.mPacket * _secondsPerPacket;
	
	[_delegate updatePlaybackTime:_playbackProgressInS totalTime:_duration];
}

- (void) streamDataInternal {
	//-----------------------------------------------
	//  Since this method is in  it's own thread, we 
	//  need to manage an autorelease pool
	//-----------------------------------------------
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	while (![[NSThread currentThread] isCancelled]) {
		//-----------------------------------------------
		//  Grab the streamState lock first to ensure the streamData
		//  method isn't trying to update _streamData while we
		//  are reading from it.
		//-----------------------------------------------
		pthread_mutex_lock(&_streamStateLock);
		NSMutableData * data = nil;
		if ([_streamData length] > 0) {
			data = [[NSMutableData alloc] initWithData:_streamData];
			[_streamData release];
			_streamData = [[NSMutableData alloc] init];
			_processingAudioData = YES;
		}
		//----------------------------------------------------------------
		//  It is important that we check the cancelled condition here 
		//  so we don't get into a race condition where the streamData thread
		//  is trying to shut us down and has already signaled this thread.
		//----------------------------------------------------------------
		else if (![[NSThread currentThread] isCancelled]) {
			if (!_seeking)
				_processingAudioData = NO;
            
			pthread_cond_wait(&_dataStreamIdleSignal, &_streamStateLock);
		}
		pthread_mutex_unlock(&_streamStateLock);
		
		//-----------------------------------------------------------
		//  The _streamStateLock lock must be released before calling parse 
		//  bytes on the audio file stream. 
		//  
		//  We are guarenteed audioFileStream is still valid,
		//  since the main thread for the audio streaming
		//  will wait for this thread to stop execution before
		//  destroying the audio file stream
		//-----------------------------------------------------------
		if (data != nil) {
			UInt32 parseFlags = _discontinuous ? kAudioFileStreamParseFlag_Discontinuity : 0;
			AudioFileStreamParseBytes(_audioData.audioFileStream, [data length], [data bytes], parseFlags);
			[data release];
		}
	}
	
	//-----------------------------------------------------------
	//  Cleanup
	//-----------------------------------------------------------
	[_streamData release];
	
	[pool drain];
}

- (void) stopStreamWithFade:(BOOL)fadeOut error:(NSError **)error {
	//----------------------------------------------------------------
	// When stop is called, we need to ensure that we grab the lock
	// and set the status to stopped so we will not enqueue any more 
	// buffers. 
	//----------------------------------------------------------------
	pthread_mutex_lock(&_streamStateLock);
	
	if (![self isStopped]) {
		if ([self isPlaying] && fadeOut == YES) {
			_fadeSongOut = YES;
			_fadeSongOutTimeInS = _playbackProgressInS + mFadeOutTimeInS;
            _disableOnIdle = YES;
		}
		else {
			[self changeState:kInternalStreamStateStopped];
			//----------------------------------------------------------------
			//  Stop the queue and wait for the audio queue to fully stop
			//----------------------------------------------------------------
			AudioQueueStop(_audioData.queue, true /* stop immediately */);  
			while (_state != kInternalStreamStateUninitialized) {
				pthread_cond_wait(&_audioQueueStopped, &_streamStateLock);
			}
			assert(_state == kInternalStreamStateStopped || _state == kInternalStreamStateUninitialized);
		}
	}	
	
	pthread_mutex_unlock(&_streamStateLock);
}

- (void) stopStreamOnIdle:(bool)waitForPlay error:(NSError **)error {
	//----------------------------------------------------------------
    //  This will put the player in a state where is will shut itself
	//  down when it goes idle. If waitForPlay is true, then it will
	//  ensure it is either in the playing state or will wait for the
	//  audio stream to transition to the playing state before arming
	//  the audio stop.
	//----------------------------------------------------------------
	pthread_mutex_lock(&_streamStateLock);
	if (![self isStopped]) {
		_disableOnIdle = (waitForPlay == NO || [self isPlaying]);
		_disableOnIdleAfterPlaying = !_disableOnIdle;
	}
	pthread_mutex_unlock(&_streamStateLock);
}

- (void) enqueueBuffer
{
	//----------------------------------------------------------------
    //  As long as the stream isn't stopping, then enqueue the current
	//  buffer in the audio queue.
	//----------------------------------------------------------------
	pthread_mutex_lock(&_streamStateLock);
	if ([self isStopped] || _seeking == YES) {
		pthread_mutex_unlock(&_streamStateLock);
		return;
	}
	
	
	pthread_mutex_lock(&_bufferLock); 
	OSStatus err = noErr;
	assert(_audioData.bufferInUse[_audioData.fillBufferIndex] == false);
	_audioData.bufferInUse[_audioData.fillBufferIndex] = true;
	uint32_t buffersInUseCount = 0;
	if (_state == kInternalStreamStateWaitingForData) {
		for (uint32_t i = 0; i < kNumAQBufs; ++i) {
			buffersInUseCount += _audioData.bufferInUse[i] ? 1 : 0;
		}
	}
	pthread_mutex_unlock(&_bufferLock); 
	
	// enqueue buffer
	AudioQueueBufferRef fillBuf = _audioData.buffers[_audioData.fillBufferIndex];
	fillBuf->mAudioDataByteSize = _audioData.bytesFilled;        
	err = AudioQueueEnqueueBuffer(_audioData.queue, fillBuf, _audioData.packetsFilled, _audioData.packetDescs);
	NSDebug(@"[StreamingAudioDriver] Enqueued Buffer %d with num packets %d",_audioData.fillBufferIndex, _audioData.packetsFilled);
	if (_state == kInternalStreamStateWaitingForData)
		_bufferedPackets += _audioData.packetsFilled;
	
	if (_state == kInternalStreamStateWaitingForData && ((buffersInUseCount == kNumAQBufs) || (_bufferedPackets >= _bufferingDelayInPackets) || (_disableOnIdleAfterPlaying == YES))) {
		[self changeState:kInternalStreamStatePlaying];
		_bufferedPackets = 0;
	}
	pthread_mutex_unlock(&_streamStateLock);
}


- (void) waitForFreeBuffer
{
	//----------------------------------------
	//  Advance the buffer index and update our
	//  current buffer paramaters
	//----------------------------------------
	if (++_audioData.fillBufferIndex >= kNumAQBufs) _audioData.fillBufferIndex = 0;
	_audioData.bytesFilled = 0;  
	_audioData.packetsFilled = 0;  
	
	//----------------------------------------
	//  Wait until the buffer we need is 
	//  available.
	//----------------------------------------
	pthread_mutex_lock(&_bufferLock); 
	
	while (_audioData.bufferInUse[_audioData.fillBufferIndex]) {
		if ([self isStopped]){
			pthread_mutex_unlock(&_bufferLock);
			return;
		}
		pthread_cond_wait(&_bufferAvailable, &_bufferLock);
	}
    
	pthread_mutex_unlock(&_bufferLock);
}

- (MultimediaPlayerState) getState:(NSError**)error {
	return [self mapInternalStateToPublicState:_state];
}

- (MultimediaPlayerState)mapInternalStateToPublicState:(InternalStreamState)state {
	switch (state) {
		case kInternalStreamStateUninitialized:
		case kInternalStreamStateInitializing:
		case kInternalStreamStateStopped:
			return kMultimediaPlayerStateStopped;
			
		case kInternalStreamStateWaitingForData:
			return kMultimediaPlayerStateBuffering;
			
		case kInternalStreamStatePaused:
			return kMultimediaPlayerStatePaused;
			
		case kInternalStreamStatePlaying:
			return kMultimediaPlayerStatePlaying;
			
		default:
			assert (0);
			break;
	}
	return kMultimediaPlayerStateStopped;
}

- (void) changeState:(InternalStreamState)newState {
	assert(_delegate != nil);
	
	if (newState == _state) return;
	
	BOOL updateDelegate = NO;
	BOOL pauseAudioQueue = NO;
	BOOL startAudioQueue = NO;
	
	//-----------------------------------------------
	//  Update our current state and depending on the
	//  transition, we need to inform the delegate
	//-----------------------------------------------
	switch (_state) {
		case kInternalStreamStateUninitialized: {
			//-----------------------------------------------
			//  We can only move to the initialized state
			//  when we are uninitialized.
			//-----------------------------------------------
			assert(kInternalStreamStateInitializing == newState);
	        break;
		}
		case kInternalStreamStateInitializing: {
			//-----------------------------------------------
			//  We can move to two other state from this.
			//  Uninitialized and WaitingForData
			//-----------------------------------------------
			assert(kInternalStreamStateUninitialized == newState || 
				   kInternalStreamStateWaitingForData == newState);
			if (kInternalStreamStateWaitingForData == newState) {
				updateDelegate = YES;
			}
	        break;
		}
		case kInternalStreamStateWaitingForData:{
			assert(kInternalStreamStatePlaying == newState || 
				   kInternalStreamStatePaused == newState || 
				   kInternalStreamStateStopped == newState);
			updateDelegate = YES;
			if (newState == kInternalStreamStatePaused) {
				pauseAudioQueue = YES;
			}
			else if (newState == kInternalStreamStatePlaying) {
				if (_disableOnIdleAfterPlaying == YES){
					_disableOnIdleAfterPlaying = NO;
					_disableOnIdle = YES;
				}
				startAudioQueue = YES;
			}
			break;
		}
		case kInternalStreamStatePlaying:{
			assert(kInternalStreamStateWaitingForData == newState || 
				   kInternalStreamStatePaused == newState || 
				   kInternalStreamStateStopped == newState);
			updateDelegate = YES;
			if (newState == kInternalStreamStateWaitingForData ||
				newState == kInternalStreamStatePaused) {
				//-----------------------------------------------
				//  If we transition from playing to waiting for data
				//  we need to pause the audio queue
				//-----------------------------------------------
				pauseAudioQueue = YES;
			}
			break;
		}
		case kInternalStreamStatePaused:{
			assert(kInternalStreamStateWaitingForData == newState || 
				   kInternalStreamStateStopped == newState);
			updateDelegate = YES;
			if ((newState == kInternalStreamStateWaitingForData) && _readyForAudioData) {
				startAudioQueue = YES;
			}
			break;
		}
		case kInternalStreamStateStopped:{
			assert(kInternalStreamStateUninitialized == newState);
			break;
		}
		default:
			assert (0);
			break;
	}
	
	assert (!(pauseAudioQueue && startAudioQueue));
	OSStatus temp = 0;
	if (pauseAudioQueue == YES) {
		temp = AudioQueuePause(_audioData.queue);
	}
	else if (startAudioQueue == YES)
		temp = AudioQueueStart(_audioData.queue, NULL);
	
	if (updateDelegate == YES) {
		NSNumber * oldStateNumber = [NSNumber numberWithInteger:_state];
		NSNumber * newStateNumber = [NSNumber numberWithInteger:newState];
	    [NSThread detachNewThreadSelector:@selector(updateDelegateStateInternal:) toTarget:self withObject:[NSArray arrayWithObjects:oldStateNumber,newStateNumber,nil]];
	}
	NSDebug(@"[StreamingAudioDriver] Changed State from %d to %d",_state,newState);
	_state = newState;
}

- (void) updateDelegateStateInternal:(NSArray *)parameterArray {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	InternalStreamState oldState = [[parameterArray objectAtIndex:0] integerValue];
	InternalStreamState newState = [[parameterArray objectAtIndex:1] integerValue];
	[_delegate stateChangedFrom:[self mapInternalStateToPublicState:oldState] toState:[self mapInternalStateToPublicState:newState] error:nil];
	
	[pool drain];
}

- (BOOL) isStopped {
	return ((_state == kInternalStreamStateStopped) ||
			(_state == kInternalStreamStateUninitialized) ||
			(_state == kInternalStreamStateInitializing));
}

- (BOOL) isBuffering {
	return (_state == kInternalStreamStateWaitingForData);
}

- (BOOL) isPlaying {
	return (_state == kInternalStreamStatePlaying);
}

- (void) audioOutputCallbackInternal:(AudioQueueRef) outAQ
									:(AudioQueueBufferRef) outBuffer {
	//-----------------------------------------------
	//  Find the buffer index that the outBuffer represents
	//-----------------------------------------------
	int32_t index = -1;
	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		if (outBuffer == _audioData.buffers[i]) 
			index = i;
	}
	assert(index >=0);
	
	//-----------------------------------------------
	//  Update the in use indicators and signal any 
	//  threads that are waiting on a buffer to become
	//  available
	//-----------------------------------------------
	pthread_mutex_lock(&_bufferLock);
	_audioData.bufferInUse[index] = false;
	pthread_cond_signal(&_bufferAvailable);
	pthread_mutex_unlock(&_bufferLock);
}

- (void) audioQueuePropertyListenerCallbackInternal:(AudioQueueRef)inAQ 
												   :(AudioQueuePropertyID)inID {
	
	if (inID == kAudioQueueProperty_IsRunning) {
		UInt32 size = sizeof(_audioData.audioQueueRunning);
		AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &_audioData.audioQueueRunning, &size);
		if (!_audioData.audioQueueRunning) {
			//-----------------------------------------------
			//  If the audio stream has been stopped, update
			//  the internal state and signal the stopped 
			//  condition.
			//-----------------------------------------------
			pthread_mutex_lock(&_streamStateLock);
			pthread_cond_signal(&_audioQueueStopped);
			pthread_mutex_unlock(&_streamStateLock);
		}
		
	}
}

- (void) audioFileStream_ProperyListnerInternal:(AudioFileStreamID)inAudioFileStream
								               :(AudioFileStreamPropertyID)inPropertyID
									           :(UInt32 *)ioFlags {
	OSStatus err;
	
    switch (inPropertyID) {
        case kAudioFileStreamProperty_ReadyToProducePackets :
        {
			pthread_mutex_lock(&_streamStateLock);
			
			if ([self isStopped]) {
				pthread_mutex_unlock(&_streamStateLock);
				return;
			}
			
			//----------------------------------------------------------------
			//  The audio file stream is ready to start sending data. We need
			//  to setup our audio queue
			//----------------------------------------------------------------
			UInt32 audioStreamDescSize = sizeof(_audioData.description);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &audioStreamDescSize, &_audioData.description);
			if (err) { 
				NSDebug(@"[StreamingAudioDriver] AudioFileStreamGetProperty returned an error %d on open", err);
				_errorOccurred = YES;
				_error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError4 userInfo:nil];
				pthread_mutex_unlock(&_streamStateLock);
				break; 
			}
			
			//----------------------------------------------------------------
			//  Create the audio queue to playback our audio data
			//----------------------------------------------------------------
			err = AudioQueueNewOutput(&_audioData.description, AudioOutputCallback, self, NULL, NULL, 0, &_audioData.queue);
			if (err) { 
				NSDebug(@"[StreamingAudioDriver] AudioQueueNewOutput returned an error %d on output", err);
				_errorOccurred = YES;
				_error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError4 userInfo:nil];
				pthread_mutex_unlock(&_streamStateLock);
				break; 
			}
			
			float currentVolume = _fadeSongIn ? 0 : _volume;
			//----------------------------------------------------------------
			//  Set the current volume
			//----------------------------------------------------------------
			err = AudioQueueSetParameter(_audioData.queue, kAudioQueueParam_Volume, currentVolume);
			if (err) { 
				NSDebug(@"[StreamingAudioDriver] AudioQueueNewOutput returned an error %d setting the volume", err);
				_errorOccurred = YES;
				_error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError4 userInfo:nil];
				pthread_mutex_unlock(&_streamStateLock);
				break; 
			}
			
			//----------------------------------------------------------------
			//  Allocate the buffers for the audio queue
			//----------------------------------------------------------------
			for (uint32_t i = 0; i < kNumAQBufs; ++i) {
				err = AudioQueueAllocateBuffer(_audioData.queue, kAQBufSize, &_audioData.buffers[i]);
				_audioData.bufferInUse[i] = NO;
				if (err) { 
					NSDebug(@"[StreamingAudioDriver] AudioQueueAllocateBuffer returned an error %d on open", err);
					_errorOccurred = YES;
					_error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError4 userInfo:nil];
					pthread_mutex_unlock(&_streamStateLock);
					break; 
				} 
			}
			
			if (err) break;
			
			//---------------------------------------------------
			//  The magic cookie property settings may fail if it
			//  does not exist in this stream. The only expected
			//  faulure would be on the first call to get the 
			//  size of the magic cookie. 
			//---------------------------------------------------
			UInt32 cookieSize;
			Boolean writable;
			OSStatus localErr = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
			if (localErr == kAudioFileStreamError_BadPropertySize) {
				//---------------------------------------------------
				//  Now that we have the cookie size, get the cookie
				//  from the stream and hand it to the queue, this 
				//  should not fail
				//---------------------------------------------------
				void* cookieData = calloc(1, cookieSize);
				err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
				if (err) { 
					free(cookieData);
					NSDebug(@"[StreamingAudioDriver] Error getting the magic cookie - %d", err);
					_errorOccurred = YES;
					_error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError4 userInfo:nil];
					pthread_mutex_unlock(&_streamStateLock);
					break; 
				}
				
				err = AudioQueueSetProperty(_audioData.queue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
				free(cookieData);
				if (err) { 
					free(cookieData);
					NSDebug(@"[StreamingAudioDriver] Error setting the magic cookie - %d", err);
					_errorOccurred = YES;
					_error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError4 userInfo:nil];
					pthread_mutex_unlock(&_streamStateLock);
					break; 
				}
				
			}
			
			//---------------------------------------------------
			//  Register our audio queue property queue callback
			//  to get notififed when the queue starts and stops
			//---------------------------------------------------
			err = AudioQueueAddPropertyListener(_audioData.queue, kAudioQueueProperty_IsRunning, AudioQueuePropertyListenerCallback, self);
			if (err) { 
				NSDebug(@"[StreamingAudioDriver] Error %d occurred when adding property lisner to the audio queue", err);
				_errorOccurred = YES;
				_error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError4 userInfo:nil];
				pthread_mutex_unlock(&_streamStateLock);
				break; 
			} 
			
			assert (!_errorOccurred);
			
			_readyForAudioData = YES;
			_discontinuous = YES;
			
			[self changeState:kInternalStreamStateWaitingForData];			
            pthread_mutex_unlock(&_streamStateLock);
			
			break;
        }
    }
}

- (void) audioFileStream_PacketsProcInternal:(UInt32)inNumberBytes
                                            :(UInt32)inNumberPackets
                                            :(const void *)inInputData
                                            :(AudioStreamPacketDescription *)inPacketDescriptions {
    
	if ([self isStopped] || _seeking == YES || _errorOccurred) {
		return;
	}
	
	assert (_readyForAudioData == YES);
	
	//---------------------------------------------------
	//  Calculate the duration of the audio file
	//---------------------------------------------------
	if (_duration < 0) {
		_secondsPerPacket = (float) _audioData.description.mFramesPerPacket / (float)_audioData.description.mSampleRate;
		_bufferingDelayInPackets = _bufferingDelayInS / _secondsPerPacket;
		if ((_audioData.description.mBytesPerFrame == 0) || (_audioData.description.mBytesPerPacket == 0)) {
			NSDebug(@"[StreamingAudioDriver] Calculating duration of VBR");			
			UInt64 totalPackets = 0;
			UInt32 size = sizeof(totalPackets);
			OSStatus err = AudioFileStreamGetProperty(_audioData.audioFileStream, kAudioFileStreamProperty_AudioDataPacketCount, &size, &totalPackets);
			if (err) {
				//----------------------------------------------------------------------------------------
				//  It appears that for CBR MP3 files, the kAudioFileStreamProperty_AudioDataPacketCount
				//  will sometimes fail. I am guessing this is because that information is not available
				//  in the header. In that case we can calculate off the bitrate. 
				//
				//  Note: CBR mp3 files get treated as VBR when using the audio file stream since we 
				//  get packet descriptions for all the packets. (inPacketDescriptions != null)
				//----------------------------------------------------------------------------------------
				UInt32 bitRate;
				UInt32 size = sizeof(bitRate);
				err = AudioFileStreamGetProperty(_audioData.audioFileStream, kAudioFileStreamProperty_BitRate, &size, &bitRate);
				if (err) {
					NSDebug(@"[StreamingAudioDriver] Could not get bitrate from file. Error %d", err);
					_errorOccurred = YES;
					_error = [NSError errorWithDomain:StreamingAudioDriverErrorDomain code:SAError4 userInfo:nil];
					return;
				}
				_duration = _streamAudioDataSizeInBytes*8 / (bitRate);
			}
			else {
				//---------------------------------------------------
				//  CBR Data
				//---------------------------------------------------
				_duration = totalPackets * _secondsPerPacket;
			}
		}
		else {
			NSDebug(@"[StreamingAudioDriver] Calculating duration of CBR");
			_duration = (_streamAudioDataSizeInBytes / _audioData.description.mBytesPerPacket) * _secondsPerPacket;
		}
		assert(_duration > 0);
	}
	
	_discontinuous = NO;
	
	if (inPacketDescriptions)
	{
		//-----------------------------------------------
		//  This must be VBR data
		//-----------------------------------------------
		NSDebug(@"[StreamingAudioDriver] VBR Data Found");
		for (int i = 0; i < inNumberPackets; ++i)
		{
			SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
			SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
			size_t bufSpaceRemaining;
			
			assert(packetSize <= kAQBufSize);
			
			bufSpaceRemaining = kAQBufSize - _audioData.bytesFilled;
			
			//-----------------------------------------------
			//  Enqueue the current buffer if we do not have
			//  enough space for this packet
			//-----------------------------------------------
			if (bufSpaceRemaining < packetSize){
				[self enqueueBuffer];
				[self waitForFreeBuffer];
			}
			
			//-----------------------------------------------
			//  Ensure it is always safe to copy to the 
			//  queue buffer.
			//-----------------------------------------------
			pthread_mutex_lock(&_streamStateLock);
			if ([self isStopped] || _seeking == YES) {
				pthread_mutex_unlock(&_streamStateLock);
				return;
			}
			
			// copy data to the audio queue buffer
			AudioQueueBufferRef fillBuf = _audioData.buffers[_audioData.fillBufferIndex];
			memcpy((char*)fillBuf->mAudioData + _audioData.bytesFilled, (const char*)inInputData + packetOffset, packetSize);
			
			//-----------------------------------------------
			//  The _streamStateLock must be release before
			//  enqueueing a buffer. 
			//-----------------------------------------------
			pthread_mutex_unlock(&_streamStateLock);
			
			//-----------------------------------------------
			//  Update the packet info for our current buffer
			//-----------------------------------------------
			_audioData.packetDescs[_audioData.packetsFilled] = inPacketDescriptions[i];
			_audioData.packetDescs[_audioData.packetsFilled].mStartOffset = _audioData.bytesFilled;
			
			_audioData.bytesFilled += packetSize;
			_audioData.packetsFilled += 1;
			assert (_audioData.bytesFilled <= kAQBufSize);
			
			//-----------------------------------------------
			//  Enqueue the current buffer if we have filled
			//  all the packet descriptions
			//-----------------------------------------------
			size_t packetsDescsRemaining = kAQMaxPacketDescs - _audioData.packetsFilled;
			if (packetsDescsRemaining == 0) {
				[self enqueueBuffer];
				[self waitForFreeBuffer];
			}
		}
		//---------------------------------------------------
		//  Enqueue the remaining packets
		//---------------------------------------------------
		if (_audioData.packetsFilled > 0){
			pthread_mutex_lock(&_streamStateLock);
			bool moreDataHasBeenStreamed = ([_streamData length] > 0);
			pthread_mutex_unlock(&_streamStateLock);
			if (!moreDataHasBeenStreamed) {
				[self enqueueBuffer];
				[self waitForFreeBuffer];
			}
		}
	}
	else {
		//---------------------------------------------------
		//  Handle CBR Data - For CBR data, we just copy the 
		//  raw bytes to our buffer
		//---------------------------------------------------
		NSDebug(@"[StreamingAudioDriver] CBR Data Found");
		uint32_t offset = 0;
		while (offset < inNumberBytes) {
			//----------------------------------------
			//  Ensure it is always safe to copy to the 
			//  queue buffer.
			//----------------------------------------
			pthread_mutex_lock(&_streamStateLock);
			if ([self isStopped] || _seeking == YES) {
				pthread_mutex_unlock(&_streamStateLock);
				return;
			}
			
			AudioQueueBufferRef fillBuf = _audioData.buffers[_audioData.fillBufferIndex];
			if (offset + kAQBufSize < inNumberBytes) {
				//----------------------------------------
				//  Fill a whole audio queue buffer
				//----------------------------------------
				memcpy((char*)fillBuf->mAudioData, (const char*)inInputData + offset, kAQBufSize);
				_audioData.bytesFilled += kAQBufSize;
			}
			else {
				//----------------------------------------
				//  Fill the audio buffer with the remaining 
				//  data in the inInputData buffer. 
				//----------------------------------------
				memcpy((char*)fillBuf->mAudioData, (const char*)inInputData + offset, inNumberBytes - offset);
				_audioData.bytesFilled += inNumberBytes - offset;
			}
			pthread_mutex_unlock(&_streamStateLock);
			[self waitForFreeBuffer];
			[self enqueueBuffer];
			
			offset += kAQBufSize;
		}
	}
}

- (void) audioSessionInterruptListnerInternal:(UInt32)inInterruptionState{
	pthread_mutex_lock(&_streamStateLock);
	if (inInterruptionState == kAudioSessionBeginInterruption) {  
		if (_state == kInternalStreamStateWaitingForData || _state == kInternalStreamStatePlaying) {
			[self changeState:kInternalStreamStatePaused];
		    _audoResumeAfterInterruption = YES;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"startedInterruption" object:self];
		AudioSessionSetActive(false);
	}
	else if (inInterruptionState == kAudioSessionEndInterruption) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"endedInterruption" object:self];
		//-----------------------------------------------------------
		//  It is important that we set our audio session active again
		//  or else we will have problems with our current audio queues
		//-----------------------------------------------------------
		AudioSessionSetActive(true);
		if (_audoResumeAfterInterruption == YES)
			[self changeState:kInternalStreamStateWaitingForData];
		_audoResumeAfterInterruption = NO;
	}		
	pthread_mutex_unlock(&_streamStateLock);
}

//-----------------------------------------------------------
//  C functions that wrap our objective C calls for audio queue
//  and audio file stream service callbacks
//-----------------------------------------------------------
void AudioFileStream_ProperyListner( void *                           inClientData,
									AudioFileStreamID                inAudioFileStream,
									AudioFileStreamPropertyID        inPropertyID,
									UInt32 *                         ioFlags)
{    
   	StreamingAudioDriver * audioDriver = (StreamingAudioDriver*)inClientData;
	[audioDriver audioFileStream_ProperyListnerInternal:inAudioFileStream :inPropertyID :ioFlags];
}


void audioFileStream_PacketsProc(void                          *inClientData,
								 UInt32                        inNumberBytes,
								 UInt32                        inNumberPackets,
								 const void                    *inInputData,
								 AudioStreamPacketDescription  *inPacketDescriptions)
{
	StreamingAudioDriver * audioDriver = (StreamingAudioDriver*)inClientData;
	[audioDriver audioFileStream_PacketsProcInternal:inNumberBytes :inNumberPackets :inInputData :inPacketDescriptions];
}


void AudioQueuePropertyListenerCallback(        void*                    inClientData, 
										AudioQueueRef            inAQ, 
										AudioQueuePropertyID    inID)
{
	StreamingAudioDriver * audioDriver = (StreamingAudioDriver*)inClientData;
	[audioDriver audioQueuePropertyListenerCallbackInternal:inAQ :inID];
}

void AudioOutputCallback(void* inUserData,
						 AudioQueueRef outAQ,
						 AudioQueueBufferRef outBuffer)
{
	StreamingAudioDriver * audioDriver = (StreamingAudioDriver*)inUserData;
	[audioDriver audioOutputCallbackInternal:outAQ :outBuffer];
}

void audioSessionInterruptionListener (void     *inClientData,
									   UInt32   inInterruptionState)
{	
	StreamingAudioDriver * audioDriver = (StreamingAudioDriver*)inClientData;
	[audioDriver audioSessionInterruptListnerInternal:inInterruptionState];
}

@end
