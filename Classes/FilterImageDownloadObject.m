//
//  FilterImageDownloadObject.m
//  KeyIngredient
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "FilterImageDownloadObject.h"
#import "FilterMainImageCache.h"
#import "NSString+md5.h"

@interface FilterImageDownloadObject()
- (NSString *)filenameFromURL:(NSString *)url;
- (NSData *)fileFromURL:(NSString *)url;
- (void)writeData:(NSData *)data forUrL:(NSString *)url;
- (void)writeDataToFileSystemInBackground;
@end

@interface FilterMainImageCache(private)
- (void)preDownloadComplete:(NSString *)url;
@end


@implementation FilterImageDownloadObject
@synthesize error = error_;
@synthesize data = data_;
@synthesize startTime = startTime_;
@synthesize url = url_;
@synthesize pictureCache = pictureCache_;
@synthesize isPreDownload = isPreDownload_;
@synthesize shouldSaveToFileSystem = shouldSaveToFileSystem_;

#pragma mark -
#pragma mark Private Methods
- (NSString *)filenameFromURL:(NSString *)url {
  return [NSString stringWithFormat:@"%@/%@_%08d.png",NSTemporaryDirectory(),[url md5],[url hash]];
}
- (NSData *)fileFromURL:(NSString *)url {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *filename = [self filenameFromURL:url];
  if ([fileManager fileExistsAtPath:filename] == NO) {
    return nil;
  }
  else {
    return [NSData dataWithContentsOfFile:filename];
  }
}
- (void)writeData:(NSData *)data forUrL:(NSString *)url {
  [data writeToFile:[self filenameFromURL:url] atomically:YES];
}

- (void)dealloc {
  [error_ release], error_ = nil;
  [data_ release], data_ = nil;
  [startTime_ release], startTime_ = nil;
  [connection_ release], connection_ = nil;
  [url_ release], url_ = nil;
  pictureCache_ = nil;
  [super dealloc];
}
- (id)init {
  if ((self = [super init])) {
    isPreDownload_ = NO;
    shouldSaveToFileSystem_ = NO;
  }
  return self;
}

+ (id)imageDownloadObjectWithURL:(NSString *)url 
      shouldSaveToFileSystem:(BOOL)shouldSaveToFileSystem
            controller:(FilterMainImageCache *)controller {
  
  FilterImageDownloadObject *newObject = [[FilterImageDownloadObject alloc] init];
  newObject.url = url;
  newObject.pictureCache = controller;
  newObject.shouldSaveToFileSystem = shouldSaveToFileSystem;
  return [newObject autorelease];
  
}

- (void)writeDataToFileSystemInBackground {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  [self writeData:self.data forUrL:self.url];
  
  // This is terrible but I dont have time to make the parent
  // controller keep the object alive so I have to do this for
  // now
  [self autorelease];
  
  [pool release];
}

- (void)start {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  // See if the file exists
  NSData *imageData = [self fileFromURL:self.url];
  
  if (imageData != nil) {
    if (self.isPreDownload == NO) {
      // We already downloaded it.  Sweeeeeeet
      NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                    [UIImage imageWithData:imageData],@"image",
                    self.url,@"url",
                    nil];
      
      [self.pictureCache performSelectorOnMainThread:@selector(returnDownloadedImage:) 
                        withObject:userInfo 
                       waitUntilDone:NO];
    }
    else {
      [self.pictureCache preDownloadComplete:self.url];
    }

  }
  else {
    
    // Else download it
    self.data = [NSMutableData data];
    self.error = nil;
    
    self.startTime = [NSDate date];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    
    connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
  }
  
  [pool release];
  
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  self.error = error;
  
  if (self.isPreDownload == NO) {
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                  self.url,@"url",
                  nil];
    
    [self.pictureCache performSelectorOnMainThread:@selector(returnError:) 
                      withObject:userInfo 
                     waitUntilDone:NO];
    
  }
  else {
    [self.pictureCache preDownloadComplete:self.url];
  }

  //NSLog(@"Image Cache Error URL: %@",self.url);
  
  [pool release];
  
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  //NSTimeInterval totalTime = [[NSDate date] timeIntervalSinceDate:self.startTime];
  
  //NSLog(@"Image Cache: TIME: %03.2fs SIZE: %d URL: %@",totalTime,[self.data length],self.url);
  
  UIImage * image = [UIImage imageWithData:self.data];
  
  if (image == nil) {
    if (self.isPreDownload == NO) {
      NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                    self.url,@"url",
                    nil];
      
      [self.pictureCache performSelectorOnMainThread:@selector(returnError:) 
                        withObject:userInfo 
                       waitUntilDone:NO];
    }
  }
  else {
    
    if (self.isPreDownload == NO) {
      NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                    image,@"image",
                    self.url,@"url",
                    nil];
      
      [self.pictureCache performSelectorOnMainThread:@selector(returnDownloadedImage:) 
                        withObject:userInfo 
                       waitUntilDone:NO];
    }
    
    if (self.shouldSaveToFileSystem == YES) {
      // This is bad but I dont have time to make the parent controller keep
      // this object alive, hence the "retain" on self.  the process will
      // autorelase self to keep the memory balanced.  This is still safe,
      // just not a good practice...
      [[self retain] performSelectorInBackground:@selector(writeDataToFileSystemInBackground) 
                      withObject:nil];
    }
    
  }
  
  if (self.isPreDownload == YES) {
    [self.pictureCache preDownloadComplete:self.url];
  }
  
  [pool release];
  
}


@end
