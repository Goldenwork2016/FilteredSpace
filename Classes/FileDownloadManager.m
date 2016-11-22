//
//  FileDownloadManager.m
//  TheFilter
//
//  Created by Eric Chapman on 12/26/09.
//

#import "FileDownloadManager.h"
#import "Reachability.h"

@interface FileDownloadManager (private)

- (void) handleReachabilityChange:(id)sender;

@end

@implementation FileDownloadManager (private)

- (void) handleReachabilityChange:(id)sender {/*
    Reachability * reachability = [Reachability sharedReachability];
    if ([reachability internetConnectionStatus] == NotReachable) {
        //-------------------------------------------------------------------------
        // The network connection connection went away, lets pause any active downloads
        //-------------------------------------------------------------------------
        for (FileDownload * downloadObject in [_activeDownloads allValues]) {
            [downloadObject pauseDownload:nil];
        }
        
        for (FileDownload * downloadObject in [_activeFragments allValues]) {
            [downloadObject pauseDownload:nil];
        }
    }
    else {
        //-------------------------------------------------------------------------
        // The network connection connection came back, so lets resume anything we 
        // had paused
        //-------------------------------------------------------------------------
        for (FileDownload * downloadObject in [_activeDownloads allValues]) {
            [downloadObject resumeDownloadFromError:nil];
        }
        
        for (FileDownload * downloadObject in [_activeFragments allValues]) {
            [downloadObject resumeDownloadFromError:nil];
        }
	} */   
}

@end


@implementation FileDownloadManager
@synthesize delegate = _delegate;
@synthesize credentials = _credentials;

- (id)init {
	if(!(self == [super init])) {return nil;}
	
	//-------------------------------------------------------------------------
	// Create the download queues
	//-------------------------------------------------------------------------
	_activeDownloads = [[NSMutableDictionary alloc] init];
	_activeFragments = [[NSMutableDictionary alloc] init];
	_credentials = nil;
	_delegate = nil;
	_canDownloadWhileFragmentIsDownloading = YES;

    //-------------------------------------------------------------------------
	// Listen to the notification for the network status to change
	//-------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReachabilityChange:) name:@"kNetworkReachabilityChangedNotification" object:nil];
	
	//-------------------------------------------------------------------------
	// Start the network thread
	//-------------------------------------------------------------------------
	[FileDownload createNetworkThread];
	
	return self;
}

- (void)dealloc {
    //-------------------------------------------------------------------------
	// Remove our listeners
	//-------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	//-------------------------------------------------------------------------
	// Kill the network thread
	//-------------------------------------------------------------------------
	[FileDownload releaseNetworkThread];
	
	[_activeDownloads release];
	[_activeFragments release];
	[_credentials release];
	[super dealloc];
}



- (void)retrieveFileFromURL:(NSString *)url canStream:(BOOL)canStream error:(NSError **)error {
	
	NSError * __error = nil;
	//NSLog(@"URL: %@", url);
	//-------------------------------------------------------------------------
	// If the file is already in the download bucket, we will try to use it
	//-------------------------------------------------------------------------
	if([_activeDownloads objectForKey:url]) {
		
		id<FileDownloadProtocol> object = [_activeDownloads objectForKey:url];
		
		//-------------------------------------------------------------------------
		// If it isnt a fragment, see if it has the data we need
		//-------------------------------------------------------------------------
		if(![object isDownloadFragment]) {
			
			//-------------------------------------------------------------------------
			// The file is downloading, start it streaming
			//-------------------------------------------------------------------------
			if([object downloadState] == kFileDownloadStateDownloading) {
				//NSLog(@"willfailhere");
				
				[object beginDownloadWithStream:canStream error:&__error];  				
				
				if(error) *error=__error;
				return;
			}
			
			//-------------------------------------------------------------------------
			// If the file is complete, pass it to the audio driver accordingly
			//-------------------------------------------------------------------------
			else if([object downloadState] == kFileDownloadStateComplete) {
			
				// Return the filet
				[_delegate FileCacheManagerStreamStart:url 
												  data:[object receivedData]
												  size:[[object receivedData] length]
												offset:0];
				[_delegate FileCacheManagerStreamEnd:url];
			}
			
			//-------------------------------------------------------------------------
			// Unknown state.  Stop the download and throw it away to get back to a
			// known state
			//-------------------------------------------------------------------------
			else {
				[object cancelDownload:nil];
				[_activeDownloads removeObjectForKey:url];
				if(error) *error = [NSError errorWithDomain:FileDownloadManagerErrorDomain code:DLMError4 userInfo:nil];
				return;
			}
		}
		else {
			assert(0);
		}
	
	}
	
	//-------------------------------------------------------------------------
	// There is no file in the queue, need to start one
	//-------------------------------------------------------------------------
	else {

		//-------------------------------------------------------------------------
		// Create the download ovject
		//-------------------------------------------------------------------------
		FileDownload * file = [[FileDownload alloc] initWithURL:[NSURL URLWithString:url]];
		file.delegate = self;
		file.credentials = _credentials;
		
		//-------------------------------------------------------------------------
		// Start the download
		//-------------------------------------------------------------------------
		[file beginDownloadWithStream:canStream error:&__error];
		
		
		
		//-------------------------------------------------------------------------
		// If it was successful, add it to the queue
		//-------------------------------------------------------------------------
		if(!__error)
			[_activeDownloads setObject:file forKey:url];
		
		[file release];
		
	}
	
	if(error) *error=__error;
}

- (void)retrieveFileOffsetFromURL:(NSString *)url offset:(SInt64)offset error:(NSError **)error {
	
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// See if the file is already downloading
	//-------------------------------------------------------------------------
	if([_activeDownloads objectForKey:url]) {
		
		id<FileDownloadProtocol> object = [_activeDownloads objectForKey:url];
		
		assert(![object isDownloadFragment]);
		
		//-------------------------------------------------------------------------
		// If it is complete, get the fragment and send it accordingly
		//-------------------------------------------------------------------------
		if([object downloadState] == kFileDownloadStateComplete) {
			
			//-------------------------------------------------------------------------
			// Set the range
			//-------------------------------------------------------------------------
			NSRange range;
			range.length = [[object receivedData] length] - offset;
			range.location = offset;
			
			//-------------------------------------------------------------------------
			// Send the fragment
			//-------------------------------------------------------------------------
			[_delegate FileCacheManagerStreamStart:url 
											  data:[[object receivedData] subdataWithRange:range]
											  size:[object fileSize]
											offset:offset];
			[_delegate FileCacheManagerStreamEnd:url];
			
		}
		
		//-------------------------------------------------------------------------
		// If it is downloading and has the data, take it
		//-------------------------------------------------------------------------
		else if([object downloadState] == kFileDownloadStateDownloading && [object receivedDataLength]>offset) {
			
			assert(![object isStreaming]);
			
			//-------------------------------------------------------------------------
			// Send the fragment by doing a begin with offset
			//-------------------------------------------------------------------------
			[object beginDownloadWithFragmentOffset:offset error:&__error];
											
		}
		
		//-------------------------------------------------------------------------
		// Else we dont have enough of the file, we need to start a fragment
		//-------------------------------------------------------------------------
		else {
			
			//-------------------------------------------------------------------------
			// If I cant have a download going while a fragment is going, pause itˆ
			//-------------------------------------------------------------------------
			if(!_canDownloadWhileFragmentIsDownloading)
				[[_activeDownloads objectForKey:url] pauseDownload:&__error];
			
			//-------------------------------------------------------------------------
			// Throw the current fragment out, we dont need it anymore
			//-------------------------------------------------------------------------
			if([_activeFragments objectForKey:url]){
				[[_activeFragments objectForKey:url] cancelDownload:&__error];
				[_activeFragments removeObjectForKey:url];
			}
			
			//-------------------------------------------------------------------------
			// Create a new download and start it
			//-------------------------------------------------------------------------
			FileDownload * file = [[FileDownload alloc] initWithURL:[NSURL URLWithString:url]];
			file.delegate = self;
			file.credentials = _credentials;
			[file beginDownloadWithFragmentOffset:offset error:&__error];
			
			//-------------------------------------------------------------------------
			// If it was successful, add it to the queue
			//-------------------------------------------------------------------------
			if(!__error)
				[_activeFragments setObject:file forKey:url];
			
			[file release];
		
		}
		
	}
	
	//-------------------------------------------------------------------------
	// The main file was never started so this is an error.  We shouldnt
	// be going after a fragment if we never started main
	//-------------------------------------------------------------------------
	else {
		if(error) *error = [NSError errorWithDomain:FileDownloadManagerErrorDomain code:DLMError2 userInfo:nil];
	}
	
	if(error) *error=__error;
	
}

//-------------------------------------------------------------------------
// This continues downloading but stops streaming
//-------------------------------------------------------------------------
- (void)stopStreamingFileFromURL:(NSString *)url error:(NSError **)error {
	
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// If we had a fragment going, get rid of it and resume the download
	//-------------------------------------------------------------------------
	if([_activeFragments objectForKey:url]) {
		
		//-------------------------------------------------------------------------
		// Cancel the fragment download
		//-------------------------------------------------------------------------
		[[_activeFragments objectForKey:url] cancelDownload:&__error];
		[_activeFragments removeObjectForKey:url];
		
		//-------------------------------------------------------------------------
		// Resume the main if it was paused
		//-------------------------------------------------------------------------
		assert([_activeDownloads objectForKey:url]);
		if([[_activeDownloads objectForKey:url] downloadState] != kFileDownloadStateComplete &&
		   !_canDownloadWhileFragmentIsDownloading) {
			[[_activeDownloads objectForKey:url] resumeDownloadWithStream:NO error:&__error];
		}
	}
	//-------------------------------------------------------------------------
	// Nothing in the fragment queue, just stop streaming the download
	//-------------------------------------------------------------------------
	else if([_activeDownloads objectForKey:url]) {
		[[_activeDownloads objectForKey:url] cancelStreaming:&__error];
	}
	
	if(error) *error=__error;
}

//-------------------------------------------------------------------------
// This will actually remove the download rather than keep it going in
// the background
//-------------------------------------------------------------------------
- (void)removeFileFromURL:(NSString *)url error:(NSError **)error {
	
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// If it is downloading, stop it and remove it
	//-------------------------------------------------------------------------
	if([_activeDownloads objectForKey:url]) {
		[[_activeDownloads objectForKey:url] cancelDownload:&__error];
		[_activeDownloads removeObjectForKey:url];
	}
	
	//-------------------------------------------------------------------------
	// If the fragment is downloading, stop it and retrieve it
	//-------------------------------------------------------------------------
	if([_activeFragments objectForKey:url]) {
		[[_activeFragments objectForKey:url] cancelDownload:&__error];
		[_activeFragments removeObjectForKey:url];
	}
	
	if(error) *error=__error;
}

//-------------------------------------------------------------------------
// This returns an error in this implementation since we are not caching
// songs in this implementation
//-------------------------------------------------------------------------
- (NSString *)getLocalLocationFromURL:(NSString *)url error:(NSError **)error{
	if(error) *error = [NSError errorWithDomain:FileDownloadManagerErrorDomain code:DLMError1 userInfo:nil];
	return nil;
}

////////////////////////////////////////////////////////////////
// File Download Delegates
////////////////////////////////////////////////////////////////
- (void)FileDownloadCompleted:(FileDownload *)fileDownload data:(NSData *)data {
	
	assert(fileDownload.url != nil);
	assert(data != nil);
	assert(_delegate != nil);
	
	NSError * __error = nil;
	
	NSString * url = [fileDownload.url absoluteString];
	
	//-------------------------------------------------------------------------
	// If streaming, send the stream end
	//-------------------------------------------------------------------------
	if([fileDownload isStreaming])
		[_delegate FileCacheManagerStreamEnd:url];
	//-------------------------------------------------------------------------
	// If not streaming, send the entire file up
	//-------------------------------------------------------------------------
	else
		[_delegate FileCacheManagerFile:url data:data];
	
	//-------------------------------------------------------------------------
	// If this was a fragment, remove it and resume the download if we need to
	//-------------------------------------------------------------------------
	if(fileDownload == [_activeFragments objectForKey:url]) {
		
		assert([_activeDownloads objectForKey:url]);
		
		//-------------------------------------------------------------------------
		// Throw away the fragment
		//-------------------------------------------------------------------------
		[_activeFragments removeObjectForKey:url];
		
		//-------------------------------------------------------------------------
		// If the files are being paused during download start it
		//-------------------------------------------------------------------------
		if(!_canDownloadWhileFragmentIsDownloading)
			[[_activeDownloads objectForKey:url] resumeDownloadWithStream:NO error:&__error];
		
		//-------------------------------------------------------------------------
		// Pass the error up if one occured
		//-------------------------------------------------------------------------
		if(__error) [_delegate FileCacheManagerError:[fileDownload.url absoluteString] error:__error];
		
	}
}

- (void)FileDownloadFailed:(FileDownload *)fileDownload error:(NSError *)error{
	
	assert(fileDownload.url != nil);
	assert(_delegate != nil);
	
	NSString * url = [fileDownload.url absoluteString];
	
	NSError * __error = nil;
	
	//-------------------------------------------------------------------------
	// First lets try to resume this download (wait a second to give the
	// network a chance to recover)
	//-------------------------------------------------------------------------
	/*
    [fileDownload resumeDownloadFromError:&__error];
	if (__error == nil) {
		NSLog(@"Download Error: Retrying connection",nil);
		// The download restarted successfully, lets pretend this 
		// never happened
		return;
	}
	*/
    
	//-------------------------------------------------------------------------
	// Pass the error to the delegate
	//-------------------------------------------------------------------------
	[_delegate FileCacheManagerError:url error:error];
	
	//-------------------------------------------------------------------------
	// Kill the download since there was an error
	//-------------------------------------------------------------------------
	[fileDownload cancelDownload:nil];
	
	//-------------------------------------------------------------------------
	// If it was a fragment, remove it and continue the main
	//-------------------------------------------------------------------------
	if(fileDownload == [_activeFragments objectForKey:url]) {
		
		assert([_activeDownloads objectForKey:url]);
		
		//-------------------------------------------------------------------------
		// remove it
		//-------------------------------------------------------------------------
		[_activeFragments removeObjectForKey:url];
		
		//-------------------------------------------------------------------------
		// Resume the download if it was paused
		//-------------------------------------------------------------------------
		if(!_canDownloadWhileFragmentIsDownloading)
			[[_activeDownloads objectForKey:url] resumeDownloadWithStream:NO error:&__error];
		
		//-------------------------------------------------------------------------
		// Pass any error up to the delegate
		//-------------------------------------------------------------------------
		if(__error) [_delegate FileCacheManagerError:[fileDownload.url absoluteString] error:__error];
		
	}
	
	//-------------------------------------------------------------------------
	// Else the error was the main one, remove it
	//-------------------------------------------------------------------------
	else {
		assert([_activeDownloads objectForKey:url]);
		assert(fileDownload == [_activeDownloads objectForKey:url]);
		[_activeDownloads removeObjectForKey:url];
	}
}

- (void)FileDownloadStreamUpdated:(FileDownload *)fileDownload newData:(NSData *)data 
						   offset:(SInt64)offset size:(float)size{
	
	assert(fileDownload.url != nil);
	assert(data != nil);
	assert(_delegate != nil);
	
	NSString * url = [fileDownload.url absoluteString];
	
	assert(url != nil);
	
	//-------------------------------------------------------------------------
	// Pass the data up to the delegate
	//-------------------------------------------------------------------------
	[_delegate FileCacheManagerStreamUpdate:url data:data size:size offset:offset];

}

- (void)FileDownloadStreamStarted:(FileDownload *)fileDownload 
						  newData:(NSData *)data offset:(SInt64)offset size:(float)size {
	
	assert(fileDownload.url != nil);
	assert(data != nil);
	assert(_delegate != nil);
	
	NSString * url = [fileDownload.url absoluteString];
	
	assert(url != nil);
	
	//-------------------------------------------------------------------------
	// Pass the data up to the delegate
	//-------------------------------------------------------------------------
	[_delegate FileCacheManagerStreamStart:url data:data size:size offset:offset];

}

- (void)FileDownloadProgress:(FileDownload *)fileDownload byteCount:(float)byteCount totalBytes:(float)totalBytes {
	
	assert(fileDownload.url != nil);
	assert(_delegate != nil);
	
	NSString * url = [fileDownload.url absoluteString];
	
	assert(url != nil);
	
	//-------------------------------------------------------------------------
	// Pass the data up to the delegate
	//-------------------------------------------------------------------------
	[_delegate FileCacheManagerProgress:url byteCount:byteCount totalBytes:totalBytes];
}


@end

