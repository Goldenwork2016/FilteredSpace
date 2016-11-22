//
//  NotificationsView.m
//  TheFilter
//
//  Created by Patrick Hernandez on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotificationsView.h"
#import "FilterToolbar.h"
#import "NotificationsTableViewCell.h"

@implementation NotificationsView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        tableView_ = [[UITableView alloc] initWithFrame:frame];
		tableView_.delegate = self;
		tableView_.dataSource = self;
		
		UIView *background = [[[UIView alloc] initWithFrame:frame] autorelease];
		background.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1.0];
		tableView_.backgroundView = background;
		tableView_.separatorColor = [UIColor blackColor];
		[self addSubview:tableView_];
    }
    return self;
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Notifications"];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
	
	//[[FilterToolbar sharedInstance] setTitle:@"Notifications"];
	//[[FilterToolbar sharedInstance] showLogo];
	
}
#pragma mark -
#pragma mark UITableViewDataSource conformance
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NotificationsTableViewCell *cell = (NotificationsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
	
	if(!cell) {
		cell = [[[NotificationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationCell"] autorelease];
	}	
	
	[[cell leftImageView] setImage:[UIImage imageNamed:@"sm_no_image.png"]];
	
	if(indexPath.row == 0) {
		[[cell nameLabel] setText:@"Preston Leatherman"];
		[[cell notificationLabel] setText:@"is now following you."];
		[[cell button] setTitle:@"Follow" forState:UIControlStateNormal];
		//[[cell followButton] addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];
		//TODO: set button action
	}
	else if (indexPath.row == 1) {
		[[cell nameLabel] setText:@"Katie Kerkover -"];
		[[cell notificationLabel] setText:@"01/11/11"];
		[[cell locationLabel] setText:@"@emos"];
		[[cell button] setTitle:@"Review" forState:UIControlStateNormal];
		[[cell button] addTarget:self action:@selector(reviewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 68.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

#pragma mark -
#pragma mark Button Clicks
- (void) reviewButtonClicked:(id)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"notifications",@"viewToPush",nil];
	[self.stackController pushFilterViewWithDictionary:dict];
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    [super dealloc];
}


@end
