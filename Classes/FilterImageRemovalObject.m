//
//  FilterImageRemovalObject.m
//  Filter
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "FilterImageRemovalObject.h"
#import "FilterMainImageCache.h"


#define IMAGE_REMOVAL_ENABLED 1


@implementation FilterImageRemovalObject

#pragma mark Class Initialization

static NSThread *CLASSTHREAD = nil;

+ (void)initialize {
#if IMAGE_REMOVAL_ENABLED == 1
  [(NSObject *)self performSelectorInBackground:@selector(deleteThread) 
                                     withObject:nil];
#endif
}

+ (void)processFileTimer {
  
}

+ (void)deleteThread {
  
  CLASSTHREAD = [NSThread currentThread];
  
  //[NSThread setThreadPriority:0.3];
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
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

#pragma mark Instance Methods

- (id)init {
  if ((self = [super init])) {
    removalObjects_ = [[NSMutableArray alloc] init];
    removalObjectsMutex_ = [[NSLock alloc] init];
  } 
  return self;
}

- (void)removeFiles {
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  // NSLog(@"Remove file process began");
  
  BOOL hasItemsToRemove = YES;
  
  while (hasItemsToRemove == YES) {
    
    [removalObjectsMutex_ lock];
    NSArray *removeItems = [NSArray arrayWithArray:removalObjects_];
    [removalObjects_ removeAllObjects];
    [removalObjectsMutex_ unlock];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
   // NSLog(@"Remove %d files",[removeItems count]);
    
    for (NSString *url in removeItems) {
      NSError *error = nil;
      [fileManager removeItemAtPath:url error:&error];
      [NSThread sleepForTimeInterval:0.1];
      //NSLog(@"Delete Image:%@",url);
    }
    
    [fileManager release];
    
    [removalObjectsMutex_ lock];
    if ([removalObjects_ count] == 0) {
      isRemovalProcessRunning_ = NO;
      hasItemsToRemove = NO;
    }
    [removalObjectsMutex_ unlock];
  
  }
  
  //NSLog(@"Remove file process ended");
  
  [pool release];
  
}

- (void)addURLToRemovalQueue:(NSString *)url {
#if IMAGE_REMOVAL_ENABLED == 1  
  NSString *filename = [FilterMainImageCache filenameFromURL:url];
  [removalObjectsMutex_ lock];
  [removalObjects_ addObject:filename];
  [removalObjectsMutex_ unlock];
  
  if (isRemovalProcessRunning_ == NO) {
    isRemovalProcessRunning_ = YES;
    [self performSelector:@selector(removeFiles) 
                 onThread:CLASSTHREAD
               withObject:nil 
            waitUntilDone:NO 
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    
  }
#endif
}

- (void)removeURLFromRemovalQueue:(NSString *)url {
#if IMAGE_REMOVAL_ENABLED == 1
  NSString *filename = [FilterMainImageCache filenameFromURL:url];
  [removalObjectsMutex_ lock];
  [removalObjects_ removeObject:filename];
  [removalObjectsMutex_ unlock];
#endif
}

@end
