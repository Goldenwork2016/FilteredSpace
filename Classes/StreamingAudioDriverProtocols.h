

@protocol StreamingAudioPlayer <NSObject>
@required
- (void) startStreamWithFade:(BOOL)fadeIn buffering:(float)bufferingTimeInS error:(NSError **)error;
- (void) streamData:(NSData *)data byteOffset:(SInt64)byteOffset error:(NSError **)error;
- (void) stopStreamWithFade:(BOOL)fadeOut error:(NSError **)error;
- (void) stopStreamOnIdle:(bool)waitForPlay error:(NSError **)error;
- (void) pauseStream:(NSError **)error;
- (void) seek:(float)seekTime byteOffset:(SInt64 *)byteOffset error:(NSError **)error;
- (void) updateVolume:(float)volume error:(NSError **)error;
- (MultimediaPlayerState) getState:(NSError **)error;
- (void) setStreamAudioDataSizeInBytes:(SInt64)size;
@end

@protocol StreamingAudioPlayerDelegate <NSObject>
@required
- (void) stateChangedFrom:(MultimediaPlayerState)oldState toState:(MultimediaPlayerState)newState error:(NSError **)error;
- (void) updatePlaybackTime:(float)time totalTime:(float)totalTime;
- (void) audioStreamEncounteredError:(NSError *)error;
@end

