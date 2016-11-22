
@protocol StreamMediaManager <NSObject>
@required
- (void)pause;
- (void)stop;
- (void)prePlayURL:(NSString *)url;
- (void)playURL:(NSString *)url;
- (void)scrubbingProgress:(float)progress;
@end

@protocol StreamMediaUI <NSObject>
@required
- (void)mediaEnded:(BOOL)songOver;
- (void)mediaStarted;
- (void)mediaPaused;
- (void)mediaProgress:(float)progress;
- (void)mediaError:(NSError *)error;
@optional
- (void)downloadProgress:(float)progress;
@end

