//
//  VenueDirectoryView.m
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "VenueDirectoryView.h"
#import "VenueDirectoryTableViewCell.h"
#import "FilterToolbar.h"
#import "FilterLocationManager.h"
#import "Common.h"


#define VENUEPAGELIMIT 20

@implementation VenueDirectoryView

@synthesize venueArray = venueArray_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		nearbyVenues_ = NO;
        venuesInitialized_ = NO;
		venueArray_ = [[NSMutableArray alloc] init];
		
		UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		headerView.image = [UIImage imageNamed:@"sub_navigation_2.png"];
		headerView.userInteractionEnabled = YES;
		venueSearchBar = [[FilterSearchBar alloc] initWithFrame:CGRectMake(10, 7, 300, 30)];
		venueSearchBar.delegate = self;
		venueSearchBar.placeholder = @"Search";
		[headerView addSubview:venueSearchBar];
		
		venueTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 414)];
		venueTable.delegate = self;
		venueTable.dataSource = self;
		venueTable.backgroundColor = [UIColor clearColor];
		venueTable.separatorColor = [UIColor blackColor];
		venueTable.tableHeaderView = headerView;
		
		[self addSubview:venueTable];
        
        sectionHeaders_            = [[NSMutableArray alloc] initWithCapacity:0];
		venueDictionary_		  = [[NSMutableDictionary alloc] initWithCapacity:1];
        
		
        [self getNearbyVenues];
        
    }
    return self;
}

-(void)getNearbyVenues {
    
    CLLocation *testLocation = [[FilterLocationManager sharedInstance] lastLocation];

   // NSLog(@"in getnearbyVenues, location= %@", testLocation);
    
    nearbyVenues_ = YES;
    lastOpType = kFilterAPITypeGeoGetVenues;
    
    NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
	
	[aDict setObject:[NSNumber numberWithFloat:[[FilterLocationManager sharedInstance] lastLocation].coordinate.latitude] forKey:@"latitude"];
	[aDict setObject:[NSNumber numberWithFloat:[[FilterLocationManager sharedInstance] lastLocation].coordinate.longitude] forKey:@"longitude"];
    [aDict setObject:[NSNumber numberWithInt:VENUEPAGELIMIT] forKey:@"limit"];
    [aDict setObject:[NSNumber numberWithInt:1] forKey:@"page"];
	
   // NSLog(@"aDict %@",aDict);
    
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:aDict andType:kFilterAPITypeGeoGetVenues andCallback:self];
    
}


- (void)dealloc {
    [super dealloc];
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];	
	
	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Venues"];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	// make sure the main toolbar displays the correct subtoolbar
	if (newSuperview == nil)
		[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	else {

	}
}




#pragma mark -
#pragma mark UITableViewDelegate/dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sectionHeaders_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == ([sectionHeaders_ count] - 1)) {
        return [[venueDictionary_ objectForKey:[sectionHeaders_ objectAtIndex:section]] count] + 1;
    }
    else {
        return [[venueDictionary_ objectForKey:[sectionHeaders_ objectAtIndex:section]] count]; 
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	 NSString *sectionKey = [sectionHeaders_ objectAtIndex:indexPath.section];
    UITableViewCell *cell = nil;
    if (indexPath.row == [[venueDictionary_ objectForKey:sectionKey] count]) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreVenuesCell"] autorelease];
        
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
        
        VenueDirectoryTableViewCell *venueCell = (VenueDirectoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"venueCell"];
        
        if(!venueCell) {
            venueCell = [[[VenueDirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"venueCell"] autorelease];
        }	
        
       
        
        FilterVenue *venue = [[venueDictionary_ objectForKey:sectionKey] objectAtIndex:indexPath.row];
        
        venueCell.venueName.text = venue.venueName;
        venueCell.venueAddress.text = venue.addressOne;
        venueCell.venueImage.userInteractionEnabled = NO;
        venueCell.venueImage.tag = indexPath.row;
        venueCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell = venueCell;
    }
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 60;	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == [[venueDictionary_ objectForKey:[sectionHeaders_ objectAtIndex:indexPath.section]] count] && indexPath.section == [sectionHeaders_ count] - 1) {
        if (pager_.hasNext) {
            
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            
            [params setObject:[NSString stringWithFormat:@"%d", (pager_.currentPage + 1)] forKey:@"page"];
            [params setObject:[NSString stringWithFormat:@"%d", pager_.perPage] forKey:@"limit"];

            if(nearbyVenues_) {
                [params setObject:[NSNumber numberWithFloat:[[FilterLocationManager sharedInstance] lastLocation].coordinate.latitude] forKey:@"latitude"];
                [params setObject:[NSNumber numberWithFloat:[[FilterLocationManager sharedInstance] lastLocation].coordinate.longitude] forKey:@"longitude"];
                
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeGeoGetVenues andCallback:self];
                
            } else {
            
                [params setObject:lastSearch_ forKey:@"searchString"];
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeVenueSearch andCallback:self];
            }
        }        
    }
    else {
        FilterVenue *venue = [[venueDictionary_ objectForKey:[sectionHeaders_ objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"venueProfile", @"viewToPush", 
                                                                        [NSNumber numberWithInt:venue.venueID], @"ID", nil];
        [self.stackController pushFilterViewWithDictionary:dict];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if([sectionHeaders_ count] == 0) {
		return @"";
	}
	
	return [sectionHeaders_ objectAtIndex:section];
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
	headerLabel.text = [sectionHeaders_ objectAtIndex:section];
	[backgroundView addSubview:headerLabel];
	
	return backgroundView;
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	
	if([textField.text length] > 0) {
	
        [lastSearch_ release];
        lastSearch_ = [textField.text retain];
        
        venuesInitialized_ = NO;
        nearbyVenues_ = NO;
        
        NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
        [params setObject:[NSString stringWithFormat:@"%@", textField.text] forKey:@"searchString"];
        [params setObject:@"1" forKey:@"page"];
        [params setObject:[NSString stringWithFormat:@"%d", VENUEPAGELIMIT] forKey:@"limit"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeVenueSearch andCallback:self];
	}
		
	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark FilterAPIOperationDelegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
    
    
    NSSortDescriptor *sortBy;
	NSArray *descriptors;
	NSArray *venues;
	NSMutableSet *chars;
	
    [pager_ release], pager_ = nil;
    pager_ = [metadata retain];
    
	// Reset arrays
    if (!venuesInitialized_ || filterop.type != lastOpType) {
        [venueDictionary_ removeAllObjects];
        [sectionHeaders_ removeAllObjects];
        venuesInitialized_ = YES;
    }
	
    // Original sort by venueName...
	sortBy		= [NSSortDescriptor sortDescriptorWithKey:@"venueName" ascending:YES selector: @selector(caseInsensitiveCompare:)];

    //JDH Lets see what the data actually looks like:
    /* for (NSUInteger i = 0; i < [data count]; i++) {
        FilterVenue *item = [data objectAtIndex:i];
        NSLog(@"venue name= %@", item.venueName);
    }
    */
    //JDH FIX use a nil sort descriptor to let venues come in sorted by server.
    descriptors = [NSArray arrayWithObjects:nil, nil];
    // Original sorted by venuName.
	//descriptors = [NSArray arrayWithObjects:sortBy, nil];
	chars		= [[NSMutableSet alloc] initWithCapacity:0];
	venues	= [(NSArray *)data sortedArrayUsingDescriptors:descriptors];
    
    // JDH how does the data look after the sort?
    /*  NSLog(@"After sort:");
    for (NSUInteger i = 0; i < [venues count]; i++) {
        FilterVenue *venue = [venues objectAtIndex:i];
        NSLog(@"venue name= %@", venue.venueName);
    }
     */
    
    switch (filterop.type) {
            
        case kFilterAPITypeVenueSearch: {
            
            
            for(FilterVenue *aBand in venues) {
                
                NSString *firstChar = [[aBand.venueName substringWithRange:NSMakeRange(0, 1)] uppercaseString];
                
                //a group already exists for this letter - just append it
                if([venueDictionary_ objectForKey:firstChar]) {
                    
                    NSMutableArray *bandArray = [venueDictionary_ objectForKey:firstChar];
                    BOOL duplicate = NO;
                    for(FilterVenue *aVenue in bandArray) {
                        if(aBand.venueID == aVenue.venueID) {
                            duplicate = YES;
                            break;
                        }
                    }
                    
                    if(duplicate == NO) {
                        [bandArray addObject:aBand];
                    }
                } else { //doesn't exist - create the section header object too
                    
                    NSMutableArray *venueArray = [[NSMutableArray alloc] init];
                    [venueArray addObject:aBand];
                    [venueDictionary_ setObject:venueArray forKey:firstChar];
                    [sectionHeaders_ addObject:firstChar];
                    [sectionHeaders_ sortUsingSelector:@selector(caseInsensitiveCompare:)];
                    [venueArray release];
                    
                    
                }
                
                
            }
            

        }
            break;
            
        case kFilterAPITypeGeoGetVenues: {
            if([sectionHeaders_ count] == 0) {
                [sectionHeaders_ addObject:@"Local Venues"];
                [venueDictionary_ setObject:venues forKey:[sectionHeaders_ objectAtIndex:0]];
            } else {
            
                NSMutableArray *venueComposite = [[NSMutableArray alloc] init];
                [venueComposite addObjectsFromArray:[venueDictionary_ objectForKey:@"Local Venues"]];
                [venueComposite addObjectsFromArray:venues];
                [venueDictionary_ setObject:venueComposite forKey:[sectionHeaders_ objectAtIndex:0]];
                [venueComposite release];
            }
            
            break;
        }
        default:
            break;
    }
    
    lastOpType = filterop.type;
    
	
    
    [venueTable reloadData];

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
