// Protocols For the file manager objects.

/**
 * Enumeration representing the state of the File Downloader
 */
typedef enum {
	kFileDownloadStateIdle,
	kFileDownloadStateDownloading,
	kFileDownloadStatePaused,
	kFileDownloadStateComplete,
	kFileDownloadStateCancelled,
	kFileDownloadStateError,
} FileDownloadStates;

@class FileDownload;

@protocol FileDownloadDelegate <NSObject>
@required
/**
 * @function FileDownloadCompleted
 * @description This function is called when the file download has completed
 * @input (FileDownload *)fileDownload - the file
 * @input data:(NSData *)data - The data that makes up the file
 */
- (void)FileDownloadCompleted:(FileDownload *)fileDownload data:(NSData *)data;

/**
 * @function FileDownloadFailed
 * @description This method is called when the dowloading of the file failes
 * @input (FileDownload *)fileDownload - the file
 * @input error:(NSError **)error - Error giving reason for cancel
 */
- (void)FileDownloadFailed:(FileDownload *)fileDownload error:(NSError *)error;
@optional
/**
 * @function FileDownloadStreamStarted
 * @description This function is called when a stream has started
 * @input (FileDownload *)fileDownload - the file
 * @input newData:(NSData *)data - The data chunk that was received
 * @input size:(float)size - The size of the total expected data
 */
- (void)FileDownloadStreamStarted:(FileDownload *)fileDownload newData:(NSData *)data 
						   offset:(SInt64)offset size:(float)size;

/**
 * @function: FileDownloadStreamUpdated
 * @description This function is called when more data has been received from the server
 * @input (FileDownload *)fileDownload - the file
 * @input newData:(NSData *)data - The data chunk that was received
 * @input size:(float)size - The size of the total expected data
 */
- (void)FileDownloadStreamUpdated:(FileDownload *)fileDownload newData:(NSData *)data
						   offset:(SInt64)offset size:(float)size;

/**
 * @function FileDownloadProgress
 * @description This function is called when more data has been received from the server
 * @input (FileDownload *)fileDownload - the file
 * @input newData:(NSData *)data - The data chunk that was received
 * @input size:(float)size - The size of the total expected data
 */
- (void)FileDownloadProgress:(FileDownload *)fileDownload byteCount:(float)byteCount totalBytes:(float)totalBytes;


@end

@protocol FileDownloadProtocol

/**
 * @function initWithURL
 * @description An intialization method that takes a intial URL
 */
- (id)initWithURL:(NSURL *)url;

/**
 * @function beginDownloadWithStream
 * @description Starts the download of a file
 * @input (BOOL)stream - stream or wait for entire file
 * @input (NSError **)error - Error object
 */
- (void)beginDownloadWithStream:(BOOL)stream error:(NSError **)error;

/**
 * @function beginDownloadWithFragmentOffset
 * @description Starts the download of a file
 * @input (BOOL)stream - stream or wait for entire file
 * @input (NSError **)error - Error object
 */
- (void)beginDownloadWithFragmentOffset:(SInt64)offset error:(NSError **)error;

/**
 * @function resumeDownloadWithStream
 * @description Resumes the download of a file
 * @input (NSError **)error - Error object
 */
- (void)resumeDownloadWithStream:(BOOL)stream error:(NSError **)error;

/**
 * @function resumeDownloadFromError
 * @description Resumes the download of a file after an error occured
 * @input (NSError **)error - Error object
 */
- (void)resumeDownloadFromError:(NSError **)error;

/**
 * @function startStreaming
 * @description Terminates the streaming of a file.  It does not however effect 
 * the download
 * @input (NSError **)error - Error object
 */
- (void)startStreaming:(NSError **)error;

/**
 * @function cancelStreaming
 * @description Terminates the streaming of a file.  It does not however effect 
 * the download
 * @input (NSError **)error - Error object
 */
- (void)cancelStreaming:(NSError **)error;

/**
 * @function cancelDownload
 * @description Terminates the download of a file
 * @input (NSError **)error - Error object
 */
- (void)cancelDownload:(NSError **)error;

/**
 * @function pauseDownload
 * @description Pauses the download of a file
 * @input (NSError **)error - Error object
 */
- (void)pauseDownload:(NSError **)error;

/**
 * @function isDownloadFragment
 * @description Tells if this was the entire file or a fragment
 * @return signalling if this was a fragment
 */
- (BOOL)isDownloadFragment;

/**
 * @function downloadState
 * @description Returns the state of the downloading file
 * @return signalling if this was a fragment
 */
- (FileDownloadStates)downloadState;

/**
 * @function isStreaming
 * @description Returns the state of the streaming
 * @return YES if the song was streaming
 */
- (BOOL)isStreaming;

/**
 * @function receivedData
 * @description Returns the received data
 * @return YES if the song was streaming
 */
- (NSData *)receivedData;

/**
 * @function receivedDataLength
 * @description Returns the received data
 * @return YES if the song was streaming
 */
- (NSInteger)receivedDataLength;

- (float)fileSize;

@end


@protocol FileManagerProtocol

/**
 * @function retrieveFileFromURL
 * @description This method requests a file from a url.  The file is returned via the
 * delegate methods
 * @input (NSURL *)url - the url of the file
 * @input canStream:(BOOL)stream - boolean signalling if the file can be streamed
 * or must be completely downloaded first
 * @input error:(NSError **)error - error handle
 */
- (void)retrieveFileFromURL:(NSString *)url canStream:(BOOL)canStream error:(NSError **)error;

/**
 * @function retrieveFileOffsetFromURL
 * @description This method requests a file from a url.  The file is returned via the
 * delegate methods
 * @input (NSURL *)url - the url of the file
 * @input offset:(SInt64)offset
 * or must be completely downloaded first
 * @input error:(NSError **)error - error handle
 */
- (void)retrieveFileOffsetFromURL:(NSString *)url offset:(SInt64)offset error:(NSError **)error;

/**
 * @function stopStreamingFileFromURL
 * @description Method to stop events from propagating up on a url
 * @input (NSURL *)url - the url of the file
 * @input error:(NSError **)error - error handle
 */
- (void)stopStreamingFileFromURL:(NSString *)url error:(NSError **)error;

/**
 * @function removeFileFromURL
 * @description Method lets the file manager know that the file is not longer needed
 * @input (NSURL *)url - the url of the file
 * @input error:(NSError **)error - error handle
 */
- (void)removeFileFromURL:(NSString *)url error:(NSError **)error;

/**
 * @function getLocalLocationFromURL
 * @description Method to get the local file name if necessary
 * @input (NSURL *)url - the url of the file
 * @input error:(NSError **)error - error handle
 * @return (NSString *) The local path to the file
 */
- (NSString *)getLocalLocationFromURL:(NSString *)url error:(NSError **)error;

@end

@protocol FileManagerDelegate <NSObject>
@required
/**
 * @function FileCacheManagerFile
 * @description Method that delivers the complete file from Cache
 * @input (NSString *)url - the url for the file being downloaded
 * @input (NSData *)data - the file as an NSData
 */
- (void) FileCacheManagerFile:(NSString *)url data:(NSData *)data;

/**
 * @function FileCacheManagerStreamStart
 * @description Method that delivers the first chunk of the file
 * @input (NSString *)url - the url for the file being downloaded
 * @input (NSData *)data - first chunk of data
 * @input (float)size - total size of the expected data
 */
- (void) FileCacheManagerStreamStart:(NSString *)url data:(NSData *)data size:(float)size offset:(SInt64)offset;

/**
 * @function FileCacheManagerStreamUpdate
 * @description Method that delivers update chunks of the file
 * @input (NSString *)url - the url for the file being downloaded
 * @input (NSData *)data - a chunk of data
 */
- (void) FileCacheManagerStreamUpdate:(NSString *)url data:(NSData *)data size:(float)size offset:(SInt64)offset;

/**
 * @function FileCacheManagerStreamEnd
 * @description Method that signals the file is done downloading
 * @input (NSString *)url - the url for the file being downloaded
 */
- (void) FileCacheManagerStreamEnd:(NSString *)url;

/**
 * @function FileCacheManagerError
 * @description Method that signals an error in retrieving the file
 * @input (NSString *)url - the url for the file being downloaded
 */
- (void) FileCacheManagerError:(NSString *)url error:(NSError *)error;

/**
 * @function FileCacheManagerError
 * @description Method that signals an error in retrieving the file
 * @input (NSString *)url - the url for the file being downloaded
 */
- (void) FileCacheManagerProgress:(NSString *)url byteCount:(float)byteCount totalBytes:(float)totalBytes;

@end