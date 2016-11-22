//
//  FilterView.h
//  TheFilter
//
//  Created by Ben Hine on 2/18/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterStackController.h"
#import "FilterAPIOperationQueue.h"
#import "FilterToolbar.h"

@interface FilterView : UIView {

	FilterStackController *stackController;
    BOOL showsTabBar;
    
    UIViewAnimationOptions popTransitionStyle;
    UIViewAnimationOptions pushTransitionStyle;
}

@property (nonatomic, retain) FilterStackController *stackController;
@property (nonatomic, assign) BOOL showsTabBar;
@property (nonatomic, assign) UIViewAnimationOptions popTransitionStyle;
@property (nonatomic, assign) UIViewAnimationOptions pushTransitionStyle;

- (id)initWithFrame:(CGRect)frame andDictionary:(NSDictionary *)dict;
- (void)configureToolbar;
- (void)donePushed:(id)button;
- (void)searchReturned:(NSString *)searchString;
- (void)refreshData;
- (void)addPlayerObserver;
- (void)removePlayerObserver;

@end
