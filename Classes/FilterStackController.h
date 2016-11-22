//
//  FilterStackController.h
//  TheFilter
//
//  Created by Ben Hine on 2/11/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FilterView;

typedef enum {
	NewsStackController = 0,
	ShowsStackController,
	FeaturedStackController,
	ProfileStackController,
	ExtrasStackController,
	AccountStackController,
} FilterStackControllerType;

@protocol FilterStackControllerDelegate <NSObject>

//-(void)popView;
//-(void)showRockSuckActionSheetForView:(FilterView*)viewObj;
- (void)pushNewView:(FilterView*)newView fromOldView:(FilterView*)oldView;
- (void)popFromView:(FilterView*)currentView toView:(FilterView*)prevView animated:(BOOL)animated;

@optional
- (void)accountStackDone;

@end

@interface FilterStackController : NSObject
{

	NSMutableArray *navStack_;
	FilterView *currentView_;
	
	FilterStackControllerType controllerType_;
		
	id<FilterStackControllerDelegate> delegate_;
}

@property (nonatomic, readonly, retain) NSMutableArray *navStack;
@property (nonatomic, retain) FilterView *currentView;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) FilterStackControllerType controllerType;

- (id)initWithType:(FilterStackControllerType)type delegate:(id)delegate;
- (FilterView*)currentView;
- (void)popNavigationStack;
- (void)popNavigationStackWithAnimation:(BOOL)animated;
- (void)pushFilterViewWithDictionary:(NSDictionary *)viewDict;
//- (void)showRatingsActionSheetForView:(FilterView*)viewObj;
- (void)filterUpcomingShows;
- (void)authorizationDone;
- (void)logout;

@end
