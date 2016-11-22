//
//  FileCacheManager.m
//  Untitled
//
//  Created by Eric Chapman on 12/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FileCacheManager.h"
#import "FileDownloadProtocals.h"
#import "TheFilterMultimediaManager.h"

// This object is used to hold an object while it is downloading
@implementation DownloadingObject
@synthesize fileDownload = _fileDownload;
@synthesize stream = _stream;
@synthesize inProgress = _inProgress;
- (id)init{
	if(!(self = [super init])){return nil;}
	_fileDownload = nil;
	_stream = NO;
	_inProgress = NO;
	return self;
}
- (void)dealloc{
	[_fileDownload release];
	[super dealloc];
}
@end

// This is used to hold a cached object after it has finished downloading
@implementation CachedObject
@synthesize url = _url;
@synthesize filePath = _filePath;
@synthesize openFile = _openFile;
@synthesize fileNumber = _fileNumber;
- (id)init{
	if(!(self = [super init])){return nil;}
	_filePath = nil;
	_openFile = nil;
	_url = nil;
	return self;
}
- (void)dealloc{
	[_filePath release];
	[_openFile release];
	[_url release];
	[super dealloc];
}
- (void)createLocalFile{
	assert(_openFile != nil);
	
	// Only create the file if it has not been created yet
	if(!_filePath){
		assert(_url != nil);
		
		// Get the path
		NSString * pathDir = [NSTemporaryDirectory() stringByAppendingPathComponent:
							  [NSString stringWithFormat:@"%06d",_fileNumber]];
		
		// Append the extension
		self.filePath = [pathDir stringByAppendingPathExtension:[[_url absoluteString] pathExtension]];
		
		// Write the file
		[_openFile writeToFile:_filePath atomically:NO];
	}
}

- (void)removeLocalFile{
	assert(_filePath != nil);
	
	// Remove the local file
	[[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
}
- (void)loadLocalFile{
	if(_openFile == nil){
		assert(_filePath != nil);
		_openFile = [[NSData alloc] initWithContentsOfFile:_filePath];
	}
}
- (void)unloadLocalFile{
	[_openFile release];
	_openFile = nil;
}
@end

@interface FileCacheManager(hidden)
- (void)clearCachedFiles;
- (void)createCachedFile:(FileDownload *)download error:(NSError **)error;
- (void)resumeNextDownload;
@end

@implementation FileCacheManager(hidden)
- (void)clearCachedFiles {
	
	// Remove the files from the file system
	for (NSString * key in _cachedFiles) {
		[[_cachedFiles objectForKey:key] removeLocalFile];
	}
	
	// Clear the dictionary
	[_cachedFiles release];
	_cachedFiles = [[NSMutableDictionary alloc] init];

}

- (void)createCachedFile:(FileDownload *)download error:(NSError **)error {
	
	// Get the key for the queues
	NSString * url = [download.url absoluteString];
	
	// If we cant cache to the file system, dont do anything and return
	if(!_cacheToFileSystem){
		[_activeDownloads removeObjectForKey:url];
		return;
	}

	assert(download != nil);
	assert(download.state == kFileDownloadStateComplete);
	
	CachedObject * object = [[CachedObject alloc] init];
	object.openFile = download.receivedData;
	object.url = download.url;
	object.fileNumber = _tempFileCounter++;
	
	// Write to file system
	[object createLocalFile];
	
	// Add to queue
	[_cachedFiles setObject:object forKey:url];
	
	// Remove Download object
	[_activeDownloads removeObjectForKey:url];
	
	// Unload the file
	[object unloadLocalFile];
	
	// Cleanup
	[object release];
	
	// Start another download since this is done
	[self resumeNextDownload];
}
- (void)resumeNextDownload {
	// Now perform a download in the background if there are any files left to download
	NSArray * keys = [_activeDownloads allKeys];
	if([keys count] > 0) {
		DownloadingObject * temp = [_activeDownloads objectForKey:[keys objectAtIndex:0]];
		[temp.fileDownload resumeDownloadWithStream:NO error:nil];
	}
}
@end

@implementation FileCacheManager

@synthesize delegate = _delegate;
@synthesize credentials = _credentials;
@synthesize cacheToFileSystem = _cacheToFileSystem;

- (id)init {
	if(!(self == [super init])) {return nil;}
	
	_cachedFiles = [[NSMutableDictionary alloc] init];
	_activeDownloads = [[NSMutableDictionary alloc] init];
	_tempFileCounter = 0;
	_credentials = nil;
	_delegate = nil;
	_cacheToFileSystem = YES;
	
	_scrubbingObject = nil;
	
	// Start the network thread for downloads
	[FileDownload createNetworkThread];
	
	return self;
}

- (void)dealloc {
	// Remove the network thread
	[FileDownload releaseNetworkThread];
	
	[self clearCachedFiles];
	[_cachedFiles release];
	[_activeDownloads release];
	[_scrubbingObject release];
	[_credentials release];
	[super dealloc];
}

- (void)retrieveFileOffsetFromURL:(NSString *)url offset:(SInt64)offset error:(NSError **)error {
	assert(url != nil);
	assert(_delegate != nil);
	assert([_delegate conformsToProtocol:@protocol(FileManagerDelegate)]);
	
	// Ensure it is a valid url
	NSURL * _url = [NSURL URLWithString:url];
	if(_url == nil) {
		// TODO: Set error
		return;
	}
	
	// Check the local cache for the file and return the section if it exists
	if([_cachedFiles objectForKey:url]) {
		CachedObject * tempObject = [_cachedFiles objectForKey:url];
		[tempObject loadLocalFile];
		// Return as stream start
		NSRange range;
		range.location = offset;
		range.length = [tempObject.openFile length]-offset;
		[_delegate FileCacheManagerStreamStart:url 
										  data:[tempObject.openFile subdataWithRange:range] 
										  size:range.length offset:offset];
		[_delegate FileCacheManagerStreamEnd:url];
		[tempObject unloadLocalFile];
		
	}
	
	else { 
		
		// Check if it is already in the download queue.  If it is
		// deactivate it and start the offset one.  This ensures they are both
		// not running at the same time.  When finished, with the scrubbed ones,
		// this song will finish downloading at some point
		if([_activeDownloads objectForKey:url]) {
		
			// Cancel the download
			DownloadingObject * object = [_activeDownloads objectForKey:url];
			[object.fileDownload cancelDownload:nil];
			
		}
		
		// If there is a scrubbing object, stop it and throw it away
		if(_scrubbingObject) {
			[_scrubbingObject cancelDownload:nil];
			[_scrubbingObject release];
			_scrubbingObject = nil;
		}
		
		// Create a new temp one just for this scenario.  The "scrubbingObject" will
		// serve as a flag signalling that a scrubbing one is occuring
		_scrubbingObject = [[FileDownload alloc] initWithURL:[NSURL URLWithString:url]];
		_scrubbingObject.delegate = self;
		_scrubbingObject.credentials = _credentials;
		[_scrubbingObject beginDownloadWithFragmentOffset:offset error:error];
		
	}
	
}

- (void)retrieveFileFromURL:(NSString *)url canStream:(BOOL)canStream error:(NSError **)error {

	assert(url != nil);
	assert(_delegate != nil);
	assert([_delegate conformsToProtocol:@protocol(FileManagerDelegate)]);
	
	// Ensure it is a valid url
	NSURL * _url = [NSURL URLWithString:url];
	if(_url == nil) {
		// TODO: Set error
		return;
	}
	
	// Check the local cache for the file and return that if it exists
	if([_cachedFiles objectForKey:url]) {
		CachedObject * tempObject = [_cachedFiles objectForKey:url];
		[tempObject loadLocalFile];
		[_delegate FileCacheManagerFile:url data:tempObject.openFile];
		[tempObject unloadLocalFile];
	}
	
	// Check if it is already in the download queue.  Activate it
	// if it is.
	else if([_activeDownloads objectForKey:url]) {
		
		// Start the download
		DownloadingObject * object = [_activeDownloads objectForKey:url];
		object.stream = canStream;
		[object.fileDownload beginDownloadWithStream:canStream error:error];
		
	}
	
	// File is not in the cache, begin the download
	else {
		
		// Create downloading object
		DownloadingObject * object = [[DownloadingObject alloc] init];
		
		// Create a new download
		object.fileDownload = [[[FileDownload alloc] initWithURL:_url] autorelease];;
		object.fileDownload.delegate = self;
		object.fileDownload.credentials = _credentials;
		
		// Set the stream flag
		object.stream = canStream;
		
		// Add the object to the Dictionary
		[_activeDownloads setObject:object forKey:url];
		
		// Start the download
		[object.fileDownload beginDownloadWithStream:canStream error:error];
		
	}
}

- (void)stopStreamingFileFromURL:(NSString *)url error:(NSError **)error {
	if(url == nil) return;

	// See if the file is being downlaoded.  If it is done already then dont worry about it
	// since the download events are already complete.  If it is not done, stop the alerts
	// on the download
	if([_activeDownloads objectForKey:url]) {
		
		// Stop the download
		DownloadingObject * object = [_activeDownloads objectForKey:url];
		[object.fileDownload cancelStreaming:error];
		
		if(_cacheToFileSystem){
			// Pause it for now
			[object.fileDownload pauseDownload:error];
		}
		// Done playing, stop downloading since we are not caching
		else{
			[object.fileDownload cancelDownload:error];
			[_activeDownloads removeObjectForKey:url];
		}
	}
		
}

- (void)removeFileFromURL:(NSString *)url error:(NSError **)error {
	// In the caching model, the file will continue downloading if the stream is stopped
	[self stopStreamingFileFromURL:url error:error];
}

- (NSString *)getLocalLocationFromURL:(NSString *)url error:(NSError **)error{
	
	assert(url != nil);
	
	// Return the local string if the file exists
	if([_cachedFiles objectForKey:url]) {
		CachedObject * cachedObject = [_cachedFiles objectForKey:url];
		return cachedObject.filePath;
	}
	else{
		// TODO: Set error
		return nil;
	}
	
}

////////////////////////////////////////////////////////////////
// File Download Delegates
////////////////////////////////////////////////////////////////
- (void)FileDownloadCompleted:(FileDownload *)fileDownload data:(NSData *)data {
	
	assert(fileDownload.url != nil);
	assert(data != nil);
	assert(_delegate != nil);
	
	// If this is the scrubbing one completed, clean it up and start
	// one of the pending downloads
	if(fileDownload == _scrubbingObject){
		// Cleanup the scrubbing object
		[_scrubbingObject cancelDownload:nil];
		[_scrubbingObject release];
		_scrubbingObject = nil;
		
		// Start another download since this is done
		[self resumeNextDownload];
	}
	
	// This is not the scrubbing one, continue normally
	else {
		
		// Get the key for the queues
		NSString * url = [fileDownload.url absoluteString];
		
		// If stream was set to no, need to send the full file now
		if(![[_activeDownloads objectForKey:url] stream])
			[_delegate FileCacheManagerFile:url data:data];
		
		// Else the stream was set to yes, signal the end
		else
			[_delegate FileCacheManagerStreamEnd:url];
		
		// Create cached object
		[self createCachedFile:fileDownload error:nil];
		
	}
	
}
- (void)FileDownloadFailed:(FileDownload *)fileDownload error:(NSError *)error{
	
	assert(fileDownload.url != nil);
	assert(_delegate != nil);
	
	// Pass error up to the delegate
	[_delegate FileCacheManagerError:[fileDownload.url absoluteString] error:error];
	
	// Stop the download
	NSError * _error;
	[fileDownload cancelDownload:&_error];
	
	// Remove it from the queue
	[_activeDownloads removeObjectForKey:[fileDownload.url absoluteString]];
	
	// Start another download since this is done
	[self resumeNextDownload];
	
}
- (void)FileDownloadStreamUpdated:(FileDownload *)fileDownload newData:(NSData *)data 
							  offset:(SInt64)offset size:(float)size{
	
	assert(fileDownload.url != nil);
	assert(data != nil);
	assert(_delegate != nil);
	
	// Get the key for the queues
	NSString * url = [fileDownload.url absoluteString];
	
	assert(url != nil);
	
	// Only give updates if streaming is on
	if([[_activeDownloads objectForKey:url] stream]){
        [_delegate FileCacheManagerStreamUpdate:url data:data size:size offset:offset];
	}
}

- (void)FileDownloadStreamStarted:(FileDownload *)fileDownload 
						  newData:(NSData *)data offset:(SInt64)offset size:(float)size {
	
	assert(fileDownload.url != nil);
	assert(data != nil);
	assert(_delegate != nil);
	
	// Get the key for the queues
	NSString * url = [fileDownload.url absoluteString];
	
	assert(url != nil);
	
	// Only give updates if streaming is on
	if([[_activeDownloads objectForKey:url] stream]){
		DownloadingObject * temp = [_activeDownloads objectForKey:url];
		temp.inProgress = YES;
		[_delegate FileCacheManagerStreamStart:url data:data size:size offset:offset];
	}
}

@end
