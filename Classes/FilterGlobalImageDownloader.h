//
//  FilterGlobalImageDownloader.h
//  KeyIngredient
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "FilterMainImageCache.h"

@interface FilterGlobalImageDownloader : NSObject {

}

+ (FilterMainImageCache *)globalImageDownloader;


+ (void)clearAllCaches;

@end
