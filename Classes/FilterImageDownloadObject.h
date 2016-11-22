//
//  FilterImageDownloadObject.h
//  KeyIngredient
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@class FilterMainImageCache;

@interface FilterImageDownloadObject : NSObject {
  NSMutableData *data_;
  NSError *error_;
  NSDate *startTime_;
  NSURLConnection *connection_;
  NSString *url_;
  FilterMainImageCache *pictureCache_;
  BOOL isPreDownload_;
  BOOL shouldSaveToFileSystem_;
}

- (void)start;

+ (id)imageDownloadObjectWithURL:(NSString *)url 
      shouldSaveToFileSystem:(BOOL)shouldSaveToFileSystem
            controller:(FilterMainImageCache *)controller;

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSString *url;
@property (assign) BOOL isPreDownload;
@property (assign) BOOL shouldSaveToFileSystem;
@property (assign) FilterMainImageCache *pictureCache;

@end
