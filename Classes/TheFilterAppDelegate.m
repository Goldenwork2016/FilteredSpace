//
//  TheFilterAppDelegate.m
//  TheFilter
//
//  Created by Ben Hine on 1/26/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "TheFilterAppDelegate.h"
#import "MainViewController.h"
#import "FilterLocationManager.h"
#import <FacebookSDK/FacebookSDK.h>
//#import "HTNotifier.h"

@implementation TheFilterAppDelegate

@synthesize window;

NSString *const FBSessionStateChangedNotification =
@"com.afineWeb.JDH-Testing-App:FBSessionStateChangedNotification";

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Get the users current location
    [[FilterLocationManager sharedInstance] startUpdatingLocation];
    
    /*
    [[NSUserDefaults standardUserDefaults] setObject:@"http://staging.filteredspace.com/api/v2/" forKey:@"apiurl"];
    [[NSUserDefaults standardUserDefaults] setObject:@"http://staging.filteredspace.com" forKey:@"mediaurl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	*/
    // Override point for customization after application launch.
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
	mainViewController = [[MainViewController alloc] init];
    UINavigationController *rootNav = [[UINavigationController alloc]initWithRootViewController:mainViewController];
    [rootNav setNavigationBarHidden:YES animated:YES];
    self.window.rootViewController = rootNav;
    
	//[self.window addSubview:mainViewController.view];
    [self.window makeKeyAndVisible];
    
    //JDH
    self.window.backgroundColor = [UIColor blackColor];

    //[HTNotifier startNotifierWithAPIKey:@"6d0745e471fa0dd0f95d292abd84ac1a"
    //                    environmentName:HTNotifierDevelopmentEnvironment];
    
    return YES;
}

// Facebook handling for url/session info received after authentication
- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication 
         annotation:(id)annotation 
{
    return [FBSession.activeSession handleOpenURL:url]; 
}

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
              //  NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


/*
 * Opens a Facebook session and optionally shows the login UI.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    
    /*
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"publish_actions", nil];
    return [FBSession openActiveSessionWithPermissions:permissions
                                          allowLoginUI:allowLoginUI
                                     completionHandler:^(FBSession *session,
                                                         FBSessionState state,
                                                         NSError *error) {
                                         [self sessionStateChanged:session
                                                             state:state
                                                             error:error];
                                     }];
    
    */
    
    return [FBSession openActiveSessionWithAllowLoginUI:allowLoginUI];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}






@end
