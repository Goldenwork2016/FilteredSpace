//
//  FilterCache.m
//  TheFilter
//
//  Created by Ben Hine on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterCache.h"
#import "SFHFKeychainUtils.h"

@implementation FilterCache

static FilterCache *singleton = nil;

//TODO: THIS IS NOT SECURE AT ALL - 
//DO NOT RELEASE WITHOUT CHANGING THIS TO STORE CONFIDENTIAL DETAILS IN THE KEYCHAIN AND MUNDANE DETAILS IN NSUSERDEFAULTS
//THIS IS MERELY A HACK TO GET A BUILD OUT
-(void)storeMyAccount:(FilterFanAccount*)myAccount {
	
	NSString *filename = [NSString stringWithFormat:@"%@.acctobj", myAccount.userName];
	[[NSUserDefaults standardUserDefaults] setObject:myAccount.userName forKey:USERNAME_KEY];
	[[NSUserDefaults standardUserDefaults] setObject:filename forKey:@"accountFile"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
	
	assert([NSKeyedArchiver archiveRootObject:myAccount toFile:filePath]);
	
}

-(void)removeMyAccount {    
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:USERNAME_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)myAccountDataExists {
	/*
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSFileManager *fileMan = [NSFileManager defaultManager];
	return [fileMan fileExistsAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"myaccount.obj"]];
	*/
	
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY];
	NSError *err = nil;
	
	NSString *pass = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:KEYCHAIN_SERVICENAME error:&err];
	
	if(err == nil && pass && username) {
		
		return YES;
	} 
		
	return NO;
}

-(FilterFanAccount*)getMyAccount {
	if([self myAccountDataExists]) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"myaccount.obj"];
	
		FilterFanAccount *acct = (FilterFanAccount*)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
		acct.userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY];
		NSError *err = nil;
		acct.userPass = [SFHFKeychainUtils getPasswordForUsername:acct.userName andServiceName:KEYCHAIN_SERVICENAME error:&err];
		
		
		return acct;
	}
	return nil;
}

#pragma mark - 
#pragma mark Singleton Methods

+(id)sharedInstance {
	
	@synchronized(self) {
		
		if(singleton == nil) {
			singleton = [[FilterCache alloc] init];
		}
		return singleton;
	}
}

-(id)init {
	
	self = [super init];
	if(self) {
		
		theCache_ = [[NSMutableDictionary alloc] init];
		
		[theCache_ setObject:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"tracks"];
		[theCache_ setObject:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"bands"];
		[theCache_ setObject:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"shows"];
		[theCache_ setObject:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"checkins"];
		[theCache_ setObject:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"venues"];
		[theCache_ setObject:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"accounts"];
		
		//TODO: stupid setup - we'll read from disk and push this to another thread later
		
	}
	return self;
	
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
