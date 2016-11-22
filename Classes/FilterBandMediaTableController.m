//
//  FilterBandMediaTableController.m
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterBandMediaTableController.h"
#import "FilterBandMediaTableCell.h"
#import "Common.h"

@implementation FilterBandMediaTableController

@synthesize bandProfile = bandProfile_;
@synthesize bandTracks = bandTracks_;
@synthesize pager = pager_;
@synthesize tracksTable = tracksTable_;
@synthesize stackController;


- (id)initWithHeader:(UIView*)header {
	
	self = [super init];
	
	if (self != nil) {
		headerView = header;
		
		bandTracks_ = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	
	[super dealloc];
}

- (void)configureTable:(UITableView *)tableView {
	
	tableView.separatorColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    tableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([bandTracks_ count] > 0)
        return [bandTracks_ count] + 1;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = nil;
    if (indexPath.row == [bandTracks_ count]) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreTracksCell"] autorelease];
        
        UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,14,300,40)];
        cellLabel.backgroundColor = [UIColor clearColor];
        cellLabel.font = FILTERFONT(15);
        cellLabel.textAlignment = UITextAlignmentCenter;
        
        if (pager_.hasNext) {
            cellLabel.text = @"More..";
            cellLabel.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1];
        } else  {
            cellLabel.text = @"No more results";
            cellLabel.textColor = [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1];
        }
        
        [cell.contentView addSubview:cellLabel];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // iOS 7 fix
        [cell setBackgroundColor:[UIColor clearColor]];
        
        [cellLabel release];
        
    } else {
        if (indexPath.section == 0) {
            FilterBandMediaTableCell *trackCell = (FilterBandMediaTableCell*)[tableView dequeueReusableCellWithIdentifier:@"bandMediaCell"];
            if(!trackCell) {
                trackCell = [[[FilterBandMediaTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bandMediaCell"] autorelease];
            }
            
            FilterTrack* track = [bandTracks_ objectAtIndex:indexPath.row];
            
            NSInteger duration = [track.durationSeconds intValue];
            NSInteger mins = duration / 60;
            NSInteger secs = duration % 60;
            
            trackCell.bandTrack = track;
            trackCell.songTitle.text = track.trackTitle;
            trackCell.songDuration.text = [NSString stringWithFormat:@"%d:%02d", mins, secs];
            
            cell = trackCell;
        }
    }
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // if the row selected is the very bottom row, then load more band data
	if (indexPath.row == [bandTracks_ count]) {
        if (pager_.hasNext) {
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            [params setObject:[NSString stringWithFormat:@"%d", bandProfile_.bandID] forKey:@"band_id"];
            [params setObject:[NSString stringWithFormat:@"%d", (pager_.currentPage + 1)] forKey:@"page"];
            [params setObject:[NSString stringWithFormat:@"%d", pager_.perPage] forKey:@"limit"];
            [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandTracks andCallback:self];
        }
    } else {     
        
        FilterTrack *track = [bandTracks_ objectAtIndex:indexPath.row];
        
        NSMutableDictionary *viewData = [[NSMutableDictionary alloc] init];									 
        [viewData setObject:@"songDetails" forKey:@"viewToPush"];
        [viewData setObject:track forKey:@"data"];
        
        [self.stackController pushFilterViewWithDictionary:viewData];
        
        [viewData release];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	UIImageView *backgroundView             = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 23)] autorelease];
	backgroundView.image                    = [UIImage imageNamed:@"header_bar.png"];
	
	UILabel *headerLabel                    = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 180, 23)] autorelease];
	headerLabel.font                        = FILTERFONT(12);
	headerLabel.textColor                   = [UIColor whiteColor];
	headerLabel.adjustsFontSizeToFitWidth   = YES;
	headerLabel.minimumFontSize             = 10;
	headerLabel.textAlignment               = UITextAlignmentLeft;
	headerLabel.backgroundColor             = [UIColor clearColor];
    
    [backgroundView addSubview:headerLabel];
	
    headerLabel.text = @"Songs";
    
	return backgroundView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 23;
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
    
    [pager_ release], pager_ = nil;
    pager_ = [metadata retain];
    
    for (FilterTrack *track in (NSArray*)data) {
        BOOL found = FALSE;
        for (int x = 0; x < [bandTracks_ count]; x++) {
            FilterTrack *oldTrack = [bandTracks_ objectAtIndex:x];
            if (track.trackID == oldTrack.trackID) {
                found = TRUE;
                break;
            }
        }
        
        if (!found) {
            [bandTracks_ addObject:track];   
        }            
    }
    
    [tracksTable_ reloadData];
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
