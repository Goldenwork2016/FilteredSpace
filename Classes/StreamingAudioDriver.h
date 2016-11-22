//
//  StreamingAudioDriver.h
//  TheFilter
//
//  Created by Chris Green on 12/13/09.
//

#import "Common.h"
#import "pthread.h"
#import "semaphore.h"

//------------------------------------------------
//  Fixed times that we will attenuate the volume
//  to fade out or ramp up the volume to fade in
//  a song.
//------------------------------------------------
#define mFadeOutTimeInS .25
#define mFadeInTimeInS .25

@class StreamingAudioDriver;

//--------------------------------------------------------------------
//  Set of internal states used by the Streaming Audio Driver. 
//
//  kInternalStreamStateUninitialized - The stream has not
//     been started.
//
//  kInternalStreamStateInitializing - Thehe stream has been started, 
//     but is not ready to receive data.
//
//  kInternalStreamStateWaitingForData - The stream is started and is 
//     available to steam data.
//
//  kInternalStreamStatePlaying - The stream is playing audio. In this state
//     the audio file stream can accept more data also.
//
//  kInternalStreamStateStopped - The stream has been stopped and is
//     in the process of shutting down. Streaming data is not allowed in this state.
//
//  kInternalStreamStatePaused - The stream is paused. Streaming data is allowed,
//     but it will not be played until the stream is unpaused.
//--------------------------------------------------------------------
typedef enum {
	kInternalStreamStateUninitialized    = 0,
	kInternalStreamStateInitializing     = 1,
	kInternalStreamStateWaitingForData   = 2,
	kInternalStreamStatePlaying          = 3,
	kInternalStreamStateStopped          = 4,
	kInternalStreamStatePaused           = 5
} InternalStreamState;

//------------------------------------------------------------
//  Struct containing all the audio data objects used for 
//  the streaming audio file stream and the audio queue 
//  services.
//------------------------------------------------------------
typedef struct
{
	AudioStreamBasicDescription  dataFormat;
	AudioQueueRef                queue;
	UInt32                       audioQueueRunning;
	AudioQueueBufferRef          buffers[4];
	bool                         bufferInUse[4];
	AudioStreamBasicDescription  description;
	AudioStreamPacketDescription packetDescs[512];
	AudioFileStreamID            audioFileStream;
	uint32_t                     fillBufferIndex;
	uint32_t                     bytesFilled;
	uint32_t                     packetsFilled;
    AudioBytePacketTranslation   bytePacketTranslation;
} StreamingAudioData;

/**
 * class StreamingAudioDriver
 * @description Provides a StreamingAudioPlayer interface to stream and control an audio stream
 */
@interface StreamingAudioDriver : NSObject <StreamingAudioPlayer> {
	//------------------------------------------------------------
	//  Public
	//------------------------------------------------------------
	id <StreamingAudioPlayerDelegate> _delegate;
	SInt64			                  _streamAudioDataSizeInBytes;
	//------------------------------------------------------------
	//  Private Members
	//------------------------------------------------------------
	StreamingAudioData   _audioData; 
	InternalStreamState  _state;
	NSMutableData *      _streamData; /* Intermediate buffer for the streamed data */
	bool                 _discontinuous;
	bool                 _readyForAudioData;
	bool                 _processingAudioData; /* This lets the main stream thread know there data thread is processing data */
	bool                 _disableOnIdle;
	bool                 _disableOnIdleAfterPlaying;
	bool                 _seeking;
	float                _duration;
	SInt64				 _seekByteOffset;
	float                _secondsPerPacket;
	NSThread *           _dataStreamThread;
	NSError *            _error;
	bool                 _errorOccurred;
	float                _bufferingDelayInS; 
	SInt32               _bufferingDelayInPackets;
	SInt32               _bufferedPackets;
	float                _volume;
    UInt32				 _fileFormatType;
	float				 _playbackProgressInS;
	bool				 _fadeSongOut;
	bool				 _fadeSongIn;
	float				 _fadeSongOutTimeInS;
	BOOL                 _audoResumeAfterInterruption;
	//------------------------------------------------------------
	//  Synchronization Objects
	//
	//  _streamStateLock - General lock used when modifying any
	//     of the member data in the audio stream driver. It is safe
	//     to grab the _bufferLock while holding this lock.
	//  _bufferLock - Used to update the inuse state of the buffers. It
	//     is NOT safe to grab the _streamStateLock while holding this lock.
	//------------------------------------------------------------
	pthread_mutex_t _streamStateLock;
	pthread_mutex_t _bufferLock;
	pthread_cond_t  _bufferAvailable;     
    pthread_cond_t  _audioQueueStopped;
	pthread_cond_t  _audioFileStreamStarted;
	pthread_cond_t  _audioFileStreamFadeOutComplete;
	pthread_cond_t  _dataStreamIdleSignal;
}
 
@property (assign) id <StreamingAudioPlayerDelegate> delegate;
@property (assign) SInt64 streamAudioDataSizeInBytes;

@end
