//
//  FilterShowsAllShows.m
//  TheFilter
//
//  Created by John Thomas on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterShowsAllShowsView.h"
#import "FilterAllShowsTableCell.h"
#import "FilterToolbar.h"
#import "Common.h"
#import "FilterAPIOperationQueue.h"
#import "FilterGlobalImageDownloader.h"
#import "FilterPosterView.h"

#define SHOWPAGELIMIT 20

@implementation FilterShowsAllShowsView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        
        showsPageInitialized_ = NO;
		
		dayOfWeekFormatter = [[NSDateFormatter alloc] init];
		[dayOfWeekFormatter setDateFormat:@"eeee"];
		
		
		dayOfMonthFormatter = [[NSDateFormatter alloc] init];
		[dayOfMonthFormatter setDateFormat:@"d"];
		
		timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setDateFormat:@"h:mm a"];
		
		allShowsTableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, -1, 320, self.frame.size.height)];
		allShowsTableView_.delegate = self;
		allShowsTableView_.dataSource = self;
		allShowsTableView_.separatorColor = [UIColor blackColor];
		allShowsTableView_.backgroundColor = [UIColor clearColor];
        
		showsArray_ = [[NSMutableArray alloc] init];
        //showIdArray_ = [[NSMutableArray alloc] init];
		datesArray_ = [[NSMutableArray alloc] init];
        
        showsDict_ = [[NSMutableDictionary alloc] init];
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterLongStyle];
        
        lastOpType = kFilterAPITypeGeoGetEvents;
        
		[self addSubview:allShowsTableView_];
        
        indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, -45, 320, self.frame.size.height + 45) andType:kLargeIndicator];
        indicator.message.text = @"Loading...";
    }
    return self;
}

-(void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeNone];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_SearchShows];
    [[FilterToolbar sharedInstance] showUpcomingShowsMapButton:YES];
    [[FilterToolbar sharedInstance] showLogo];
    
	//[[FilterToolbar sharedInstance] showPrimaryLabel:@"All Shows"];
	//[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
}

- (void)filterPosterTapped:(id)sender {
	FilterPosterView *poster = sender;
    //TODO: switch this back
	//NSNumber *idx = [[NSNumber alloc] initWithInt:[showsArray_ indexOfObject:[NSNumber numberWithInt:poster.filterShowID]]];
    NSInteger idx = 0;
    
    for (int i = 0; i < [showsArray_ count]; i++) {
        if ([[showsArray_ objectAtIndex:i] showID] == poster.filterShowID) {
            idx = i;
            break;
        }
    }
    
    NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
    
    [data setObject:@"showExpandedPosters" forKey:@"viewToPush"];
	[data setObject:showsArray_ forKey:@"data"];
	[data setObject:[NSNumber numberWithInt:idx] forKey:@"selectedIndex"];
    
	[self.stackController pushFilterViewWithDictionary:data];
}

- (void)mapButtonTapped:(id)button {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *today = [[[NSDate alloc] init] autorelease];
    
    // Get todays year month and day, ignoring the time
    NSDateComponents *comp = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:today];
    
    // Components to add 1 day
    NSDateComponents *oneDay = [[[NSDateComponents alloc] init] autorelease];
    oneDay.day = 1;
    
    // From & To
    NSDate *fromDate = [cal dateFromComponents:comp]; // Today at midnight
    NSDate *toDate = [cal dateByAddingComponents:oneDay toDate:fromDate options:0]; // Tomorrow at midnight

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%@ < startDate AND %@ > startDate) OR (startDate < %@ AND endDate > %@)", fromDate, toDate, today, today];
    
    NSArray *todaysShows = [showsArray_ filteredArrayUsingPredicate:predicate];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"showMapView",@"viewToPush", todaysShows, @"data",nil];
    [self.stackController pushFilterViewWithDictionary:dict];
}

-(void)searchReturned:(NSString *)searchString {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    prevSearchString = [searchString retain];
    [params setObject:searchString forKey:@"search"];
    [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"page"];
    [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"limit"];
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeSearchShows andCallback:self];
    
    [params release];
}

- (void)dealloc {
    [super dealloc];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	// make sure the main toolbar displays the correct subtoolbar
	if (newSuperview == nil) {
		//[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
    }
	else {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:[NSString stringWithFormat:@"%d", SHOWPAGELIMIT] forKey:@"limit"];
        [params setObject:@"1" forKey:@"page"];
        
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeGeoGetEvents andCallback:self];
        
        [indicator startAnimating];
        [self addSubview:indicator];
        
        [params release];
	}
}

#pragma mark -
#pragma mark UITableViewDelegate/dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [datesArray_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger rows;
    
    rows = [[showsDict_ objectForKey:[datesArray_ objectAtIndex:section]] count];
    
    if (section == [datesArray_ count] - 1) {
        rows++;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = nil;
    if (indexPath.section == [datesArray_ count] - 1 &&
        indexPath.row == [[showsDict_ objectForKey:[datesArray_ objectAtIndex:indexPath.section]] count]) {
        
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
        // iOS 7 fix
        [cell setBackgroundColor:[UIColor clearColor]];
        
        [cellLabel release];
    
    } else {
        
        FilterAllShowsTableCell *showCell = (FilterAllShowsTableCell*)[tableView dequeueReusableCellWithIdentifier:@"allshowsCell"];
        
        if(!showCell) {
            showCell = [[[FilterAllShowsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"allshowsCell"] autorelease];
        }	
        
        FilterShow *aShow = [[showsDict_ objectForKey:[datesArray_ objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]; //MAKE THIS HAVE SECTIONS

        if(showCell.posterView != nil) {
            [showCell.posterView release];
            showCell.posterView = nil;
        }
        
        showCell.posterView = [[FilterPosterView alloc] initWithFrame:CGRectMake(10, 5, 41, 63) withShow:aShow withBookmark:NO];
        [showCell.contentView addSubview:showCell.posterView];
        
        [showCell.posterView addTarget:self action:@selector(filterPosterTapped:) forControlEvents:UIControlEventTouchUpInside];
        
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
        if(aShow.attending) {
            [showCell setBookmark];
        }
        else {
            [showCell removeBookmark];
        }
        
        showCell.bandsLabel.text = bandString;
        showCell.venueLabel.text = [NSString stringWithFormat:@"%@ @ %@",[timeFormatter stringFromDate:aShow.startDate] ,aShow.showVenue.venueName];
        
        showCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        cell = showCell;

    }
	
	return cell;
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
	headerLabel.text = [formatter stringFromDate:[datesArray_ objectAtIndex:section]];
	[backgroundView addSubview:headerLabel];
	
	return backgroundView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 75;	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    // if the row selected is the very bottom row, then load more band data
	if (indexPath.row == [[showsDict_ objectForKey:[datesArray_ objectAtIndex:indexPath.section]] count] && indexPath.section == [datesArray_ count] - 1) {
        if (pager_.hasNext) {
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            [params setObject:[NSString stringWithFormat:@"%d", (pager_.currentPage + 1)] forKey:@"page"];
            [params setObject:[NSString stringWithFormat:@"%d", pager_.perPage] forKey:@"limit"];
            if (lastOpType == kFilterAPITypeSearchShows) {
                [params setObject:prevSearchString forKey:@"search"];
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeSearchShows andCallback:self];
            }
            else {
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeGeoGetEvents andCallback:self];
            }
        }
    } else {
        //TODO: this will break once we get proper sectioning of the shows array
        FilterShow *aShow = [[showsDict_ objectForKey:[datesArray_ objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:@"showDetails",@"viewToPush", [NSNumber numberWithInt:aShow.showID],@"showID",nil];
        [self.stackController pushFilterViewWithDictionary:aDict];
    }
}

#pragma mark -
#pragma mark FilterAPIOperationDelegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
    
    [showsDict_ removeAllObjects];
    
    if (filterop.type == kFilterAPITypeSearchShows) {
        if (lastOpType != kFilterAPITypeSearchShows || pager_.currentPage >= ((FilterPaginator *)metadata).currentPage) {
            [showsArray_ removeAllObjects];
            [datesArray_ removeAllObjects];
        }
    }
    else {
        [indicator stopAnimatingAndRemove];
        
        if (lastOpType == kFilterAPITypeSearchShows || pager_.currentPage >= ((FilterPaginator *)metadata).currentPage) {
            [showsArray_ removeAllObjects];
            [datesArray_ removeAllObjects];
        }
    }
    if (!showsPageInitialized_) {
        [showsArray_ removeAllObjects];
        [datesArray_ removeAllObjects];
        showsPageInitialized_ = YES;
    }
    
    [pager_ release], pager_ = nil;
    pager_ = [metadata retain];

    NSSortDescriptor *sortBy = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
	NSArray *descriptors     = [NSArray arrayWithObjects:sortBy, nil];
    NSMutableSet *datesSet   = [[NSMutableSet alloc] init];
    
    for(FilterShow *show in (NSArray *)data) {
        NSString *strDate = [formatter stringFromDate:show.startDate];
        
        [datesSet addObject:[formatter dateFromString:strDate]];
    }
    
    [showsArray_ addObjectsFromArray:(NSArray *)data];
    
    //datesArray_ = [[NSMutableArray alloc] initWithArray:[[datesSet sortedArrayUsingDescriptors:descriptors] retain]];
    [datesArray_ addObjectsFromArray:[datesSet sortedArrayUsingDescriptors:descriptors]];
    
    [datesSet release];
    for (int i = 0; i < [datesArray_ count]; i++) {
        
        NSMutableArray *shows = [[NSMutableArray alloc] init];
        for(FilterShow *show in showsArray_) {
            if([[formatter stringFromDate:[datesArray_ objectAtIndex:i]] isEqualToString:[formatter stringFromDate:show.startDate]])
            {
                [shows addObject:show];
            }
        }
        [showsDict_ setObject:shows forKey:[datesArray_ objectAtIndex:i]];
    }
    
    lastOpType = filterop.type;
    
    [allShowsTableView_ reloadData];
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
    
    [indicator stopAnimatingAndRemove];
}



@end
