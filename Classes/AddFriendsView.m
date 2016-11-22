//
//  AddFriendsView.m
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddFriendsView.h"
#import "FilterToolbar.h"
#import "AddFriendsTableViewCell.h"
#import "FilterDataObjects.h"

@implementation AddFriendsView

@synthesize profileArray = profileArray_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		profileArray_ = [[NSMutableArray alloc] init];
	
		friendsTable				= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		friendsTable.delegate		= self;
		friendsTable.dataSource		= self;
		friendsTable.separatorColor = [UIColor blackColor];
		friendsTable.backgroundColor = [UIColor clearColor];
				
		UIImageView *headerView		= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		headerView.image			= [UIImage imageNamed:@"sub_navigation_2.png"];
		headerView.userInteractionEnabled = YES;
		searchBar_					= [[FilterSearchBar alloc] initWithFrame:CGRectMake(10, 7, 300, 30)];
		searchBar_.delegate			= self;
		searchBar_.placeholder		= @"Search";
		
		[headerView addSubview:searchBar_];
		[friendsTable setTableHeaderView:headerView];
		[self addSubview:friendsTable];
        
        [headerView release];
		
    }
    return self;
}

-(void)configureToolbar {
	FilterToolbar* toolbar = [FilterToolbar sharedInstance];
	[toolbar showPrimaryLabel:@"Find Friends"];
	[toolbar showSecondaryLabel:nil];
	[toolbar showPlayerButton:YES];
	[toolbar setLeftButtonWithType:kToolbarButtonTypeBackButton];
	
	[toolbar showSecondaryToolbar:kSecondaryToolbar_None];
	
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	// make sure the main toolbar displays the correct subtoolbar
	if (newSuperview == nil)
		[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	else {
		
	}
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

#pragma mark -
#pragma mark UITableViewDelegate/UITableViewDatasource conformance
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	FilterFanAccount *profile = [profileArray_ objectAtIndex:indexPath.row];

	[dict setObject:@"fanProfile" forKey:@"viewToPush"];
	[dict setObject:profile forKey:@"data"];

	[self.stackController pushFilterViewWithDictionary:dict];
    
    [dict release];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	AddFriendsTableViewCell *cell = (AddFriendsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"addFriendCell"];
	
	if(!cell) {
		cell = [[[AddFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addFriendCell"] autorelease];
	}	
	
	FilterFanAccount *profile = [profileArray_ objectAtIndex:indexPath.row];
	
	cell.profileName.text = profile.userName;
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [profileArray_ count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	
	if([textField.text length] > 0) {
		
		NSMutableDictionary *paramDict = [[[NSMutableDictionary alloc] init] autorelease];
		[paramDict setObject:textField.text forKey:@"searchString"];
		//[paramDict setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];
        [paramDict setObject:[[UIDevice currentDevice] identifierForVendor] forKey:@"udid"];
        
		//[[FilterAPIOperationQueue sharedInstance] FilterAPIOperationSearchAccountWithParams:paramDict withCallback:self];
	}
	
	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark FilterAPIOperationDelegate methods

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	[profileArray_ removeAllObjects];
	
	[profileArray_ addObjectsFromArray:(NSArray*)data];
	[friendsTable reloadData];
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
