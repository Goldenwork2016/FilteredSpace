//
//  FilterShowsCheckIn.h
//  TheFilter
//
//  Created by John Thomas on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FilterView.h"
#import "FilterPosterView.h"
#import "FilterCheckInCommentView.h"

#import "FilterDataObjects.h"

@interface FilterShowsCheckIn : FilterView <FilterAPIOperationDelegate> {

	UIImageView *filterObjImage;
	FilterDataObject *checkInObj_;
	
	FilterCheckInCommentView *checkInComments;
	UILabel *venueLabel, *bandLabel, *attendingLabel;
	
	UIImageView *shareBackground;
	UILabel *shareLabel;
	UIButton *twitterButton, *facebookButton, *tumblrButton;
    UIAlertView *objAlertView;
}

@property (strong, nonatomic) NSMutableDictionary *postParams;
@property (nonatomic, retain) FilterDataObject *checkInObj;

@end
