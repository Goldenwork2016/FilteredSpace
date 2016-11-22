//
//  TheFilterAppDelegate.h
//  TheFilter
//
//  Created by Ben Hine on 1/26/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface TheFilterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	MainViewController *mainViewController;
	
}

extern NSString *const FBSessionStateChangedNotification;

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@end

