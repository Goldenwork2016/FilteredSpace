//
//  FilterShowsDetailsView.m
//  TheFilter
//
//  Created by John Thomas on 2/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterShowsDetailsView.h"
#import "FilterToolbar.h"
#import "FilterShowDetailsTableCell.h"
#import "FilterDataObjects.h"
#import <QuartzCore/QuartzCore.h>
#import "FilterGlobalImageDownloader.h"
#import "FilterAPIOperationQueue.h"
#import "FilterAPIOperationQueue.h"

#define kShowInfoSection	0
#define kVenueInfoSection	1
#define kVenueLineupSection	2

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation FilterShowsDetailsView
@synthesize showID = showID_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.window.backgroundColor = [UIColor blackColor];
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 110)];
        headerView.backgroundColor  = [UIColor blackColor];
		
		posterImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 65, 100)];
		posterImage.image = [UIImage imageNamed:@"no_poster_avatar.png"];
		//posterImage.layer.cornerRadius = 5;
		posterImage.clipsToBounds = YES;
		[headerView addSubview:posterImage];
		
//		venueLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 6, 165, 14)];
//		venueLabel.font = FILTERFONT(13);
//		venueLabel.textColor = DARK_TEXT_COLOR;
//		venueLabel.adjustsFontSizeToFitWidth = YES;
//		venueLabel.minimumFontSize = 10;
//		venueLabel.textAlignment = UITextAlignmentLeft;
//		venueLabel.backgroundColor = [UIColor clearColor];
//		[headerView addSubview:venueLabel];
		
//		bandLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 22, 165, 18)];
//		bandLabel.font = FILTERFONT(16);
//		bandLabel.textColor = LIGHT_TEXT_COLOR;
//		bandLabel.adjustsFontSizeToFitWidth = YES;
//		bandLabel.minimumFontSize = 10;
//		bandLabel.textAlignment = UITextAlignmentLeft;
//		bandLabel.backgroundColor = [UIColor clearColor];
//		[headerView addSubview:bandLabel];
    
        showLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 6, 165, 18)];
		showLabel.font = FILTERFONT(17);
		showLabel.textColor = LIGHT_TEXT_COLOR;
		showLabel.adjustsFontSizeToFitWidth = YES;
		showLabel.minimumFontSize = 10;
		showLabel.textAlignment = UITextAlignmentLeft;
		showLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:showLabel];
        
        attendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 29, 165, 18)];
		attendingLabel.font = FILTERFONT(12);
		attendingLabel.textColor = DARK_TEXT_COLOR;
		attendingLabel.adjustsFontSizeToFitWidth = YES;
		attendingLabel.minimumFontSize = 10;
		attendingLabel.textAlignment = UITextAlignmentLeft;
		attendingLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:attendingLabel];
        
        attendingIndicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(106, 83, 21, 21) andType:kSmallIndicator];
        [headerView addSubview:attendingIndicator];
        
        attendingButton = [UIButton buttonWithType:UIButtonTypeCustom];
		attendingButton.frame = CGRectMake(80, 81, 73, 25);
		attendingButton.titleLabel.font = FILTERFONT(13);
		[attendingButton setTitle:@"Attend" forState:UIControlStateNormal];
		[attendingButton setTitle:@"Attending" forState:UIControlStateSelected];
		[attendingButton setTitle:@"Attending" forState:(UIControlStateSelected | UIControlStateHighlighted)];
		[attendingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[attendingButton setBackgroundImage:[UIImage imageNamed:@"band_profile_follow_button.png"] forState:UIControlStateNormal];
        [attendingButton setBackgroundImage:[[UIImage imageNamed:@"pressed_down_band_profile_follow_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateHighlighted];
        [attendingButton setBackgroundImage:[[UIImage imageNamed:@"selected_band_profile_follow_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:(UIControlStateSelected)];
        [attendingButton setBackgroundImage:[[UIImage imageNamed:@"selected_band_profile_follow_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:(UIControlStateSelected | UIControlStateHighlighted)];
        [headerView addSubview:attendingButton];
		[attendingButton addTarget:self action:@selector(attendPushed:) forControlEvents:UIControlEventTouchUpInside];
        
        shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shareButton.frame = CGRectMake(158, 81, 73, 25);
		shareButton.titleLabel.font = FILTERFONT(13);
		[shareButton setTitle:@"share" forState:UIControlStateNormal];
		[shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[shareButton setBackgroundImage:[UIImage imageNamed:@"band_profile_follow_button.png"] forState:UIControlStateNormal];
        //[headerView addSubview:shareButton];
        
		showDetailsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height - 45) style:UITableViewStyleGrouped];
		showDetailsTable.backgroundColor = [UIColor blackColor];
		showDetailsTable.separatorColor = [UIColor blackColor];
		showDetailsTable.delegate = self;
		showDetailsTable.dataSource = self;
		
        //JDH
        headerView.backgroundColor = [UIColor blackColor];
		[showDetailsTable setTableHeaderView:headerView];
		showDetailsTable.backgroundColor = [UIColor blackColor];
		[self addSubview:showDetailsTable];
        
        toolBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btm_bar.png"]];
        toolBar.frame = CGRectMake(0, 365, 320, 51);
        toolBar.userInteractionEnabled = YES;
        [self addSubview:toolBar];
        
		checkInButton = [[UIButton alloc] initWithFrame:CGRectMake(75, 6, 170, 41)];
		[checkInButton setBackgroundImage:[UIImage imageNamed:@"checkin_button.png"] forState:UIControlStateNormal];
		[checkInButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_checkin_button.png"] forState:UIControlStateHighlighted];
        [checkInButton setBackgroundImage:[UIImage imageNamed:@"disabled_check_in_button.png"] forState:UIControlStateDisabled];
		[checkInButton addTarget:self action:@selector(checkInButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[toolBar addSubview:checkInButton];
        
		dayFormat_ = [[NSDateFormatter alloc] init];
		[dayFormat_ setDateFormat:@"MMMM d, yyyy"];
		
		timeFormat_ = [[NSDateFormatter alloc] init];
		[timeFormat_ setDateFormat:@"h:mm a"];
		
        show = nil;
        
        indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height) andType:kLargeIndicator];
        indicator.message.text = @"Loading...";
        
        [headerView release];
	}
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	// make sure the main toolbar displays the correct subtoolbar
	if (newSuperview == nil) {
		//[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
    }
	else {
        //TODO: get the new show when we get in
        attendingButton.userInteractionEnabled = NO;
        checkInButton.userInteractionEnabled = NO;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:showID_ forKey:@"showID"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:dict andType:kFilterAPITypeShowDetails andCallback:self];
        
        [self addSubview:indicator];
        [indicator startAnimating];
        
        [dict release];
	}
}

-(void)setShow:(FilterShow *)aShow {
    [show release];
    show = [aShow retain];
    
    showLabel.text = show.name;
    attendingLabel.text = [NSString stringWithFormat:@"%@ Attending", [show.attendingCount stringValue]];
    [[FilterToolbar sharedInstance] showPrimaryLabel:show.name];
    attendingButton.selected = show.attending;
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
	[[FilterToolbar sharedInstance] showSecondaryLabel:[formatter stringFromDate:show.startDate]];
    
	if (show.posterURL != nil)
		posterImage.image = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:show.posterURL object:self selector:@selector(imageDownloaded:)];
    
    checkInButton.enabled = !aShow.checkedIn;
    
    [showDetailsTable reloadData];
}

-(void)imageDownloaded:(id)sender {
	posterImage.image = [(NSNotification*)sender image];
}

-(void)attendPushed:(id)sender {
    
    [attendingIndicator startAnimating];
    [UIView animateWithDuration:0.3 animations:^{ attendingButton.alpha = 0.0;}];
    attendingButton.userInteractionEnabled = NO;
    if(attendingButton.selected) {
        NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:show.showID] forKey:@"showID"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeShowUnbookmark andCallback:self];
	} else {
        NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:show.showID] forKey:@"showID"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeShowBookmark andCallback:self];
    }
}

- (void)checkInButtonPressed:(id)sender {
	if (show != nil) {
		
		NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
		[data setObject:@"showCheckIn" forKey:@"viewToPush"];
		[data setObject:show forKey:@"data"];
		[self.stackController pushFilterViewWithDictionary:data];
	}
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];	
	
	//[[FilterToolbar sharedInstance] showPrimaryLabel:@""];
	//[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
}

#pragma mark -
#pragma mark UITableViewDelegate/dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([show.showBands count] > 0) ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 1;
	switch (section) {
		case kShowInfoSection:
			rows = (show == nil) ? 0 : 1;
			break;
			
		case kVenueInfoSection:
			rows = (show == nil) ? 0 : 1;
			break;
			
		case kVenueLineupSection:
			rows = [show.showBands count];
	}
	
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FilterShowDetailsTableCell *cell = (FilterShowDetailsTableCell*)[tableView dequeueReusableCellWithIdentifier:@"showDetailsCell"];
	
	if(!cell) {
		cell = [[[FilterShowDetailsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"showDetailsCell"] autorelease];
	}	
	
	switch (indexPath.section) {
		case kShowInfoSection:
			cell.primaryLabel.text = [NSString stringWithFormat:@"Date: %@", [dayFormat_ stringFromDate:show.startDate]];
			cell.secondaryLabel.text = [NSString stringWithFormat:@"Time: %@", [timeFormat_ stringFromDate:show.startDate]];
			cell.tertiaryLabel.text = [NSString stringWithFormat:@"Price: %@", show.price];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
			
		case kVenueInfoSection:
			cell.primaryLabel.text = show.showVenue.venueName;
			cell.secondaryLabel.text = show.showVenue.addressOne;
			// cell.tertiaryLabel.text = [NSString stringWithFormat:@"%@, %@ %@", show.showVenue.city, show.showVenue.venueState, show.showVenue.zip];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell showChevron:YES];
            cell.chevronView.frame = CGRectMake(290, 23, 9, 14);
			break;
			
		case kVenueLineupSection: {
            cell.lineupLabel.text = [[show.showBands objectAtIndex:indexPath.row] objectForKey:@"name"];
            if ([[show.showBands objectAtIndex:indexPath.row] objectForKey:@"id"] != [NSNull null]) {
                [cell showChevron:YES];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
		}
		break;
			
		default:
			break;
	}
			
    //JDH
    cell.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1.0];
    
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
			
	UIView *backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    backgroundView.backgroundColor = [UIColor blackColor];
	
	UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 7, 180, 25)] autorelease];
	headerLabel.font = FILTERFONT(18);
	headerLabel.textColor = LIGHT_TEXT_COLOR;
	headerLabel.adjustsFontSizeToFitWidth = YES;
	headerLabel.minimumFontSize = 10;
	headerLabel.textAlignment = UITextAlignmentLeft;
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.shadowColor = [UIColor blackColor];
	headerLabel.shadowOffset = CGSizeMake(0, 1);
	[backgroundView addSubview:headerLabel];
	
	switch (section) {
		case kVenueInfoSection:
			headerLabel.text = @"Venue";
			break;
			
		case kVenueLineupSection:
			headerLabel.text = @"Line Up";
			break;
			
		default:
			break;
	}
	
	return backgroundView;
}
 
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section != kShowInfoSection) {
		return 35;
	}
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section != kVenueLineupSection) {
		return 60;
	}
	
	return 40;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kVenueLineupSection) {
        
        if ([[show.showBands objectAtIndex:indexPath.row] objectForKey:@"id"] != [NSNull null]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:@"bandProfile" forKey:@"viewToPush"];
            [dict setObject:[[show.showBands objectAtIndex:indexPath.row] objectForKey:@"id"] forKey:@"ID"];
            
            [self.stackController pushFilterViewWithDictionary:dict];
            
            [dict release];
        }
    }
    if (indexPath.section == kVenueInfoSection) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"venueProfile" forKey:@"viewToPush"];
        [dict setObject:[NSNumber numberWithInt:show.showVenue.venueID] forKey:@"ID"];
            
        [self.stackController pushFilterViewWithDictionary:dict];
            
        [dict release];
    }
}

#pragma mark -
#pragma mark FilterAPIOperationDelegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
    
    if(filterop.type == kFilterAPITypeShowBookmark) {
		
		attendingButton.selected = YES;
		show.attendingCount = [NSNumber numberWithInt:[show.attendingCount intValue] + 1];
        attendingLabel.text = [NSString stringWithFormat:@"%@ Attending", [show.attendingCount stringValue]];
        [UIView animateWithDuration:0.3 animations:^{ attendingButton.alpha = 1.0;} completion:^(BOOL finished){ [attendingIndicator stopAnimating]; }];
		
	} else if (filterop.type == kFilterAPITypeShowUnbookmark) {
		attendingButton.selected = NO;
		show.attendingCount = [NSNumber numberWithInt:[show.attendingCount intValue] - 1];
        attendingLabel.text = [NSString stringWithFormat:@"%@ Attending", [show.attendingCount stringValue]];
        [UIView animateWithDuration:0.3 animations:^{ attendingButton.alpha = 1.0;} completion:^(BOOL finished){ [attendingIndicator stopAnimating]; }];
	} else {
        [self setShow:(FilterShow *)data];
        [indicator stopAnimatingAndRemove];
    }
	
    attendingButton.userInteractionEnabled = YES;
    checkInButton.userInteractionEnabled = YES;
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
    
    attendingButton.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.3 animations:^{ attendingButton.alpha = 1.0;} completion:^(BOOL finished){ [indicator stopAnimating]; }];
    [indicator stopAnimatingAndRemove];
}

@end
