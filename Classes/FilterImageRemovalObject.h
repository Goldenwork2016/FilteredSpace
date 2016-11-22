//
//  FilterImageRemovalObject.h
//  KeyIngredient
//
//  Created by Ben Hine on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface FilterImageRemovalObject : NSObject {
  NSMutableArray *removalObjects_;
  NSLock *removalObjectsMutex_;
  BOOL isRemovalProcessRunning_;
}

- (void)addURLToRemovalQueue:(NSString *)url;
- (void)removeURLFromRemovalQueue:(NSString *)url;

@end
