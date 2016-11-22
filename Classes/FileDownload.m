//
//  FileDownload.m
//  Untitled
//
//  Created by Eric Chapman on 12/13/09.
//

#import "FileDownload.h"
#import "NetworkActive.h"

static NSString * TheFilterFileRunLoopMode = @"BPFileRunLoopMode";


@interface FileDownload(hidden)
- (void)startConnection;
- (void)beginDownloadWithStreamInternal:(BOOL)stream error:(NSError **)error;
- (void)cancelDownloadInternal:(NSError **)error;
@end

@implementation FileDownload(thread)

//-------------------------------------------------------------------------
// Private class variables to handle the thread
//-------------------------------------------------------------------------
static NSRunLoop * _runLoop = nil;			/** Pointer to the run loop for the thread */
static NSThread * _thread = nil;			/** Pointer to the thread (used for error checking) */
static BOOL _isThreadCreated = NO;			/** Flag signalling if hte thread was created */
static BOOL _isThreadFinished = NO;			/** Flag signalling if the thread finished */
static NSCondition * _mutexNetworkThread;	/** Condition to handle starting of thread */

//-------------------------------------------------------------------------
// This method will create the network thread.  If it is called and the 
// thread is already spawned, then it will do nothing
//-------------------------------------------------------------------------

+ (void)createNetworkThread {
	
	//-------------------------------------------------------------------------
	// Ensure multiple threads do not run in this at the same time
	//-------------------------------------------------------------------------
	@synchronized(self) {
		
		[_mutexNetworkThread lock];
		
		//-------------------------------------------------------------------------
		// Do nothing if the spread has not thawned
		//-------------------------------------------------------------------------
		if(!_isThreadCreated){
			
			assert(!_runLoop);
			assert(!_thread);
			
			//-------------------------------------------------------------------------
			// Spawn the new thread
			//-------------------------------------------------------------------------
			[NSThread detachNewThreadSelector:@selector(threadMain) toTarget:[FileDownload class] withObject:nil];
			
			//-------------------------------------------------------------------------
			// Initialize the flags
			//-------------------------------------------------------------------------
			_isThreadCreated = YES;
			_isThreadFinished = NO;
			
			//-------------------------------------------------------------------------
			// Wait for the thread to spawn
			//-------------------------------------------------------------------------
			[_mutexNetworkThread wait];
			
		}
		else
			[_mutexNetworkThread unlock];
		
	}
}
//-------------------------------------------------------------------------
// This method releases the network thread
//-------------------------------------------------------------------------
+ (void)releaseNetworkThread {
	
	//-------------------------------------------------------------------------
	// Ensure multiple threads do not run in this at the same time
	//-------------------------------------------------------------------------
	@synchronized(self) {		

		//-------------------------------------------------------------------------
		// This locks the connection until the network thread is destroyed
		//-------------------------------------------------------------------------
		[_mutexNetworkThread lock];
		
		_isThreadFinished = YES;
		
		//-------------------------------------------------------------------------
		// Wait for the thread exit
		//-------------------------------------------------------------------------
		[_mutexNetworkThread wait];
		
	}
}

//-------------------------------------------------------------------------
// The main thread loop
//-------------------------------------------------------------------------
+ (void)threadMain {
	
	//-------------------------------------------------------------------------
	// Need to create a release pool for this thread
	//-------------------------------------------------------------------------
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//-------------------------------------------------------------------------
	// Set the run loop and thread pointers
	//-------------------------------------------------------------------------
	_runLoop = [NSRunLoop currentRunLoop];
	_thread = [NSThread currentThread];
	
	assert(_thread != [NSThread mainThread]);
	
	//-------------------------------------------------------------------------
	// Unlock the mutex and signal that we are done
	//-------------------------------------------------------------------------
	[_mutexNetworkThread unlock];
	[_mutexNetworkThread signal];
	
	
	//-------------------------------------------------------------------------
	//  Setup timer to prevent over-polling
	//-------------------------------------------------------------------------
	NSTimer *downloadTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(processFileTimer) userInfo:nil repeats:YES];
	[_runLoop addTimer:downloadTimer forMode:TheFilterFileRunLoopMode];
	
	//-------------------------------------------------------------------------
	// This loop will keep the thread alive
	//-------------------------------------------------------------------------
	while(!_isThreadFinished){
		
		//NSLog(@"currentPollTime: %f", [[NSDate date] timeIntervalSinceReferenceDate]);
		
		[_runLoop runMode:TheFilterFileRunLoopMode beforeDate:[NSDate distantFuture]];
		
		
	}
	
	
	[downloadTimer invalidate];
	
	//-------------------------------------------------------------------------
	// At this point, we are exiting the thread.  Clean up
	//-------------------------------------------------------------------------
	_runLoop = nil;
	_thread = nil;
	_isThreadCreated = NO;

	[pool release];
	
	//-------------------------------------------------------------------------
	// Unlock the mutex and signal that we are done
	//-------------------------------------------------------------------------
	[_mutexNetworkThread unlock];
	[_mutexNetworkThread signal];
}


+(void)processFileTimer {
	
	
	
}

 
@end

@implementation FileDownload(hidden)

- (void)beginDownloadWithStreamInternal:(BOOL)stream error:(NSError **)error {

	assert(_delegate != nil);
	assert([_delegate conformsToProtocol:@protocol(FileDownloadDelegate)]);
	assert(_url != nil);
	assert(_thread != [NSThread mainThread]);
	
	//-------------------------------------------------------------------------
	// If the file has already completed downloading, simply return it
	//-------------------------------------------------------------------------
	if(_state == kFileDownloadStateComplete) {
		[_delegate FileDownloadCompleted:self data:_receivedData];
	}
	//-------------------------------------------------------------------------
	// This method supports predownloading.  If the download has already started
	// simply turn on the streaming.  The delegate will return the beginning
	// of the file
	//-------------------------------------------------------------------------
	else if(_state == kFileDownloadStateDownloading) {
		
		//-------------------------------------------------------------------------
		// If we werent streaming, turn it on
		//-------------------------------------------------------------------------
		if(stream && !_isStreamable){
			_isStreamable = YES;
			_justStarted = YES;
		}
		
	}
	
	//-------------------------------------------------------------------------
	// Start the connection
	//-------------------------------------------------------------------------
	else{
		
		//-------------------------------------------------------------------------
		// Set the stream variable
		//-------------------------------------------------------------------------
		_isStreamable = stream;
		
		//-------------------------------------------------------------------------
		// If we are scrubbing or resuming a paused download, we need to create
		// a fragmented packet
		//-------------------------------------------------------------------------
		if((_state == kFileDownloadStateIdle && _withOffset>0) || (_state == kFileDownloadStatePaused)) {
			
			//-------------------------------------------------------------------------
			// Create the request
			//-------------------------------------------------------------------------
			_request = [[NSMutableURLRequest requestWithURL:_url
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:60.0] retain];
			
			//assert([_receivedData length] != _transferFileSize);
			assert(_request != nil);
			
			//-------------------------------------------------------------------------
			// Create the range variable
			//-------------------------------------------------------------------------
			[_request setHTTPMethod:@"GET"];
			[_request setValue:@"keep-live" forHTTPHeaderField:@"Connection"];
			[_request setValue:@"300" forHTTPHeaderField:@"Keep-Alive"];
			
			///-------------------------------------------------------------------------
			// Form the range value depending if we are resuming or getting a fragment
			//-------------------------------------------------------------------------
			NSString * strRange;
			if(_state == kFileDownloadStatePaused)
				strRange = [NSString stringWithFormat:@"bytes=%lu-",(unsigned long)[_receivedData length]];
			else
				strRange = [NSString stringWithFormat:@"bytes=%lld-",_withOffset];
			
			[_request setValue:strRange forHTTPHeaderField:@"Range"];
			
			NSDebug(@"FD: %d Download Fragment URL: %@",self,[_url absoluteString]);
			
		}
		
		//-------------------------------------------------------------------------
		// If we were idle and here, it is the start of a normal download, create
		// that request
		//-------------------------------------------------------------------------
		else if(_state == kFileDownloadStateIdle) {
			_request = [[NSMutableURLRequest requestWithURL:_url
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:60.0] retain];
			NSDebug(@"FD: %d Download Began URL: %@",self,[_url absoluteString]);
			
		}
		//-------------------------------------------------------------------------
		// If here, unknown state.  Cancel the download and trigger an error
		//-------------------------------------------------------------------------
		else {
			[self cancelDownloadInternal:nil];
			if(error) *error = [NSError errorWithDomain:FileDownloadErrorDomain code:DLError4 userInfo:nil];
			return;
		}
		
		//-------------------------------------------------------------------------
		// See if the connection can handle the request.  If not, exit
		//-------------------------------------------------------------------------
		if(![NSURLConnection canHandleRequest:_request]){
			if(error) *error = [NSError errorWithDomain:FileDownloadErrorDomain code:DLError5 userInfo:nil];
			return;
		}
		
		//-------------------------------------------------------------------------
		// If the is Stremable was set, set the just started which will send what
		// has already been downloaded as the stream start
		//-------------------------------------------------------------------------
		if(_isStreamable){
			_justStarted = YES;
		}
		
		//-------------------------------------------------------------------------
		// Start the connection
		//-------------------------------------------------------------------------
		[self startConnection];
		
	}
	
	if(error) *error = nil;
	
}


//-------------------------------------------------------------------------
// This method start the connection
//-------------------------------------------------------------------------
- (void)startConnection {
	
	assert(_request != nil);
	assert(_runLoop);
	assert(_thread);
	
	//-------------------------------------------------------------------------
	// Create the connection but dont start it
	//-------------------------------------------------------------------------
	_connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
	
	//-------------------------------------------------------------------------
	// Check if the connection was created
	//-------------------------------------------------------------------------
	if (_connection) {
		
		//-------------------------------------------------------------------------
		// Schedule the connection to run on the background thread
		//-------------------------------------------------------------------------
		[_connection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:TheFilterFileRunLoopMode];
		[_connection scheduleInRunLoop:_runLoop forMode:TheFilterFileRunLoopMode];
		
		
		//-------------------------------------------------------------------------
		// Start the connection
		//-------------------------------------------------------------------------
		
		[_connection start];
		
		//-------------------------------------------------------------------------
		// Set the network indicator
		//-------------------------------------------------------------------------
		[NetworkActive networkActiveConnection:YES];
		
		//-------------------------------------------------------------------------
		// Create the new receive buffer if we are not coming back from a resumed
		// state
		//-------------------------------------------------------------------------
		if(_state != kFileDownloadStatePaused)
			_receivedData = [[NSMutableData data] retain];
		
		//-------------------------------------------------------------------------
		// Change the state to downloading
		//-------------------------------------------------------------------------
		_state = kFileDownloadStateDownloading;
		
		
		
		
		
	} 
	//-------------------------------------------------------------------------
	// The connection was not created,  Error accordingly
	//-------------------------------------------------------------------------
	else {
		NSError * _error = [NSError errorWithDomain:FileDownloadErrorDomain code:DLError1 userInfo:nil];
		[_delegate FileDownloadFailed:self error:_error];
		_state = kFileDownloadStateError;
	}	
	
}

- (void)cancelDownloadInternal:(NSError **)error {
    //-------------------------------------------------------------------------
    // Change the state to cancelled
    //-------------------------------------------------------------------------
    _state = kFileDownloadStateCancelled;
    
    //-------------------------------------------------------------------------
    // Kill the connection
    //-------------------------------------------------------------------------
    [_connection cancel];
    [_connection unscheduleFromRunLoop:_runLoop forMode:TheFilterFileRunLoopMode];
    
    //-------------------------------------------------------------------------
    // Cleanup
    //-------------------------------------------------------------------------
    [_connection release];
    _connection = nil;
    
    [_request release];
    _request = nil;
    
    [_receivedData release];
    _receivedData = [[NSMutableData data] retain];
    
    //-------------------------------------------------------------------------
    // Stop the indicator
    //-------------------------------------------------------------------------
    [NetworkActive networkActiveConnection:NO];
    
    NSDebug(@"FD: %d Download Cancelled URL: %@",self,[_url absoluteString]);
}

@end

@implementation FileDownload

@synthesize state = _state;
@synthesize url = _url;
@synthesize credentials = _credentials;
@synthesize delegate = _delegate;

- (id)init {
	if(!(self == [super init])) {return nil;}
	
	// Initialize attributes
	_state = kFileDownloadStateIdle;
	_url = nil;
	_connection = nil;
	_credentials = nil;
	_transferFileSize = -1;  // Signals un-initialized value
	_isStreamable = NO;
	_justStarted = NO;
	_withOffset = 0;
	_mutexData = [[NSLock alloc] init];
	_mutexConnection = [[NSLock alloc] init];
	_mutexState = [[NSLock alloc] init];
	_retryCount = 0;
	
	
	return self;
}

- (void)dealloc {
	[self cancelDownload:nil];
	[_url release];
	[_credentials release];
	[_receivedData release];
	[_connection release];
	[_request release];
	[_mutexConnection release];
	[_mutexData release];
	[_mutexState release];
	[super dealloc];
}

- (id)initWithURL:(NSURL *)url {
	if(!(self == [self init])) {return nil;}
	
	// Initialize url
	self.url = url;
	
	return self;
}

//-------------------------------------------------------------------------
// This will start a paused download back up
//-------------------------------------------------------------------------
- (void)resumeDownloadWithStream:(BOOL)stream error:(NSError **)error {
	
	NSError *__error = nil;
	
	[_mutexConnection lock];
	[_mutexData lock];
	[_mutexState lock];
	
	//-------------------------------------------------------------------------
	// If idle, trigger error since we cant resume from idle
	//-------------------------------------------------------------------------
	if(_state == kFileDownloadStateIdle){
		if(error) *error = [NSError errorWithDomain:FileDownloadErrorDomain code:DLError2 userInfo:nil];
		goto ErrorExit;
	}
	
	//-------------------------------------------------------------------------
	// Begin the download with the stream setting
	//-------------------------------------------------------------------------
	[self beginDownloadWithStreamInternal:stream error:&__error];
	

ErrorExit:
	
	[_mutexConnection unlock];
	[_mutexData unlock];
	[_mutexState unlock];
	
	if(error) *error =__error = nil;
	
}

//-------------------------------------------------------------------------
// This will start an errored download from where it left off
//-------------------------------------------------------------------------
- (void)resumeDownloadFromError:(NSError **)error {
	
	//-------------------------------------------------------------------------
	// Check the retry count
	//-------------------------------------------------------------------------
	_retryCount++;
	if(_retryCount >= 20){
		if(error) *error = [NSError errorWithDomain:FileDownloadErrorDomain code:DLError9 userInfo:nil];
		goto ErrorExit;
	}
	
	//-------------------------------------------------------------------------
	// If not error, trigger error since we cant resume from any other state
	//-------------------------------------------------------------------------
    /*
	if(_state != kFileDownloadStateError){
		if(error) *error = [NSError errorWithDomain:FileDownloadErrorDomain code:DLError8 userInfo:nil];
		goto ErrorExit;
	}
	*/
	NSError *__error = nil;
	
	//-------------------------------------------------------------------------
	// Resume the download with the last error example
	//-------------------------------------------------------------------------
	[self resumeDownloadWithStream:_isStreamable error:&__error];
	
ErrorExit:
	
	if(error) *error =__error = nil;
	
}

//-------------------------------------------------------------------------
// This begins a fragment download
//-------------------------------------------------------------------------
- (void)beginDownloadWithFragmentOffset:(SInt64)offset error:(NSError **)error {
	
	assert(offset>=0);
	
	NSError *__error = nil;
	
	[_mutexConnection lock];
	[_mutexData lock];
	[_mutexState lock];
	
	//-------------------------------------------------------------------------
	// If the file is downloading and we have the offset,  and this is not a
	// fragment send the block and let the download continue. Ensure streaming
	// is enabled so the data keeps coming
	//-------------------------------------------------------------------------
	if(_state == kFileDownloadStateDownloading && [_receivedData length]>offset &&
	   ![self isDownloadFragment]) {
		
		NSRange range;
		range.location = offset;
		range.length = [_receivedData length]-offset;
		
		if([_delegate respondsToSelector:@selector(FileDownloadStreamStarted: newData: offset: size:)])
			[_delegate FileDownloadStreamStarted:self 
										 newData:[_receivedData subdataWithRange:range] 
										  offset:offset 
											size:_transferFileSize-offset];
		
		_isStreamable = YES;
	}
	//-------------------------------------------------------------------------
	// Else this is a new download for a fragment.  Start it
	//-------------------------------------------------------------------------
	else {
		_withOffset = offset;
		[self beginDownloadWithStreamInternal:YES error:&__error];
	}
	
	[_mutexConnection unlock];
	[_mutexState unlock];
	[_mutexData unlock];
		
	if(error) *error =__error = nil;
	
}

- (void)beginDownloadWithStream:(BOOL)stream error:(NSError **)error {
	
	[_mutexConnection lock];
	[_mutexData lock];
	[_mutexState lock];
	
	//-------------------------------------------------------------------------
	// Begin the new download
	//-------------------------------------------------------------------------
	[self beginDownloadWithStreamInternal:stream error:error];
	
	[_mutexConnection unlock];
	[_mutexState unlock];
	[_mutexData unlock];
	
	

}


//-------------------------------------------------------------------------
// Cancel the streaming if the download is not already complete
//-------------------------------------------------------------------------
- (void)cancelStreaming:(NSError **)error {
	if(_state != kFileDownloadStateComplete) {
		[_mutexConnection lock];
		_isStreamable = NO;
		[_mutexConnection unlock];
		NSDebug(@"FD : %d Streaming Cancelled URL: %@",self,[_url absoluteString]);
	}

	if(error) *error = nil;
}

//-------------------------------------------------------------------------
// Start the streaming if the download is not already complete
//-------------------------------------------------------------------------
- (void)startStreaming:(NSError **)error {
	if(_state != kFileDownloadStateComplete) {
		[_mutexConnection lock];
		_justStarted = YES;
		_isStreamable = YES;
		[_mutexConnection unlock];
		NSDebug(@"FD : %d Streaming Started URL: %@",self,[_url absoluteString]);
	}
	
	if(error) *error = nil;
}

//-------------------------------------------------------------------------
// This method cancels the download
//-------------------------------------------------------------------------
- (void)cancelDownload:(NSError **)error {
	
	[_mutexConnection lock];
	[_mutexData lock];
	[_mutexState lock];
	
	//-------------------------------------------------------------------------
	// Only cancel if we have not done it already
	//-------------------------------------------------------------------------
	if(_connection){
	
		[self cancelDownloadInternal:error];
		
	}
	
	[_mutexConnection unlock];
	[_mutexData unlock];
	[_mutexState unlock];
	
	if(error) *error = nil;
}

//-------------------------------------------------------------------------
// This method will pause the connection by cancelling it
//-------------------------------------------------------------------------
- (void)pauseDownload:(NSError **)error {
	
	NSError *__error = nil;
	
	//-------------------------------------------------------------------------
	// If it is already paused, dont do anything
	//-------------------------------------------------------------------------
	if(_state == kFileDownloadStatePaused){
		return;
	}
	
	//-------------------------------------------------------------------------
	// Stop the download by cancelling it
	//-------------------------------------------------------------------------
	[self cancelDownload:&__error];
	
	//-------------------------------------------------------------------------
	// Set the state to paused
	//-------------------------------------------------------------------------
	[_mutexState lock];
	_state = kFileDownloadStatePaused;
	[_mutexState unlock];
	
	NSDebug(@"FD: %d Download Paused URL: %@",self,[_url absoluteString]);
	
	if(error) *error =__error = nil;
	
}

//-------------------------------------------------------------------------
// Returns a flag signalling if the download is a fragment or the entire thing
//-------------------------------------------------------------------------
- (BOOL)isDownloadFragment {
	return (_withOffset>0)?YES:NO;
}

//-------------------------------------------------------------------------
// Returns the state of the download
//-------------------------------------------------------------------------
- (FileDownloadStates)downloadState {
	return _state;
}

//-------------------------------------------------------------------------
// Returns a bool signalling if the download is streaming
//-------------------------------------------------------------------------
- (BOOL)isStreaming {
	return _isStreamable;
}

//-------------------------------------------------------------------------
// Return the data
//-------------------------------------------------------------------------
- (NSData *)receivedData {
	[_mutexData lock];
	NSData * data = [[_receivedData copy] autorelease];
	[_mutexData unlock];
	return data;
	
}

//-------------------------------------------------------------------------
// Return the length
//-------------------------------------------------------------------------
- (NSInteger)receivedDataLength {
	[_mutexData lock];
	NSInteger length = [_receivedData length];
	[_mutexData unlock];
	return length;
}

//-------------------------------------------------------------------------
// Return the expected size of the file
//-------------------------------------------------------------------------
- (float)fileSize {
	return _transferFileSize;
}
//-------------------------------------------------------------------------
// Connection delegate
//-------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	assert(![NSThread isMainThread]);
	
	[_mutexConnection lock];
	
	//-------------------------------------------------------------------------
	// If the size of the response is negative 1, something went seriously
	// wrong.  Trigger an error
	//-------------------------------------------------------------------------
	NSInteger number = [response expectedContentLength];
	if(number<0){
		NSError * _error = [NSError errorWithDomain:FileDownloadErrorDomain code:DLError6 userInfo:nil];
		[_delegate FileDownloadFailed:self error:_error];
	}
	
	//-------------------------------------------------------------------------
	// Set the file size if it hasent been set yet
	//-------------------------------------------------------------------------
	else if(_transferFileSize < 0) {
		_transferFileSize = number;
	}
	
	[_mutexConnection unlock];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	
	assert(![NSThread isMainThread]);
	
	[_mutexConnection lock];
	[_mutexData lock];
	
	//-------------------------------------------------------------------------
	// Reset the retry count since this was successful
	//-------------------------------------------------------------------------
	_retryCount = 0;
	
	//-------------------------------------------------------------------------
	// Set the length and append the data
	//-------------------------------------------------------------------------
	NSInteger oldLength = [_receivedData length];
	[_receivedData appendData:data];
	
	//-------------------------------------------------------------------------
	// If streaming, send the data
	//-------------------------------------------------------------------------
	if(_isStreamable){
		
		//-------------------------------------------------------------------------
		// If just started, send everything we have downloaded so far
		//-------------------------------------------------------------------------
		if(_justStarted) {
			if([_delegate respondsToSelector:@selector(FileDownloadStreamStarted: newData: offset: size:)])
				[_delegate FileDownloadStreamStarted:self 
											 newData:_receivedData 
											  offset:_withOffset 
												size:_transferFileSize];
			_justStarted = NO;
		}
		//-------------------------------------------------------------------------
		// Else only send what we have received
		//-------------------------------------------------------------------------
		else {
			if([_delegate respondsToSelector:@selector(FileDownloadStreamUpdated: newData: offset: size:)])
				[_delegate FileDownloadStreamUpdated:self 
											 newData:data 
											  offset:_withOffset+oldLength
												size:_transferFileSize];
		}
	}
	
	//-------------------------------------------------------------------------
	// Send the progress up to the delegate
	//-------------------------------------------------------------------------
		if([_delegate respondsToSelector:@selector(FileDownloadProgress: byteCount: totalBytes:)])
			[_delegate FileDownloadProgress:self 
								  byteCount:[_receivedData length]
								 totalBytes:_transferFileSize];
	
	[_mutexConnection unlock];
	[_mutexData unlock];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	assert(![NSThread isMainThread]);
	//assert([_receivedData length] == _transferFileSize);
	
	NSDebug(@"FD: %d Download Completed URL: %@",self,[_url absoluteString]);
	
	[_mutexConnection lock];
	[_mutexData lock];
	[_mutexState lock];
	
	if(_connection){
		
		//-------------------------------------------------------------------------
		// Set the state to complete
		//-------------------------------------------------------------------------
		_state = kFileDownloadStateComplete;
		
		//-------------------------------------------------------------------------
		// Send the file over
		//-------------------------------------------------------------------------
		[_delegate FileDownloadCompleted:self data:_receivedData];
		
		//-------------------------------------------------------------------------
		// Cleanup the connection
		//-------------------------------------------------------------------------
		[_connection cancel];
		[_connection release];
		_connection = nil;
		
		//-------------------------------------------------------------------------
		// Clear the network indicator
		//-------------------------------------------------------------------------
		[NetworkActive networkActiveConnection:NO];
		
	}
	
	[_mutexConnection unlock];
	[_mutexData unlock];
	[_mutexState unlock];
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	assert(![NSThread isMainThread]);
	
	NSDebug(@"FD: %d Download Failed URL: %@",self,[_url absoluteString]);
	
	[_mutexState lock];
	
	//-------------------------------------------------------------------------
	// Change the state to error
	//-------------------------------------------------------------------------
	_state = kFileDownloadStateError;
	
	[_mutexState unlock];
	
	//-------------------------------------------------------------------------
	// Cleanup the connection
	//-------------------------------------------------------------------------
	[_connection cancel];
	[_connection release];
	_connection = nil;
	
	//-------------------------------------------------------------------------
	// Send a message to the delegate
	//-------------------------------------------------------------------------
	[_delegate FileDownloadFailed:self error:error];
	
	//-------------------------------------------------------------------------
	// Clear the network indicator
	//-------------------------------------------------------------------------
	[NetworkActive networkActiveConnection:NO];

}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0) {
	
	assert(![NSThread isMainThread]);
	
	if(_credentials) return YES;
	return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
	
	assert(![NSThread isMainThread]);
	
	[[challenge sender] useCredential:_credentials forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
	assert(![NSThread isMainThread]);
	
	[_mutexConnection lock];
	[_mutexState lock];
	
	//-------------------------------------------------------------------------
	// Change the state to error
	//-------------------------------------------------------------------------
	_state = kFileDownloadStateError;
	
	//-------------------------------------------------------------------------
	// Send the error up
	//-------------------------------------------------------------------------
	NSError * _error = [NSError errorWithDomain:FileDownloadErrorDomain code:DLError7 userInfo:nil];
	[_delegate FileDownloadFailed:self error:_error];
	
	[_mutexConnection unlock];
	[_mutexState unlock];

}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0){
	assert(![NSThread isMainThread]);
	
	return NO;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	assert(![NSThread isMainThread]);
	
	return cachedResponse;
}



@end
