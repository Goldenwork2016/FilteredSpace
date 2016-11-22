//
//  FileCacheManager.h
//  Untitled
//
//  Created by Eric Chapman on 12/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownload.h"
#import "FileDownloadProtocals.h"

/**
 * @class DownloadingObject
 * @description Object for storing the songs while downloading
 */
@interface DownloadingObject : NSObject {
@public
	FileDownload * _fileDownload;	/** Download object for file */
	BOOL _stream;					/** Represents if the received wants the stream or the complete file */
	BOOL _inProgress;				/** Represents if the download has started */
}
@property (nonatomic,retain) FileDownload * fileDownload;
@property (assign) BOOL stream;
@property (assign) BOOL inProgress;
@end

/**
 * @class CachedObject
 * @description Object for storing the songs while cached
 */
@interface CachedObject : NSObject {
@public
	NSString * _filePath;			/** The path to the file in local memory */
	NSData * _openFile;				/** The data is the file is open */
	NSURL * _url;					/** The url where the file came from */
	NSInteger _fileNumber;			/** The number of the file */
}
@property (nonatomic,retain) NSString * filePath;
@property (nonatomic,retain) NSData * openFile;
@property (nonatomic,retain) NSURL * url;
@property (assign) NSInteger fileNumber;
/**
 * @function createLocalFile
 * @description Persists file to the local file system
 */
- (void)createLocalFile;
/**
 * @function removeLocalFile
 * @description Removes file from the local file system
 */
- (void)removeLocalFile;
/**
 * @function loadLocalFile
 * @description Loads file from the local file system
 */
- (void)loadLocalFile;
/**
 * @function loadLocalFile
 * @description Unloads loadede file
 */
- (void)unloadLocalFile;
@end

/**
 * @class FileCacheManager
 * @description Main Object
 */
@interface FileCacheManager : NSObject <FileDownloadDelegate,FileManagerProtocol> {
@public
	id<FileManagerDelegate> _delegate;		  /** Delegate for the Cache Manager */
	NSURLCredential * _credentials;			  /** Credentials for the URL */
	BOOL _cacheToFileSystem;				  /** Flag signalling if the manager can cache to the file system */
@private
	NSMutableDictionary * _cachedFiles;       /** Dictionary for CachedObject objects */
	NSMutableDictionary * _activeDownloads;   /** Dictionary for DownloadingObject objects */
	FileDownload * _scrubbingObject;		  /** This object is only used to stream and is destroyed */
	NSInteger _tempFileCounter;				  /** Counter used to name random files */
}

@property (assign) id<FileManagerDelegate> delegate;
@property (nonatomic,retain) NSURLCredential * credentials;
@property (assign) BOOL cacheToFileSystem;

@end
