//
//  MoreFeaturedView.m
//  TheFilter
//
//  Created by Ben Hine on 2/25/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "MoreFeaturedView.h"
#import "FilterToolbar.h"
#import "Common.h"
#import "FeaturedTrackTableCell.h"
#import "FilterAPIOperationQueue.h"
#import "FilterAPIOperationQueue.h"

@implementation MoreFeaturedView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		featuredTable_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		featuredTable_.dataSource = self;
		featuredTable_.delegate = self;
		featuredTable_.separatorColor = [UIColor blackColor];
		
		UIView *background = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		background.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		featuredTable_.backgroundView = background;
		
		
		trackArray = [[NSMutableArray alloc] init];
		
		[self addSubview:featuredTable_];
    }
    return self;
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	
	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Featured"];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
	
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	[trackArray removeAllObjects];
	
	if (newSuperview == nil) {
		[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	} else {

		NSDictionary *params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [[UIDevice currentDevice] identifierForVendor]] forKey:@"udid"];
        
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeGeoGetFeaturedBands andCallback:self];
	}

}

- (void)dealloc {
    [super dealloc];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	FilterTrack *track = [trackArray objectAtIndex:indexPath.row];
	
	NSMutableDictionary *viewData = [[NSMutableDictionary alloc] init];
	[viewData setObject:@"songDetails" forKey:@"viewToPush"];
	[viewData setObject:track forKey:@"data"];
	[self.stackController pushFilterViewWithDictionary:viewData];
	
	[viewData release];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FeaturedTrackTableCell *cell = (FeaturedTrackTableCell*)[tableView dequeueReusableCellWithIdentifier:@"tableCell"];
	
	if(!cell) {
		cell = [[[FeaturedTrackTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCell"] autorelease];
	}
	

	FilterTrack *track = [trackArray objectAtIndex:indexPath.row];
	
	cell.artistLabel.text = track.trackArtist;
	cell.trackLabel.text = track.trackTitle;
	cell.featuredTrack = track;
	
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [trackArray count];
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	
	switch (filterop.type) {
			
		case kFilterAPITypeGeoGetFeaturedBands: {
			
			NSArray *bandHackList = data;

			for ( FilterFeaturedBand *featureHack in bandHackList) {
				
				FilterBand *bandHack = featureHack.featuredBand;
				NSDictionary *params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", bandHack.bandID] forKey:@"band_id"];
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandTracks andCallback:self];
			}
		}
		break;	
			
		case kFilterAPITypeBandTracks: {

			[trackArray addObjectsFromArray:(NSArray*)data];
			
			[featuredTable_ reloadData];
		}
		break;
			
		default:
			break;
	}
}

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFailWithError:(NSError*)err {
	
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
