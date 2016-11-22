//
//  Protocols.h
//  TheFilter
//
//  Created by Ben Hine on 1/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StreamingAudioDriverProtocols.h"
#import "TheFilterMultimediaManagerProtocols.h"


@class FilterAPIOperation;
@class ASIHTTPRequest;

@protocol FilterAPIOperationDelegate <NSObject>

-(void)filterAPIOperation:(ASIHTTPRequest *)filterop didFinishWithData:(id)data withMetadata:(id)metadata;

-(void)filterAPIOperation:(ASIHTTPRequest *)filterop didFailWithError:(NSError*)err;


@end