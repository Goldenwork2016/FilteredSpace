//
//  FilterAPIOperationQueue.h
//  TheFilter
//
//  Created by Ben Hine on 1/27/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "Common.h"

@class FilterView;

@interface FilterAPIOperationQueue : NSOperationQueue <ASIHTTPRequestDelegate> {
    NSString *API_URL;
    NSString *API_MEDIA_URL;
    NSArray *filterAPIURLs;
}

+(id)sharedInstance;

@property (nonatomic, retain) NSString *API_URL;
@property (nonatomic, retain) NSString *API_MEDIA_URL;

- (void)FilterAPIRequestWithParams:(NSDictionary *)params andType:(FilterAPIType)type andCallback:(id<FilterAPIOperationDelegate>)callback;
- (void)removeOperationsForCallback:(FilterView *)callback;
- (void)removeAllOperations;
- (BOOL)isAPITypeInQueue:(FilterAPIType)type;
@end
