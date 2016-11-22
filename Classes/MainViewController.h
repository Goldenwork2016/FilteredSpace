//
//  MainViewController.h
//  TheFilter
//
//  Created by Ben Hine on 1/31/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterTabBarView.h"
#import	"FilterStackController.h"
#import "FilterToolbar.h"
#import "FilterCreateAccountView.h"

@class TheFilterMultimediaManager;
@class StreamingAudioDriver;

@interface MainViewController : UIViewController <FilterTabBarDelegate, FilterStackControllerDelegate, 
												  FilterToolbarDelegate, FilterCreateAccountViewDelegate> 
{
	
	TheFilterMultimediaManager *mediaManager_;
	StreamingAudioDriver *audioDriver_;
	
	// temporary hack to have a persistant account creation object
	FilterCreateAccountView *createAccountView;
	
	FilterTabBarView *tabBar_;
	FilterToolbar *toolbar_;
	UIImageView *backgroundImage;
	
	NSMutableArray *stacksArray;
	
	NSInteger currentFilterTab;
	
	
	FilterStackController *accountStack;
}

- (void)popFromView:(FilterView*)currentView toView:(FilterView*)prevView animated:(BOOL)animated;
- (void)pushNewView:(FilterView*)newView fromOldView:(FilterView*)oldView;
- (void)createAndShowFeatured;
- (void)showFeatured;
- (void)showAccountSignIn;
@end
