//
//  FilterMainFeaturedView.m
//  TheFilter
//
//  Created by Ben Hine on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterMainFeaturedView.h"
#import "FeaturedImageButton.h"
#import "FilterToolbar.h"
#import "Common.h"
#import "RockMeter.h"
#import <QuartzCore/QuartzCore.h>
#import "FilterAPIOperationQueue.h"
#import "FilterPlayerController.h"
#import "FilterAPIOperationQueue.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1]
#define BACKGROUND_COLOR [UIColor clearColor]

#define Y_OFFSET 10

//This is for debugging frames - normally it should be commented out
//#define BACKGROUND_COLOR [UIColor colorWithRed:(float)(rand() % 100)/100.0 green:(float)(rand() % 100)/100.0 blue:(float)(rand() % 100)/100.0 alpha:0.5]


@implementation FilterMainFeaturedView

@synthesize featuredObj = featuredObj_;
@synthesize featuredShow = featuredShow_;
@synthesize featuredTracks = featuredTracks_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = BACKGROUND_COLOR;
		
		featuredTracks_ = [[NSArray alloc] init];

        featuredImage = [[FeaturedImageButton alloc] initWithFrame:CGRectMake(10, Y_OFFSET, 65, 65)];

		[self addSubview:featuredImage];

		featureName = [[UILabel alloc] initWithFrame:CGRectMake(85, Y_OFFSET + 10, 230, 15)];
		featureName.backgroundColor = BACKGROUND_COLOR;
		featureName.font = FILTERFONT(17);
		featureName.textColor = LIGHT_TEXT_COLOR;
		featureName.shadowColor = [UIColor blackColor];
        featureName.shadowOffset = CGSizeMake(0, 1);
		[self addSubview:featureName];
		
		featureNameSecondary = [[UILabel alloc] initWithFrame:CGRectMake(85, Y_OFFSET + 25, 230, 20)];
		featureNameSecondary.backgroundColor = BACKGROUND_COLOR;
		featureNameSecondary.textColor = DARK_TEXT_COLOR;
		featureNameSecondary.font = FILTERFONT(12);
		[self addSubview:featureNameSecondary];
		
		featureNameTertiary = [[UILabel alloc] initWithFrame:CGRectMake(85, Y_OFFSET + 39, 225, 20)];
		featureNameTertiary.backgroundColor = BACKGROUND_COLOR;
		featureNameTertiary.textColor = DARK_TEXT_COLOR;
		featureNameTertiary.font = FILTERFONT(10);
		//featureNameTertiary.text = @"Country, \"Crunk\", Rock";
		[self addSubview:featureNameTertiary];
		
        //TODO: make a subclass of UIView to make this look fancy and animate - this static meter is a placeholder
		rockMeter = [[RockMeter alloc] initWithFrame:CGRectMake(10, Y_OFFSET + 75, 299, 81)];
		
		[self addSubview:rockMeter];
        
        // Create dividers for tracks
		UIView *topDivider = [[[UIView alloc] initWithFrame:CGRectMake(10, Y_OFFSET + 209, 300, 1)] autorelease];
		topDivider.backgroundColor = [UIColor blackColor];
		[self addSubview:topDivider];
		
		UIView *bottomDivider = [[[UIView alloc] initWithFrame:CGRectMake(10, Y_OFFSET + 210, 300, 1)] autorelease];
		bottomDivider.backgroundColor = [UIColor colorWithRed:0.19 green:0.18 blue:0.18 alpha:1];
		[self addSubview:bottomDivider];
		
		UIView *secondTopDivider = [[[UIView alloc] initWithFrame:CGRectMake(10, Y_OFFSET + 257, 300, 1)] autorelease];
		secondTopDivider.backgroundColor = [UIColor blackColor];
		[self addSubview:secondTopDivider];
		
		UIView *secondBottomDivider = [[[UIView alloc] initWithFrame:CGRectMake(10, Y_OFFSET + 258, 300, 1)] autorelease];
		secondBottomDivider.backgroundColor = [UIColor colorWithRed:0.19 green:0.18 blue:0.18 alpha:1];
		[self addSubview:secondBottomDivider];
		
        UIView *thirdTopDivider = [[[UIView alloc] initWithFrame:CGRectMake(10, Y_OFFSET + 305, 300, 1)] autorelease];
		thirdTopDivider.backgroundColor = [UIColor blackColor];
		[self addSubview:thirdTopDivider];
		
		UIView *thirdBottomDivider = [[[UIView alloc] initWithFrame:CGRectMake(10, Y_OFFSET + 306, 300, 1)] autorelease];
		thirdBottomDivider.backgroundColor = [UIColor colorWithRed:0.19 green:0.18 blue:0.18 alpha:1];
		[self addSubview:thirdBottomDivider];
        
		/*
		featureTrackSecondary = [[UILabel alloc] initWithFrame:CGRectMake(82, 87, 225, 18)];
		featureTrackSecondary.backgroundColor = BACKGROUND_COLOR;
		featureTrackSecondary.textColor = LIGHT_TEXT_COLOR;
		featureTrackSecondary.font = FILTERFONT(12);
		[self addSubview:featureTrackSecondary];
		
		featureTrackTertiary = [[UILabel alloc] initWithFrame:CGRectMake(82, 102, 225, 18)];
		featureTrackTertiary.backgroundColor = BACKGROUND_COLOR;
		featureTrackTertiary.textColor = DARK_TEXT_COLOR;
		featureTrackTertiary.font = FILTERFONT(11);
		
		[self addSubview:featureTrackTertiary];
		*/
		
		indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(69, 183, 21, 21) andType:kSmallIndicator];
        [self addSubview:indicator];
        
		followingButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		followingButton.frame = CGRectMake(10, Y_OFFSET + 168, 148, 31);
		followingButton.titleLabel.font = FILTERFONT(13);
		[followingButton setTitle:@"Follow" forState:UIControlStateNormal];
		[followingButton setTitle:@"Following" forState:UIControlStateSelected];
		[followingButton setTitle:@"Following" forState:(UIControlStateSelected | UIControlStateHighlighted)];
		[followingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[followingButton setBackgroundImage:[[UIImage imageNamed:@"featured_screen_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateNormal];
		[followingButton setBackgroundImage:[[UIImage imageNamed:@"pressed_down_featured_screen_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateHighlighted];
		[followingButton setBackgroundImage:[[UIImage imageNamed:@"blue_featured_screen_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:(UIControlStateSelected | UIControlStateNormal)];
//		[followingButton setBackgroundImage:[[UIImage imageNamed:@"pressed_down_blue_under_meter_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:(UIControlStateSelected | UIControlStateHighlighted)];
		//followingButton.selected = YES;
		[followingButton addTarget:self action:@selector(followPushed:) forControlEvents:UIControlEventTouchUpInside];
		
		
		//in honor of the gong show - why?
//		gongButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		gongButton.titleLabel.font = FILTERFONT(13);
//        gongButton.titleLabel.textColor = LIGHT_TEXT_COLOR;
//		[gongButton setTitle:@"Not Interested" forState:UIControlStateNormal];
//		[gongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//		[gongButton setBackgroundImage:[[UIImage imageNamed:@"ni_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateNormal];
//		[gongButton setBackgroundImage:[[UIImage imageNamed:@"pressed_down_ni_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateHighlighted];
//		[gongButton addTarget:self action:@selector(nextButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
//		gongButton.frame = CGRectMake(10, 258, 95, 31);
//		[self addSubview:gongButton];
        
		
		profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[profileButton setTitle:@"Profile" forState:UIControlStateNormal];
		profileButton.titleLabel.font = FILTERFONT(13);
		[profileButton setBackgroundImage:[[UIImage imageNamed:@"featured_screen_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateNormal];
		[profileButton setBackgroundImage:[[UIImage imageNamed:@"pressed_down_featured_screen_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateHighlighted];
//		[profileButton setBackgroundImage:[[UIImage imageNamed:@"selected_profile_follow_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:(UIControlStateSelected | UIControlStateNormal)];
//		[profileButton setBackgroundImage:[[UIImage imageNamed:@"pressed_down_blue_under_meter_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:(UIControlStateSelected | UIControlStateHighlighted)];
		[profileButton addTarget:self action:@selector(pushViewProfile:) forControlEvents:UIControlEventTouchUpInside];
		profileButton.frame = CGRectMake(162, Y_OFFSET + 168, 148, 31);
		
		
		[self addSubview:followingButton];
		[self addSubview:profileButton];
		
		/*
		bottomSectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(10, 270, 300, 25)];
		bottomSectionHeader.backgroundColor = BACKGROUND_COLOR;
		bottomSectionHeader.textColor = LIGHT_TEXT_COLOR;
		bottomSectionHeader.font = FILTERFONT(15);
		bottomSectionHeader.shadowColor = [UIColor blackColor];
		bottomSectionHeader.shadowOffset = CGSizeMake(0, 1);
		bottomSectionHeader.text = @"Upcoming Shows";
		[self addSubview:bottomSectionHeader];
		*/
		/*
		UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
		clearButton.frame = CGRectMake(5, 296, 255, 50);
		clearButton.layer.cornerRadius = 5;
		clearButton.clipsToBounds = YES;
		[clearButton setBackgroundImage:[[UIImage imageNamed:@"onepixel.png"]stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
		[clearButton addTarget:self action:@selector(clearButton) forControlEvents:UIControlEventTouchUpInside];
		
		bottomSectionPrimary = [[UILabel alloc] initWithFrame:CGRectMake(10, 296, 250, 20)];
		bottomSectionPrimary.backgroundColor = BACKGROUND_COLOR;
		bottomSectionPrimary.textColor = LIGHT_TEXT_COLOR;
		bottomSectionPrimary.font = FILTERFONT(12);
		[self addSubview:bottomSectionPrimary];
		
		bottomSectionSecondary = [[UILabel alloc] initWithFrame:CGRectMake(10, 310, 250, 20)];
		bottomSectionSecondary.backgroundColor = BACKGROUND_COLOR;
		bottomSectionSecondary.textColor = LIGHT_TEXT_COLOR;
		bottomSectionSecondary.font = FILTERFONT(11);
		[self addSubview:bottomSectionSecondary];
		
		
		bottomSectionTertiary = [[UILabel alloc] initWithFrame:CGRectMake(10, 322, 250, 20)];
		bottomSectionTertiary.backgroundColor = BACKGROUND_COLOR;
		bottomSectionTertiary.textColor = DARK_TEXT_COLOR;
		bottomSectionTertiary.font = FILTERFONT(10);
		[self addSubview:bottomSectionTertiary];
		[self addSubview:clearButton];
		*/
		/*
		
		bookmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[bookmarkButton setImage:[UIImage imageNamed:@"featured_disabled_bookmark.png"] forState:UIControlStateNormal];
		[bookmarkButton setImage:[UIImage imageNamed:@"bookmark.png"] forState:UIControlStateSelected];
		bookmarkButton.frame = CGRectMake(268, 294, 25, 52);
		[bookmarkButton addTarget:self action:@selector(bookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:bookmarkButton];
		 */
        //NSDictionary *paramDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", [[UIDevice currentDevice] uniqueIdentifier]] forKey:@"udid"]; 
        //[[FilterAPIOperationQueue sharedInstance] FilterAPIOperationGeoGetFeaturedBandsWithParams:paramDict withCallback:self];
    }
    return self;
}

-(void)refreshData {
	
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeNone];
	
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	
	[[FilterToolbar sharedInstance] showLogo];

}

- (void)setInfoWithData:(FilterBand *)data {
    [featuredObj_ release];
    featuredObj_ = [data retain];
    featureName.text = featuredObj_.bandName;
    featureNameSecondary.text = featuredObj_.city;
    featureNameTertiary.text = featuredObj_.genres;
    followingButton.selected = featuredObj_.following;
    
    featuredTracks_ = [[NSArray alloc] initWithArray:featuredObj_.trackArray];

    NSInteger max = MIN([featuredTracks_ count], 2);
    

    for(int i = 0; i < max; i++) {
        
        FilterTrack *song = [featuredTracks_ objectAtIndex:i];
        
        if ([song.durationSeconds intValue] <= 0) {
            break;
        }
        
        track[i] = [[FilterFeaturedSongView alloc] initWithFrame:CGRectMake(10, Y_OFFSET + 210 + (47 * i), 300, 50)];
        [self addSubview:track[i]];
        
        NSInteger minutes;
		NSInteger hours;
		
		minutes = [song.durationSeconds intValue];
		hours   = minutes / 60;
		minutes = minutes % 60;
        
        track[i].songTitle.text = song.trackTitle;
        track[i].songTime.text = [NSString stringWithFormat:@"%d:%02d",hours,minutes];
        track[i].currentTrack = song;
    }
    
    [featuredImage setImageURL:featuredObj_.profilePicMediumURL];
}

- (void)updateRockMeter {
    [rockMeter setRockLevel:[featuredObj_.bandRating intValue] andFollowers:[featuredObj_.followerCount intValue]];
}

- (void)dealloc {
    [featureNameTertiary release];
    [featureNameSecondary release];
    [featureName release];
    [featuredImage release];
    [featuredTracks_ release];
    [rockMeter release];
    [followingButton release];
    [indicator release];
    [super dealloc];
}

//- (void)willMoveToSuperview:(UIView *)newSuperview {
//
//	if (newSuperview == nil) {
//		[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
//	} else {
//		
//	}
//}

#pragma mark - 
#pragma mark Button Click Methods

//-(void)clearButton {
//	//TODO: call show detail
//}
//
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//	NSLog(@"ButtonIndex %d", buttonIndex);
//	switch (buttonIndex) {
//		case 0: //rox
//			break;
//		case 1: //sux
//			break;
//		case 2: //cancel
//			
//			break;
//		default:
//			break;
//	}
//	
//	
//}

-(void)followPushed:(id)sender {
    
    followingButton.userInteractionEnabled = NO;
    if(followingButton.selected) {
        NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:featuredObj_.bandID] forKey:@"bandID"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandUnfollow andCallback:self];
	} else {
        NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:featuredObj_.bandID] forKey:@"bandID"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandFollow andCallback:self];
    }
    [UIView animateWithDuration:0.3 animations:^{ followingButton.alpha = 0.0;}];
    
    [indicator startAnimating];
}

- (void)pushViewProfile:(id)sender {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@"bandProfile" forKey:@"viewToPush"];
    NSNumber *bandID = [[NSNumber alloc] initWithInt:featuredObj_.bandID];
	[dict setObject:bandID forKey:@"ID"];
	
	[self.stackController pushFilterViewWithDictionary:dict];
    
    [dict release];
}

- (void)playPauseButtonClicked {
	if ([featuredImage isSelected]) {
		//selected
		[playPauseImage setImage:[UIImage imageNamed:@"sm_play_button.png"]];
		[featuredImage setSelected:NO];
	} else {
		//not selected
		[[FilterPlayerController sharedInstance] addTrackToPlaylist:[featuredTracks_ objectAtIndex:0] startPlaying:YES overrideCurrent:NO];
		[playPauseImage setImage:[UIImage imageNamed:@"sm_pause_button.png"]];
		[featuredImage setSelected:YES];
	}
}


-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	
    CGFloat bounce = 0.0;
    
	if(filterop.type == kFilterAPITypeBandFollow) {
		
		followingButton.selected = YES;
		featuredObj_.followerCount = [[NSNumber alloc] initWithInt:[featuredObj_.followerCount intValue] + 1];
        [rockMeter setRockLevel:[featuredObj_.bandRating intValue]  andFollowers:[featuredObj_.followerCount intValue]];
		bounce = 0.05;
	} else if (filterop.type == kFilterAPITypeBandUnfollow) {
		followingButton.selected = NO;
		featuredObj_.followerCount = [[NSNumber alloc] initWithInt:[featuredObj_.followerCount intValue] - 1];
        [rockMeter setRockLevel:[featuredObj_.bandRating intValue]  andFollowers:[featuredObj_.followerCount intValue]];
        bounce = -0.05;
    }
    
    [UIView animateWithDuration:0.3 animations:^{ followingButton.alpha = 1.0;} completion:^(BOOL finished){ [indicator stopAnimating]; }];
    
    [rockMeter bounceNeedle:bounce];
    
    followingButton.userInteractionEnabled = YES;
}


-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFailWithError:(NSError*)err {
    
    NSString *title;
    NSString *message;
    
    if ([[err domain] isEqualToString:@"USR"]) {
        title = [[err userInfo] objectForKey:@"name"];
        message = [[err userInfo] objectForKey:@"description"];
    }
    else {
        title = @"Sorry";
        message = @"The Server could not be reached";
    }
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle: title
							   message: message
							   delegate:self
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
    
    [UIView animateWithDuration:0.3 animations:^{ followingButton.alpha = 1.0;} completion:^(BOOL finished){ [indicator stopAnimating]; }];
    
    followingButton.userInteractionEnabled = YES;
}

@end
