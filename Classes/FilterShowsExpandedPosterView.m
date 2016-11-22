//
//  FilterShowsExpandedPosterView.m
//  TheFilter
//
//  Created by John Thomas on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterShowsExpandedPosterView.h"
#import "FilterShowsPosterScrollView.h"
#import "FilterPosterView.h"
#import "FilterToolbar.h"

@implementation FilterShowsExpandedPosterView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
		// TODO: pass this control actual data
		posterScrollView = [[FilterShowsPosterScrollView alloc] initWithFrame:CGRectMake(0, -20, 320, 480)];
		posterScrollView.delegate = self;
        [self addSubview:posterScrollView];
		
//		// UX decision to remove the expand button for now
//		expandButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 306, 23, 24)];
//		[expandButton setBackgroundImage:[UIImage imageNamed:@"expand_icon.png"] forState:UIControlStateNormal];
//		[expandButton addTarget:self action:@selector(expandButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:expandButton];

        toolBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btm_bar.png"]];
        toolBar.frame = CGRectMake(0, 410, 320, 51);
        toolBar.userInteractionEnabled = YES;
        [self addSubview:toolBar];
        
		checkInButton = [[UIButton alloc] initWithFrame:CGRectMake(75, 6, 170, 41)];
		[checkInButton setBackgroundImage:[UIImage imageNamed:@"checkin_button.png"] forState:UIControlStateNormal];
		[checkInButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_checkin_button.png"] forState:UIControlStateHighlighted];
        [checkInButton setBackgroundImage:[UIImage imageNamed:@"disabled_check_in_button.png"] forState:UIControlStateDisabled];
		[checkInButton addTarget:self action:@selector(checkInButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[toolBar addSubview:checkInButton];
    
		infoButton = [[UIButton alloc] initWithFrame:CGRectMake(271, 14, 22, 23)];
		[infoButton setBackgroundImage:[UIImage imageNamed:@"i_icon.png"] forState:UIControlStateNormal];
		[infoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[toolBar addSubview:infoButton];
    }
    return self;
}

- (void)dealloc {
    // HACK
    if ([UIApplication sharedApplication].statusBarHidden) {
        [UIApplication sharedApplication].statusBarHidden = NO;
        [[FilterToolbar sharedInstance] setAlpha:1.0];
      //  NSLog(@"WARNING: leaving poster viewer didnt catch animation for toolbar");
    }
    [super dealloc];
}

- (void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];	

	[self updateToolbarLabelsWithShow:[posterScrollView getCurrentShow]];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	// make sure the main toolbar displays the correct subtoolbar
	if (newSuperview == nil){
        //self.clipsToBounds = YES;
        [self.stackController.delegate setWantsFullScreenLayout:NO];
        [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutToolbars) object:nil];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [[FilterToolbar sharedInstance] setAlpha:1.0];
        [toolBar setAlpha:1.0];
	//	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
    }
	else {
        //self.clipsToBounds = YES;
        [self.stackController.delegate setWantsFullScreenLayout:NO];
        [self performSelector:@selector(fadeOutToolbars) withObject:nil afterDelay:1.0];
	}
}


- (void) didMoveToSuperview {
    // HACK
    if ([UIApplication sharedApplication].statusBarHidden) {
        [UIApplication sharedApplication].statusBarHidden = NO;
        [[FilterToolbar sharedInstance] setAlpha:1.0];
        [toolBar setAlpha:1.0];
        
      // NSLog(@"WARNING2: leaving poster viewer didnt catch animation for toolbar");
    }
}

- (void)setPosterDataArray:(NSArray *)array startingAtIndex:(NSInteger)idx {
	[posterScrollView setPosterDataArray:array startingAtIndex:idx];
}

- (void)expandButtonPressed:(id)sender {
	
}

- (void)checkInButtonPressed:(id)button {

	FilterShow *checkIn = [posterScrollView getCurrentShow];
	
	if (checkIn != nil) {
		
		NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
		[data setObject:@"showCheckIn" forKey:@"viewToPush"];
		[data setObject:checkIn forKey:@"data"];
		[self.stackController pushFilterViewWithDictionary:data];
	}
}

- (void) infoButtonPressed:(id)sender {
	FilterShow *show = [posterScrollView getCurrentShow];
	if (show != nil) {
		
		NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
		[data setObject:@"showDetails" forKey:@"viewToPush"];
		[data setObject:[NSNumber numberWithInt:show.showID] forKey:@"showID"];
		[self.stackController pushFilterViewWithDictionary:data];
	}
}

- (void)updateToolbarLabelsWithShow:(FilterShow*)showData {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterLongStyle];
	
    [[FilterToolbar sharedInstance] showSecondaryLabel:[formatter stringFromDate:showData.startDate]];
    [[FilterToolbar sharedInstance] showPrimaryLabel:showData.name];
    
    [formatter release];
    
    checkInButton.enabled = !showData.checkedIn;
}

#pragma mark -
#pragma mark FilterShowsPosterScrollViewDelegate methods

- (void)ExpandedPosterTapped:(id)sender {
	[UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutToolbars) object:nil];
    
    // JDH fix for iOS 7 tap not doing anything.
   // BOOL shouldShow = [UIApplication sharedApplication].statusBarHidden;
    BOOL shouldShow = YES;
    
    [UIView animateWithDuration:0.3 
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         toolBar.alpha = shouldShow ? 1.0 : 0.0;
                         [[FilterToolbar sharedInstance] setAlpha:shouldShow ? 1.0 : 0.0];
                         [UIApplication sharedApplication].statusBarHidden = !shouldShow;
                     } 
                     completion:^(BOOL finished){
//                         if (shouldShow) {
//                             [self performSelector:@selector(fadeOutToolbars) withObject:nil afterDelay:3.0];
//                         }
                     }];
}

- (void)fadeOutToolbars {
    //self.clipsToBounds = NO;
    [self.stackController.delegate setWantsFullScreenLayout:YES];
    [[FilterToolbar sharedInstance] setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.3 
                          delay:0.3 
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         toolBar.alpha = 0.0;
                         [[FilterToolbar sharedInstance] setAlpha:0.0];
                         [UIApplication sharedApplication].statusBarHidden = YES;
                     } 
                     completion:^(BOOL finished){
                         [[FilterToolbar sharedInstance] setUserInteractionEnabled:YES];
                     }];
}

- (void)ScrollingStoppedOnShow:(FilterShow*)filterShow {
	[self updateToolbarLabelsWithShow:filterShow];
}


@end
