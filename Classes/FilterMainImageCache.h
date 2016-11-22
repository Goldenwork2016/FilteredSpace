//
//  FilterMainImageCache.h
//  KeyIngredient
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "FilterCacheObject.h"
#import "FilterImageRemovalObject.h"

@interface FilterMainImageCache : NSObject {
  
  NSThread *thread_;
  FilterCacheObject *cache_;
  
  NSMutableArray *queue_;
  NSMutableDictionary *downloadQueue_;
  NSInteger maxDownloadCount_;
  NSInteger downloadCount_;
  
  NSMutableArray *preQueue_;
  NSMutableDictionary *preDownloadQueue_;
  NSInteger maxPreDownloadCount_;
  NSInteger preDownloadCount_;
  NSLock *preDownloadLock_;
  
  NSInteger maxItemsInQueue_;
  
  FilterImageRemovalObject *imageRemoval_;
  
  BOOL shouldSaveToFileSystem_;
}

@property (assign) NSThread *thread;
@property (assign) NSInteger maxDownloadCount;
@property (assign) NSInteger maxPreDownloadCount;
@property (assign) NSInteger maxItemsInQueue;
@property (assign) BOOL shouldSaveToFileSystem;
@property (readonly) FilterCacheObject *cache;

#pragma mark -
#pragma mark Methods to create Network Threads
+ (NSThread *)createImageDownloadThread;
- (void)killImageDownloadThread:(NSThread *)thread;
+ (NSString *)filenameFromURL:(NSString *)url;

#pragma mark -
#pragma mark Instance Methods

- (void)clearImageCache;
- (UIImage *)imageForURL:(NSString *)url object:(id)object selector:(SEL)selector;
- (void)removeListener:(id)listener url:(NSString *)url;

- (void)preDownloadURLs:(NSArray *)urls;
- (void)preDownloadURL:(NSString *)url;
- (void)removePreDownloadURL:(NSString *)url;

@end

@interface NSNotification (ImageCache)
- (UIImage *)image;
- (NSString *)url;
@end
