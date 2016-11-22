//
//  FilterMainImageCache.m
//  KeyIngredient
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "FilterMainImageCache.h"
#import "FilterImageDownloadObject.h"
#import "NetworkActive.h"
#import "NSString+md5.h"

@implementation FilterMainImageCache

@synthesize thread = thread_;
@synthesize maxDownloadCount = maxDownloadCount_;
@synthesize maxPreDownloadCount = maxPreDownloadCount_;
@synthesize maxItemsInQueue = maxItemsInQueue_;
@synthesize shouldSaveToFileSystem = shouldSaveToFileSystem_;
@synthesize cache = cache_;

static NSThread *newThread_ = nil;

#pragma mark -
#pragma mark Class Methods

+ (void)processFileTimer {
  
}

+ (void)threadMain {
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  assert(newThread_ != [NSThread mainThread]);
  
  newThread_ = [NSThread currentThread];
  
  NSTimer *downloadTimer = [NSTimer timerWithTimeInterval:1 
                           target:self 
                           selector:@selector(processFileTimer) 
                           userInfo:nil 
                          repeats:YES];
  
  [[NSRunLoop currentRunLoop] addTimer:downloadTimer forMode:NSDefaultRunLoopMode];
  
  [[NSRunLoop currentRunLoop] run];
  
  [downloadTimer invalidate];
  
  [pool release];

}

+ (NSThread *)createImageDownloadThread {
  
  
  @synchronized(self) {
    
    [NSThread detachNewThreadSelector:@selector(threadMain) toTarget:[FilterMainImageCache class] withObject:nil];
    
    while (newThread_ == nil) {
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    NSThread *tempThread = newThread_;
    newThread_ = nil;
    
    return tempThread;
    
  }
  
}
- (void)killImageDownloadThread:(NSThread *)thread {
  [thread cancel];
}

+ (NSString *)filenameFromURL:(NSString *)url {
  return [NSString stringWithFormat:@"%@/%@_%08d.png",NSTemporaryDirectory(),[url md5],[url hash]];
}

#pragma mark -
#pragma mark Instance Methods

- (void)checkQueue {
  if (downloadCount_ < maxDownloadCount_) {
    for (int i=downloadCount_; i<maxDownloadCount_; i++) {
      
      if ([queue_ count] > 0) {
        
        NSString *url = [[queue_ lastObject] retain];
        downloadCount_++;
        [queue_ removeLastObject];
        
        FilterImageDownloadObject *newObject = [FilterImageDownloadObject imageDownloadObjectWithURL:url 
                                        shouldSaveToFileSystem:self.shouldSaveToFileSystem
                                              controller:self];
        
        [downloadQueue_ setObject:newObject forKey:url];
        
//        [NetworkActive networkActiveConnection:YES];
        
        [newObject performSelector:@selector(start) 
                  onThread:self.thread 
                withObject:nil 
               waitUntilDone:NO];
        
        [url release];
      }
      else {
        break;
      }
      
    }
  }
}

- (void)checkPreDownloadQueue {
  
  [preDownloadLock_ lock];
  
  NSInteger remaingingSpots = ((maxDownloadCount_+maxPreDownloadCount_)-downloadCount_)-preDownloadCount_;
  
  if (remaingingSpots > 0) {
    for (int i=0; i<remaingingSpots; i++) {
      
      if ([preQueue_ count] > 0) {
        
        NSString *url = [[preQueue_ lastObject] retain];
        preDownloadCount_++;
        [preQueue_ removeLastObject];
        
        FilterImageDownloadObject *newObject = [FilterImageDownloadObject imageDownloadObjectWithURL:url 
                                        shouldSaveToFileSystem:self.shouldSaveToFileSystem
                                              controller:self];
        newObject.isPreDownload = YES;
        
        [preDownloadQueue_ setObject:newObject forKey:url];
        
        [newObject performSelector:@selector(start) 
                  onThread:self.thread 
                withObject:nil 
               waitUntilDone:NO];
        
        [url release];
      }
      else {
        break;
      }
      
    }
  }
  
  [preDownloadLock_ unlock];
}

- (void)preDownloadComplete:(NSString *)url {
  preDownloadCount_--;
  [preDownloadLock_ lock];
  [preDownloadQueue_ removeObjectForKey:url];
  [preDownloadLock_ unlock];
  [self checkPreDownloadQueue];
}

- (void)addURLToQueue:(NSString *)url {
  
  for(int i = 0; i < [queue_ count]; i++) {
      //NSString *test = [queue_ objectAtIndex:i];
      if ([[queue_ objectAtIndex:i] isEqualToString:url]) {
          [queue_ removeObjectAtIndex:i];
          break;
      }
  }
//  NSUInteger urlLocation = [queue_ indexOfObject:url];
//  if (urlLocation >= 0 && urlLocation < [queue_ count] && [queue_ count] > 0) {
//    [queue_ removeObjectAtIndex:urlLocation];
//  }
  
  [queue_ addObject:url];
  
  if ([queue_ count] > maxItemsInQueue_ && [queue_ count] > 0) {
    [queue_ removeObjectAtIndex:0];
  }
  
  [self checkQueue];
  
}

- (void)preDownloadURLs:(NSArray *)urls {
  
  [preDownloadLock_ lock];
  
  for (NSString *url in urls) {
    [preQueue_ addObject:url];
    [imageRemoval_ removeURLFromRemovalQueue:url];
  }
  
  [preDownloadLock_ unlock];
  
  [self checkPreDownloadQueue];
  
}

- (void)preDownloadURL:(NSString *)url {
  
  [preDownloadLock_ lock];
  
  [preQueue_ addObject:url];
  [imageRemoval_ removeURLFromRemovalQueue:url];
  
  [preDownloadLock_ unlock];
  
  [self checkPreDownloadQueue];
  
}

- (void)removePreDownloadURL:(NSString *)url {
  
  [preDownloadLock_ lock];
  
  NSUInteger objectLocation = [preQueue_ indexOfObject:url];
  if (objectLocation>=[preQueue_ count]) {
    [imageRemoval_ addURLToRemovalQueue:url];
  }
  
  [preDownloadLock_ unlock];
  
}

- (id)init {
  if ((self = [super init])) {
    maxDownloadCount_ = 10;
    maxPreDownloadCount_ = 5;
    downloadCount_ = 0;
    preDownloadCount_ = 0;
    maxItemsInQueue_ = 40;
    shouldSaveToFileSystem_ = NO;
    queue_ = [[NSMutableArray alloc] init];
    downloadQueue_ = [[NSMutableDictionary alloc] init];
    preQueue_ = [[NSMutableArray alloc] init];
    preDownloadQueue_ = [[NSMutableDictionary alloc] init];
    cache_ = [[FilterCacheObject alloc] init];
    preDownloadLock_ = [[NSLock alloc] init];
    imageRemoval_ = [[FilterImageRemovalObject alloc] init];
  }
  return self;
}

- (void)dealloc {
  [cache_ release], cache_ = nil;
  [queue_ release], queue_ = nil;
  [preQueue_ release], preQueue_ = nil;
  [preDownloadQueue_ release], preDownloadQueue_ = nil;
  [downloadQueue_ release], downloadQueue_ = nil;
  [imageRemoval_ release], imageRemoval_ = nil;
  [super dealloc];
}

- (void)clearImageCache {
  [cache_ removeAllObjects];
}

- (void)returnError:(NSDictionary *)userInfo {
  
  downloadCount_--;
//  [NetworkActive networkActiveConnection:NO];
  
  // Use the main thread as a mutex
  assert([NSThread mainThread] == [NSThread currentThread]);
  
  NSString *url = [userInfo objectForKey:@"url"];
  
  [downloadQueue_ removeObjectForKey:url];
  
  // We retained this in the main thread before calling it, so we are releasing it now
  [userInfo autorelease];
  
  [self checkQueue];
  
}

- (void)returnDownloadedImage:(NSDictionary *)userInfo {
  
  downloadCount_--;
//  [NetworkActive networkActiveConnection:NO];
  
  // Use the main thread as a mutex
  assert([NSThread mainThread] == [NSThread currentThread]);
  
  UIImage *image = [userInfo objectForKey:@"image"];
  NSString *url = [userInfo objectForKey:@"url"];
  
  [cache_ setObject:image forKey:url];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:url 
                            object:nil 
                            userInfo:userInfo];
  
  
  [downloadQueue_ removeObjectForKey:url];
  
  // We retained this in the main thread before calling it, so we are releasing it now
  [userInfo autorelease];
  
  [self checkQueue];
  
}


- (UIImage *)imageForURL:(NSString *)url object:(id)object selector:(SEL)selector {
  
  assert([NSThread mainThread] == [NSThread currentThread]);
  
  if (url == nil) {
    return nil;
  }
  
  // This checks allows us to predownload images by passing nil in for the selector and the object
  if(!(object == nil || selector == nil)) {
    // Subscribe the object to the notification
    [[NSNotificationCenter defaultCenter] addObserver:object selector:selector name:url object:nil];
  }
  
  // See if we have the image
  id image = [cache_ objectForKey:url];
  
  if(image == nil){
    
    // If not, start the download
    [cache_ setObject:[NSNull null] forKey:url];
    [self addURLToQueue:url];
    
  }
  else if([image isKindOfClass:[NSNull class]]) {
    // It is already downloading and we have already subscribed to it.  Lets move it to
    // the top of the queue
    [self addURLToQueue:url];
  }
  else {
    // If we have it, return it
    return image;
  }
  
  return nil;
  
}

- (void)removeListener:(id)listener url:(NSString *)url {
  assert([NSThread mainThread] == [NSThread currentThread]);
  
  [[NSNotificationCenter defaultCenter] removeObserver:listener name:url object:nil];
}

@end


#pragma mark -
#pragma mark NSNotification

@implementation NSNotification (ImageCache)
- (UIImage *)image {
  NSDictionary *userInfo = [self userInfo];
  return [userInfo objectForKey:@"image"];
}

- (NSString *)url {
  NSDictionary *userInfo = [self userInfo];
  return [userInfo objectForKey:@"url"];
}
@end
