//
//  FilterGlobalImageDownloader.m
//  KeyIngredient
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FilterGlobalImageDownloader.h"


@implementation FilterGlobalImageDownloader


static FilterMainImageCache *globalImageDownloader = nil;

+ (void)initialize {
  
  
  globalImageDownloader = [[FilterMainImageCache alloc] init];
  globalImageDownloader.thread = [FilterMainImageCache createImageDownloadThread];
  //globalImageDownloader.thread = [NSThread mainThread];
  globalImageDownloader.cache.maxCount = 25;
  globalImageDownloader.maxDownloadCount = 10;
  globalImageDownloader.shouldSaveToFileSystem = YES;
  

  
}

+ (FilterMainImageCache *)globalImageDownloader {
  return globalImageDownloader;
}

+ (void)clearAllCaches {
  [globalImageDownloader clearImageCache];
}

@end
