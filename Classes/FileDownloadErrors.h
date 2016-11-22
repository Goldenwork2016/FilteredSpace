//

// File Download Errors
#define FileDownloadErrorDomain			@"FileDownload"
#define FileDownloadErrorDomainOffset	-22000
#define DLError1  FileDownloadErrorDomainOffset-0	// Connection could not be established
#define DLError2  FileDownloadErrorDomainOffset-1	// Resume was called on a download that never started
#define DLError3  FileDownloadErrorDomainOffset-2	// Begin was called on a paused download
#define DLError4  FileDownloadErrorDomainOffset-3	// Begin was in an un-expected state
#define DLError5  FileDownloadErrorDomainOffset-4	// NSURLConnection could not handle the request
#define DLError6  FileDownloadErrorDomainOffset-5	// Server returned content of -1.  Probably bad request.  This is bad
#define DLError7  FileDownloadErrorDomainOffset-6	// Authentication challenge cancelled
#define DLError8  FileDownloadErrorDomainOffset-7	// Resume Error was called on a download that didn't error out
#define DLError9  FileDownloadErrorDomainOffset-8	// System has retried and errored download too many times

#define FileDownloadManagerErrorDomain			@"FileDownloadManager"
#define FileDownloadManagerErrorDomainOffset	-23000
#define DLMError1 FileDownloadManagerErrorDomainOffset-0	// Download Manager does not support caching to local file system
#define DLMError2 FileDownloadManagerErrorDomainOffset-1	// The user attempted to retrieve the offset of a song before the song was downloaded
#define DLMError3 FileDownloadManagerErrorDomainOffset-2	// Fragment in main download queue
#define DLMError4 FileDownloadManagerErrorDomainOffset-3	// The download is in an unknown state