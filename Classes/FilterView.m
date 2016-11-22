//
//  FilterView.m
//  TheFilter
//
//  Created by Ben Hine on 2/18/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "FilterView.h"

@implementation FilterView

@synthesize stackController;
@synthesize showsTabBar;
@synthesize popTransitionStyle;
@synthesize pushTransitionStyle;

// Description: New init that allows the passing of information while keeping a general initilization.
//
// Overriding is required
- (id)initWithFrame:(CGRect)frame andDictionary:(NSDictionary *)dict {
    self = [super initWithFrame:frame];
    if (self) {
        
        popTransitionStyle = UIViewAnimationOptionCurveEaseInOut;
        pushTransitionStyle = UIViewAnimationOptionCurveEaseInOut;
    }
    
    return self;
}

// Description: Old implementation for legacy purposes
//
// Deprecated
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        popTransitionStyle = UIViewAnimationOptionCurveEaseInOut;
        pushTransitionStyle = UIViewAnimationOptionCurveEaseInOut;
    }
    
    return self;
}

// Description: Use to configure the toolbar using the [FilterToolbar sharedInstance].
//
// Override is required
-(void)configureToolbar {
}

// Description: If adding a done button on the toolbar overriding is required.
//
// Overriding is dependent
-(void)donePushed:(id)button {
}

// Description: If a secondary search toolbar is added, overriding is required.
//
// Overriding is dependent
-(void)searchReturned:(NSString *)searchString {
}

// Description: Is called when addPlayerObserver has been called the player changes status (stopped, started, paused)
//
// Overriding is optional
-(void)playerChanged:(id)sender {
}

// Description: Called when moving to a view. Override to fresh the views data.
//
// Overriding is optional
-(void)refreshData {
}

// Description: Call to observe player change events
//
// Do not override
-(void)addPlayerObserver {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerChanged:) name:@"PlayerTrackChanged" object:nil];
}

// Description: Call to remove observation of player change events
//
// Do not override
-(void)removePlayerObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"PlayerTrackChanged" object:nil];
}

@end
