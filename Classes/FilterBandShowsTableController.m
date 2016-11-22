//
//  FilterBandShowsTableController.m
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterBandShowsTableController.h"
#import "FilterAllShowsTableCell.h"
#import "FilterDataObjects.h"
#import "Common.h"

@implementation FilterBandShowsTableController

@synthesize bandProfile = bandProfile_;
@synthesize bandShows = bandShows_;
@synthesize pager = pager_;
@synthesize showsTable = showsTable_;
@synthesize stackController;

- (id)initWithHeader:(UIView*)header {
	
	self = [super init];
	
	if (self != nil) {		
		headerView = header;

		bandShows_ = [[NSMutableArray alloc] init];
        
        timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setDateFormat:@"EEE, MMM d h:mma"];
	}
	
	return self;
}

- (void)dealloc {
	
	[super dealloc];
}

- (void)configureTable:(UITableView *)tableView {
	
	//tableView.tableHeaderView = headerView;
	tableView.separatorColor = [UIColor blackColor];
    tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([bandShows_ count] > 0)
        return [bandShows_ count] + 1;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = nil;
    if (indexPath.row == [bandShows_ count]) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreShowsCell"] autorelease];
        
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
        
        [cellLabel release];
        
    } else {
    
        FilterAllShowsTableCell *showCell = (FilterAllShowsTableCell*)[tableView dequeueReusableCellWithIdentifier:@"bandShowsCell"];
        
        FilterShow *aShow = [bandShows_ objectAtIndex:indexPath.row];
        
        if(!showCell) {
            showCell = [[[FilterAllShowsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bandShowsCell"] autorelease];
        }
        
        if(showCell.posterView != nil) {
            [showCell.posterView release];
            showCell.posterView = nil;
        }
        
        showCell.posterView = [[FilterPosterView alloc] initWithFrame:CGRectMake(5, 5, 41, 63) withShow:aShow withBookmark:NO];
        [showCell.contentView addSubview:showCell.posterView];
        
        showCell.showLabel.text = aShow.name;
        
        NSMutableString *bandString = [[NSMutableString alloc] init];
        
        for(int i = 0; i < [aShow.showBands count]; i++) {
            if (i == [aShow.showBands count] - 1) {
                [bandString appendString:[NSString stringWithFormat:@"%@", [[aShow.showBands objectAtIndex:i] objectForKey:@"name"]]];
            }
            else {
                [bandString appendString:[NSString stringWithFormat:@"%@,", [[aShow.showBands objectAtIndex:i] objectForKey:@"name"]]];
            }
        }
        
        showCell.bandsLabel.text = bandString;
        showCell.venueLabel.text = [NSString stringWithFormat:@"%@ @ %@",[timeFormatter stringFromDate:aShow.startDate] ,aShow.showVenue.venueName];
        
        showCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell = showCell;
	}
    
    // iOS 7 fix
    [cell setBackgroundColor:[UIColor clearColor]];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    // if the row selected is the very bottom row, then load more band data
	if (indexPath.row == [bandShows_ count]) {
        if (pager_.hasNext) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:[NSString stringWithFormat:@"%d", bandProfile_.bandID] forKey:@"band_id"];
            [params setObject:[NSString stringWithFormat:@"%d", (pager_.currentPage + 1)] forKey:@"page"];
            [params setObject:[NSString stringWithFormat:@"%d", pager_.perPage] forKey:@"limit"];
            [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandShows andCallback:self];
            
            [params release];
        }
    } else { 
        
        //TODO: this will break once we get proper sectioning of the shows array
        NSNumber *showID = [[NSNumber alloc] initWithInt:[[bandShows_ objectAtIndex:indexPath.row] showID]];
        
        [self.stackController pushFilterViewWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"showDetails",@"viewToPush",showID,@"showID",nil]];
        
        [showID release];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 75;	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIImageView *backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 23)] autorelease];
	backgroundView.image = [UIImage imageNamed:@"header_bar.png"];
	
	UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 180, 23)] autorelease];
	headerLabel.font = FILTERFONT(12);
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.adjustsFontSizeToFitWidth = YES;
	headerLabel.minimumFontSize = 10;
	headerLabel.textAlignment = UITextAlignmentLeft;
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.text = @"Shows";
	[backgroundView addSubview:headerLabel];
	
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
    
    for (FilterShow *show in (NSArray*)data) {
        BOOL found = FALSE;
        for (int x = 0; x < [bandShows_ count]; x++) {
            FilterShow *oldShow = [bandShows_ objectAtIndex:x];
            if (show.showID == oldShow.showID) {
                found = TRUE;
                break;
            }
        }
        
        if (!found) {
            [bandShows_ addObject:show];   
        }            
    }
    
    [showsTable_ reloadData];
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
