//
//  FileDownloadManager.h
//  TheFilter
//
//  Created by Eric Chapman on 12/26/09.
//

#import <Foundation/Foundation.h>
#import "FileDownloadProtocals.h"
#import "FileDownload.h"

@interface FileDownloadManager : NSObject <FileDownloadDelegate,FileManagerProtocol> {
	id<FileManagerDelegate> _delegate;		  /** Delegate for the Cache Manager */
	NSURLCredential * _credentials;			  /** Credentials for the URL */
	NSMutableDictionary * _activeDownloads;   /** Dictionary for DownloadingObject objects */
	NSMutableDictionary * _activeFragments;	  /** Dictionary of fragments */
	BOOL _canDownloadWhileFragmentIsDownloading; /** Flag signalling if hte main download can continue while the fragemnt is going */
}
@property (assign) id<FileManagerDelegate> delegate;
@property (nonatomic,retain) NSURLCredential * credentials;

@end
