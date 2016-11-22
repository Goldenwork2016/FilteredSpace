//
//  BandsDirectoryView.m
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BandsDirectoryView.h"
#import "FilterToolbar.h"
#import "BandsDirectoryTableViewCell.h"
#import "FilterLocationManager.h"
#import "Common.h"

#define BANDPAGELIMIT 20

@interface BandsDirectoryView () 
-(void)getNearbyBands;
@end
    
@implementation BandsDirectoryView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
        bandsInitialized_ = NO;
        
		tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 414)];
		tableView_.backgroundColor  = [UIColor clearColor];
		tableView_.delegate			= self;
		tableView_.dataSource		= self;
		
		[self addSubview:tableView_];
		
		UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		headerView.image = [UIImage imageNamed:@"sub_navigation_2.png"];
		headerView.userInteractionEnabled = YES;
		searchBar_ = [[FilterSearchBar alloc] initWithFrame:CGRectMake(10, 7, 300, 30)];
		searchBar_.delegate = self;
		searchBar_.placeholder = @"Search";
		
		[headerView addSubview:searchBar_];
		
		[tableView_ setTableHeaderView:headerView];
		
        [headerView release];
        
		tableView_.separatorColor = [UIColor blackColor];
		bandArray_				  = [[NSMutableArray alloc] initWithCapacity:0];
		sectionHeaders            = [[NSMutableArray alloc] initWithCapacity:0];
		bandDictionary_			  = [[NSMutableDictionary alloc] initWithCapacity:1];
        
        lastOpType = kFilterAPITypeGeoGetBands;
        
        indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height) andType:kLargeIndicator];
		indicator.message.text = @"Loading...";
        
        [self getNearbyBands];
    }
    return self;
}

-(void)getNearbyBands {
	
	NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
	
	[aDict setObject:[NSNumber numberWithFloat:[[FilterLocationManager sharedInstance] lastLocation].coordinate.latitude] forKey:@"latitude"];
	[aDict setObject:[NSNumber numberWithFloat:[[FilterLocationManager sharedInstance] lastLocation].coordinate.longitude] forKey:@"longitude"];
	
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:aDict andType:kFilterAPITypeGeoGetBands andCallback:self];
	
    [self addSubview:indicator];
    [indicator startAnimating];
    
    [aDict release];
}


-(void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Bands"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [indicator release];
    [bandDictionary_ release];
    [sectionHeaders release];
    [bandArray_ release];
    [tableView_ release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource/UITableViewDelegate conformance
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sectionHeaders count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == ([sectionHeaders count] - 1))
        return [[bandDictionary_ objectForKey:[sectionHeaders objectAtIndex:section]] count] + 1;
    else
        return [[bandDictionary_ objectForKey:[sectionHeaders objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = nil;
    if (indexPath.row == [[bandDictionary_ objectForKey:[sectionHeaders objectAtIndex:indexPath.section]] count]) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreBandsCell"] autorelease];
        
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
        
        BandsDirectoryTableViewCell *bandCell = (BandsDirectoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        FilterBand *band = [[bandDictionary_ objectForKey:[sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        if(!bandCell) {
            bandCell = [[[BandsDirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
        }	
        else {
            [[NSNotificationCenter defaultCenter] removeObserver:bandCell];
            [bandCell resetImage];
        }
        
        if(band.profilePicURL) {
            
            [bandCell setImageURL:band.profilePicURL];
        } else {
            [bandCell resetImage];
        }
        
        bandCell.artistLabel.text = band.bandName;
        bandCell.genreLabel.text = band.influences;
        
        cell = bandCell;
    }
		
    // iOS 7 fix
    [cell setBackgroundColor:[UIColor clearColor]];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

	

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	NSInteger count = 0;
	
	if (index == 0) {
        
		[tableView setContentOffset:CGPointZero animated:NO];
        
		return NSNotFound;
    }
	
	for(NSString *character in sectionHeaders)
	{
		if([character isEqualToString:title])
			return count;
		count ++;
	}
	
	return 0;// in case of some eror donot crash d application 
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if([sectionHeaders count] == 0) {
		return @"";
	}
	
	return [sectionHeaders objectAtIndex:section];
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
	headerLabel.text = [sectionHeaders objectAtIndex:section];
	[backgroundView addSubview:headerLabel];
	
	return backgroundView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == [[bandDictionary_ objectForKey:[sectionHeaders objectAtIndex:indexPath.section]] count]) {
        
        if (pager_.hasNext) {
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            [params setObject:lastSearch_ forKey:@"searchString"];
            [params setObject:[NSString stringWithFormat:@"%d", (pager_.currentPage + 1)] forKey:@"page"];
            [params setObject:[NSString stringWithFormat:@"%d", pager_.perPage] forKey:@"limit"];
            
            [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandSearch andCallback:self];
        }        
    } else {

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        FilterBand *band = [[bandDictionary_ objectForKey:[sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        [dict setObject:@"bandProfile" forKey:@"viewToPush"];
        [dict setObject:[NSNumber numberWithInt:band.bandID] forKey:@"ID"];
        
        [self.stackController pushFilterViewWithDictionary:dict];
        
        [dict release];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate conformance


- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	
	if([textField.text length] > 0) {
		
        [lastSearch_ release];
        lastSearch_ = [textField.text retain];
        
        bandsInitialized_ = NO;
        
        NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
        [params setObject:[NSString stringWithFormat:@"%@", textField.text] forKey:@"searchString"];
        [params setObject:@"1" forKey:@"page"];
        [params setObject:[NSString stringWithFormat:@"%d", BANDPAGELIMIT] forKey:@"limit"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandSearch andCallback:self];
	}
	
	[textField resignFirstResponder];
	return NO;
}


#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {

    NSSortDescriptor *sortBy;
	NSArray *descriptors;
	NSArray *bands;
	NSMutableSet *chars;
	
	
    [pager_ release], pager_ = nil;
    pager_ = [metadata retain];
    
	// Reset arrays
    if (!bandsInitialized_ || filterop.type != lastOpType) {
        [bandDictionary_ removeAllObjects];
        [sectionHeaders removeAllObjects];
        bandsInitialized_ = YES;
    }
	
	sortBy		= [NSSortDescriptor sortDescriptorWithKey:@"bandName" ascending:YES selector: @selector(caseInsensitiveCompare:)];
	descriptors = [NSArray arrayWithObjects:sortBy, nil];
	chars		= [[NSMutableSet alloc] initWithCapacity:0];
	bands		= [(NSArray *)data sortedArrayUsingDescriptors:descriptors];
    
    switch (filterop.type) {
            
        case kFilterAPITypeBandSearch: {
            
            
            for(FilterBand *aBand in bands) {
                
                NSString *firstChar = [[aBand.bandName substringWithRange:NSMakeRange(0, 1)] uppercaseString];
                
                //a group already exists for this letter - just append it
                if([bandDictionary_ objectForKey:firstChar]) {
                    NSMutableArray *bandArray = [bandDictionary_ objectForKey:firstChar];
                    [bandArray addObject:aBand];
                } else { //doesn't exist - create the section header object too
                    
                    NSMutableArray *bandArray = [[NSMutableArray alloc] init];
                    [bandArray addObject:aBand];
                    [bandDictionary_ setObject:bandArray forKey:firstChar];
                    [sectionHeaders addObject:firstChar];
                    [sectionHeaders sortUsingSelector:@selector(caseInsensitiveCompare:)];
                    [bandArray release];
                }
                
                
            }
            
            // Create header letters
            //FIXME: This is broken for band names with non alphabetical first characters (e.g. 8mm)
            /*
            for(char c = 'A'; c <= 'Z'; c++) {
                //        NSMutableArray *bandsByAlpha = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray *bandsByAlpha = [bandDictionary_ objectForKey:[NSString stringWithFormat:@"%c", c]];
                if (bandsByAlpha == nil) {
                    bandsByAlpha = [[NSMutableArray alloc] initWithCapacity:0];
                    [bandDictionary_ setObject:bandsByAlpha forKey:[NSString stringWithFormat:@"%c", c]];
                }
                
                for (; i < [bands count]; i++) {
                    
                    NSString *bandName = [[bands objectAtIndex:i] bandName];
                    
                    if([[bandName uppercaseString] characterAtIndex:0] != c) {
                        break;
                    }
                    else {
                        [chars addObject:[NSString stringWithFormat:@"%c",c]];
                        
                        BOOL found = FALSE;
                        FilterBand *newBand = [bands objectAtIndex:i];
                        for (FilterBand *oldBand in bandsByAlpha) {
                            if (oldBand.bandID == newBand.bandID) {
                                found = TRUE;
                                break;
                            }                    
                        }
                        
                        if (!found) {
                            [bandsByAlpha addObject:newBand];
                        }
                    }
                }
            }
            
            sortBy		= [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
            descriptors = [NSArray arrayWithObjects:sortBy, nil];
            
            NSArray *newChars = [chars sortedArrayUsingDescriptors:descriptors];
            for (NSString *newC in newChars) {
                
                BOOL found = FALSE;
                for (NSString *oldC in sectionHeaders) {
                    if ([oldC isEqualToString:newC]) {
                        found = TRUE;
                        break;
                    }
                }
                
                if (!found) {
                    [sectionHeaders addObject:newC];
                }
            }
            
            [chars release];*/
        }
            break;
            
        case kFilterAPITypeGeoGetBands:
            [indicator stopAnimatingAndRemove];
            
            [sectionHeaders addObject:@"Local Bands"];
            [bandDictionary_ setObject:bands forKey:[sectionHeaders objectAtIndex:0]];

            break;
        default:
            break;
    }

    lastOpType = filterop.type;
    
	[tableView_ reloadData];
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
    
    [indicator stopAnimatingAndRemove];
}

@end
