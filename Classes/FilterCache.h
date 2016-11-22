//
//  FilterCache.h
//  TheFilter
//
//  Created by Ben Hine on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterDataObjects.h"

@interface FilterCache : NSObject {

	NSMutableDictionary *theCache_;
	
}

+ (id)sharedInstance;

- (void)storeMyAccount:(FilterFanAccount*)myAccount;
//- (void)addFanAccount:(FilterFanAccount*)aAccount;
//- (FilterFanAccount*)getAccountWithID:(NSInteger)accountID;
- (void)removeMyAccount;
- (BOOL)myAccountDataExists;
- (FilterFanAccount*)getMyAccount;

@end
