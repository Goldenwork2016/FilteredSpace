//
//  FileDownload.h
//  Untitled
//
//  Created by Eric Chapman on 12/13/09.
//

#import <Foundation/Foundation.h>
#import "FileDownloadProtocals.h"
#import "FileDownloadErrors.h"
#import "Common.h"

@interface FileDownload : NSObject <FileDownloadProtocol> {
@public
	NSURL * _url;							/** The url of the file being downloaded */
	FileDownloadStates _state;				/** The state of the downloader */
	NSURLCredential * _credentials;			/** The password credentials if they are needed (nil if not) */
	NSMutableData * _receivedData;			/** Buffer for the received data */
	id<FileDownloadDelegate> _delegate;		/** The delegate for the downloader */
@protected
	NSURLConnection * _connection;			/** The connection */
	NSMutableURLRequest * _request;			/** HTML Request for the file */
	float _transferFileSize;				/** Size of the file being downloaded in bytes */
	BOOL _justStarted;						/** Flag signalling this is the first one */
	BOOL _isStreamable;						/** Flag signalling if streaming events should be pushed up */
	SInt64 _withOffset;						/** Flag signalling if this was a fragment */

	//-------------------------------------------------------------------------
	// Mutexes
	//-------------------------------------------------------------------------
	NSLock * _mutexData;					/** Mutex used to change the "isStreaming" property */
	NSLock * _mutexConnection;				/** Mutex used to start and stop connections */
	NSLock * _mutexState;					/** Mutex used to start and stop connections */

	NSAutoreleasePool *pool;
	
	// This forces a download to max out on its attempts
	NSInteger _retryCount;

}

@property (readonly) FileDownloadStates state;
@property (nonatomic,retain) NSURL * url;
@property (nonatomic,retain) NSURLCredential * credentials;
@property (assign) id<FileDownloadDelegate> delegate;

@end

@interface FileDownload(thread)
/**
 * @function createNetworkThread
 * @description Method used to start the network thread.  This should be called by the object
 * in charge of creating and destroying the threads
 */
+ (void)createNetworkThread;
/**
 * @function releaseNetworkThread
 * @description Method used to destroy the network thread.  This should be called by the object
 * in charge of creating and destroying the threads
 */
+ (void)releaseNetworkThread;

+ (void)processFileTimer;


@end


