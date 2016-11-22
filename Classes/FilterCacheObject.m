//
//  FilterCacheObject.m
//  KeyIngredient
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "FilterCacheObject.h"


@implementation FilterCacheObject
@synthesize maxCount = maxCount_;

- (id)init {
  if ((self = [super init])) {
    maxCount_ = 50;
    cache_ = [[NSMutableDictionary alloc] init];
    orderAdded_ = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [cache_ release], cache_ = nil;
  [orderAdded_ release], orderAdded_ = nil;
  [super dealloc];
}

- (void)removeAllObjects {
  [cache_ removeAllObjects];
  [orderAdded_ removeAllObjects];
}

- (void)setObject:(id)anObject forKey:(id)aKey {
  
  [orderAdded_ addObject:aKey];
  
  if ([orderAdded_ count] > maxCount_) {
    NSString *url = [orderAdded_ objectAtIndex:0];
    [cache_ removeObjectForKey:url];
    [orderAdded_ removeObjectAtIndex:0];
  }
  
  [cache_ setObject:anObject forKey:aKey];
  
}

- (id)objectForKey:(id)key {
  return [cache_ objectForKey:key];
}

@end
