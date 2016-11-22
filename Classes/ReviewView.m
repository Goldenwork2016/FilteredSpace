//
//  ReviewView.m
//  TheFilter
//
//  Created by Patrick Hernandez on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReviewView.h"
#import "FilterToolbar.h"
#import "ReviewTableViewCell.h"
#import "FilterAPIOperationQueue.h"
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1]

#define BACKGROUND_COLOR [UIColor clearColor]

#define CELL_HEIGHT 89.0f

@implementation ReviewView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        tableView_					= [[UITableView alloc] initWithFrame:frame];
		tableView_.backgroundColor  = [UIColor clearColor];
		tableView_.delegate			= self;
		tableView_.dataSource		= self;
		
		[tableView_ setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[self addSubview:tableView_];
		
		[self setUpTableHeader];
		
		[self setUpTableFooter];
    }
    return self;
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:NO];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeCancel];
	[[FilterToolbar sharedInstance] setRightButtonWithType:kToolbarButtonTypeDone];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Review"];
}

- (void) willRemoveSubview:(UIView *)subview
{
	// NSLog(@"Removing subview from view");
	
}

#pragma mark -
#pragma mark Configure tableView_

- (void) setUpTableHeader {
	
	UIView *headerView;
	UIImageView *imageView;
	UILabel *venueLabel;
	UILabel *nameLabel;
	
	headerView			= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
	imageView			= [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 48, 48)];
	venueLabel			= [[UILabel alloc] initWithFrame:CGRectMake(68, 0, 250, 20)];
	nameLabel			= [[UILabel alloc] initWithFrame:CGRectMake(68, 20, 250, 20)];
	
	// Set up the image view
	[imageView setImage:[UIImage imageNamed:@"sm_no_image.png"]];
	[imageView setBackgroundColor:[UIColor purpleColor]];
	[[imageView layer] setCornerRadius:5.0];
	
	// Set up the venue label
	[venueLabel setText:@"Emos Presents"];
	[venueLabel setTextColor:DARK_TEXT_COLOR];
	[venueLabel setBackgroundColor:BACKGROUND_COLOR];
	[venueLabel setFont:FILTERFONT(13)];
	
	// Set up the name label
	[nameLabel setText:@"Katie Kerkhover"];
	[nameLabel setTextColor:LIGHT_TEXT_COLOR];
	[nameLabel setBackgroundColor:BACKGROUND_COLOR];
	[nameLabel setFont:FILTERFONT(18)];
	
	// Add subviews to header
	[headerView addSubview:venueLabel];
	[headerView addSubview:imageView];
	[headerView addSubview:nameLabel];
	
	[tableView_ setTableHeaderView:headerView];

	// Cleanup
	[nameLabel release];
	[venueLabel release];
	[imageView release];
	[headerView release];
	
}

- (void) setUpTableFooter {
	UIView *footerView;
	UILabel *venueLabel;
	UILabel *venueAddressLabel;
	UIView *seperator;
	UIView *seperatorShadow;
	
	footerView		  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 89)];
	venueLabel		  = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 225, 20)];
	venueAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 225, 20)];
	
	// Set up the seperator
	seperator		  = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 1)];
	seperatorShadow   = [[UIView alloc] initWithFrame:CGRectMake(10, 1, 300, 1)];
	
	[seperator setBackgroundColor:[UIColor blackColor]];
	
	[seperatorShadow setBackgroundColor:[UIColor grayColor]];
	[seperatorShadow setAlpha:0.2];
	
	[footerView addSubview:seperator];
	[footerView addSubview:seperatorShadow];

	// Set up the venue label
	[venueLabel setBackgroundColor:BACKGROUND_COLOR];
	[venueLabel setTextColor:LIGHT_TEXT_COLOR];
	[venueLabel setFont:FILTERFONT(18)];
	[venueLabel setShadowColor:[UIColor blackColor]];
	[venueLabel setShadowOffset:CGSizeMake(0, 1)];
	[venueLabel setText:@"Emos"];
	
	[footerView addSubview:venueLabel];

	//set up the venue address label
	[venueAddressLabel setBackgroundColor:BACKGROUND_COLOR];
	[venueAddressLabel setTextColor:LIGHT_TEXT_COLOR];
	[venueAddressLabel setFont:FILTERFONT(14)];
	[venueAddressLabel setShadowColor:[UIColor blackColor]];
	[venueAddressLabel setShadowOffset:CGSizeMake(0, 1)];
	[venueAddressLabel setText:@"603 Red River Street"];
	
	[footerView addSubview:venueAddressLabel];
	
	//vote button
	UIButton *voteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[voteButton setFrame:CGRectMake(240, 10, 69, 69)];
	[voteButton setImage:[UIImage imageNamed:@"tap_to_vote_button.png"] forState:UIControlStateNormal];
	[voteButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_tap_to_vote.png"] forState:UIControlStateHighlighted];
	[voteButton addTarget:self action:@selector(voteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	voteButton.tag = 999; //venue button type - for determining where to send API call
	[footerView addSubview:voteButton];
	
	[tableView_ setTableFooterView:footerView];
	
	// Cleanup
	[venueLabel release];
	[seperator release];
	[seperatorShadow release];
	[footerView release];
}

#pragma mark -
#pragma mark Button Click Methods
- (void)donePushed:(id)button {
	[stackController popNavigationStack];
}

- (void) voteButtonClicked:(id)sender {
	
	//NSLog(@"sender: %@", [[sender superview] description]);
	
	if([sender tag] == 1) {//band type
		
	} else if([sender tag] == 999) {//venue type
		
	}
	
	//[self.stackController showRatingsActionSheetForView:self];
}


//TODO: figure out how to get a pointer to the object that's being rated
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"ButtonIndex %d", buttonIndex);
	switch (buttonIndex) {
		case 0: //rox
			break;
		case 1: //sux
			break;
		case 2: //cancel
			
			break;
		default:
			break;
	}
	
	
}




#pragma mark -
#pragma mark UITableViewDataSource/UITableViewDelegate conformance
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ReviewTableViewCell *cell = (ReviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"reviewCell"];
	
	if(!cell) {
		cell = [[[ReviewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reviewCell"] autorelease];
	}	
	
	if (indexPath.row == 1) {

		[[cell nameLabel] setText:@"Benton Blount"];
	}
	else {
		[[cell nameLabel] setText:@"Katie Kerkhover"];
	}

	[[cell voteButton] addTarget:self action:@selector(voteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	cell.voteButton.tag = 1; //artist type tag (for determining where to send the API call)
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return CELL_HEIGHT;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//TODO: nothing
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
	//[tableView_ release];
	[keyboardToolbar release];
    [super dealloc];
}

#pragma mark -
#pragma mark FilterAPIOperationDelegate methods

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
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
