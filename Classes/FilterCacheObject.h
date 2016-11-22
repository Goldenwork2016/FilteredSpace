//
//  FilterCacheObject.h
//  KeyIngredient
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface FilterCacheObject : NSObject {
  NSInteger maxCount_;
  NSMutableDictionary *cache_;
  NSMutableArray *orderAdded_;
}
@property (assign) NSInteger maxCount;

- (void)removeAllObjects;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)key;

@end
