//
//  FilterShowsPosterView.m
//  TheFilter
//
//  Created by John Thomas on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterShowsPosterView.h"
#import "FilterToolbar.h"
#import "FilterPosterView.h"
#import "FilterAPIOperationQueue.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation FilterShowsPosterView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		posterShows_ = [[NSMutableArray alloc] init];

        //JDH Original
        //posterScrollView = [[FilterScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        //JDH making the frame size to full height.
		posterScrollView = [[FilterScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 480)];
        
		posterScrollView.backgroundColor = [UIColor clearColor];
		posterScrollView.delegate = self;
		[self addSubview:posterScrollView];
    }
    return self;
}


-(void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeNone];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_UpcomingShows];
	[[FilterToolbar sharedInstance] showUpcomingShowsMapButton:YES];
	
	[[FilterToolbar sharedInstance] showLogo];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
		
	// make sure the main toolbar displays the correct subtoolbar
	if (newSuperview == nil){
		//[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
    }
	else {
		if([posterShows_ count] == 0) {
            [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:nil andType:kFilterAPITypeGeoGetEvents andCallback:self];
		}
	}
}

- (void)filterPosterTapped:(id)sender {
	FilterPosterView *poster = sender;
	NSNumber *idx = [[NSNumber alloc] initWithInt:[posterShows_ indexOfObject:[NSNumber numberWithInt:poster.filterShowID]]];
	
	NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
//	[data setObject:@"showDetails" forKey:@"viewToPush"];
//  [data setObject:[posterShows_ objectAtIndex:[idx intValue]] forKey:@"data"];
    
    [data setObject:@"showExpandedPosters" forKey:@"viewToPush"];
	[data setObject:posterShows_ forKey:@"data"];
	[data setObject:idx forKey:@"selectedIndex"];
    
	[self.stackController pushFilterViewWithDictionary:data];
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {

	[posterShows_ addObjectsFromArray:(NSArray*)data];
	
	int x, row, column;
	for (x = 0; x < [posterShows_ count]; x++) {
		
		row = x / 4;
		column = x % 4;
		
		// build a container view for the poster and misc show info
		CGRect showFrame = CGRectMake(15 + (75 * column), 10 + (135 * row), 65, 125);
		UIView *showInfoView = [[UIView alloc] initWithFrame:showFrame];;
		showInfoView.backgroundColor = [UIColor clearColor];

		FilterShow *show = [posterShows_ objectAtIndex:x];
		FilterPosterView *poster = [[FilterPosterView alloc] initWithFrame:CGRectMake(0, 0, 65, 100)  
																  withShow:show 
															  withBookmark:YES];
		[poster addTarget:self action:@selector(filterPosterTapped:) forControlEvents:UIControlEventTouchUpInside];
		[showInfoView addSubview:poster];
		
		// TODO: grab the band headliner and fill it out here
		UILabel *showName = [[UILabel alloc] initWithFrame:CGRectMake(0, 103, 65, 10)];
		showName.font = FILTERFONT(10);
		showName.textColor = DARK_TEXT_COLOR;
		showName.adjustsFontSizeToFitWidth = YES;
		showName.minimumFontSize = 10;
		showName.text = @"Headliner";
		//showName.text = [show.showBands objectAtIndex:0].bandName;
		showName.textAlignment = UITextAlignmentLeft;
		showName.backgroundColor = [UIColor clearColor];
		[showInfoView addSubview:showName];
		
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"h:MM a"];
		
		UILabel *showTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 114, 65, 10)];
		showTime.font = FILTERFONT(10);
		showTime.textColor = DARK_TEXT_COLOR;
		showTime.adjustsFontSizeToFitWidth = YES;
		showTime.minimumFontSize = 10;
		showTime.text = [formatter stringFromDate:show.startDate];
		showTime.textAlignment = UITextAlignmentLeft;
		showTime.backgroundColor = [UIColor clearColor];
		[showInfoView addSubview:showTime];
		
		[posterScrollView addSubview:showInfoView];
	}
	
	posterScrollView.contentSize = CGSizeMake(320, (row+1) * 145);
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
}


@end
