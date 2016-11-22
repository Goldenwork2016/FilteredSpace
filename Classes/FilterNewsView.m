//
//  FilterNewsView.m
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterNewsView.h"
#import "FilterToolbar.h"
#import "BandNewsTableCell.h"
#import "FilterDataObjects.h"

#define NEWSPAGELIMIT   20

@implementation FilterNewsView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
        newsFeedInitialized_ = NO;
		bandFeed_ = [[NSMutableArray alloc] init];

		tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		tableView_.delegate = self;
		tableView_.dataSource = self;
		UIView *background = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		background.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1.0];
		tableView_.backgroundView = background;
		tableView_.separatorColor = [UIColor blackColor];
		[self addSubview:tableView_];
		
        indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, -1, 320, self.frame.size.height+ 1) andType:kLargeIndicator];
        indicator.message.text = @"Loading...";
    }
    return self;
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeNone];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
    [[FilterToolbar sharedInstance] showLogo];
	
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
        [params setObject:[NSString stringWithFormat:@"%d", NEWSPAGELIMIT] forKey:@"limit"];
        [params setObject:@"1" forKey:@"page"];
        
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeAccountNews andCallback:self];
        
        [self addSubview:indicator];
        [indicator startAnimating];
        
        [params release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == [bandFeed_ count]) {
        return 44;
    } else {
        
        FilterNews *news = [bandFeed_ objectAtIndex:indexPath.row];
        CGSize maximumLabelSize = CGSizeMake(280,9999);
        CGSize expectedLabelSize = [news.body sizeWithFont:FILTERFONT(11) 
                                         constrainedToSize:maximumLabelSize 
                                             lineBreakMode:UILineBreakModeWordWrap]; 
        
        if (expectedLabelSize.height > 25) {
            return expectedLabelSize.height + 20 + 34;	// 20 for the padding, 34 for the static content
        } else {
            return 79;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = nil;
    if (indexPath.row == [bandFeed_ count]) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreNewsCell"] autorelease];
                    
        UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,12,300,20)];
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
        
        BandNewsTableCell *bandCell = (BandNewsTableCell*)[tableView dequeueReusableCellWithIdentifier:@"BandNewsCell"];
        
        if (!bandCell) {
            bandCell = [[[BandNewsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BandNewsCell"] autorelease];
        }
        else {
            [[NSNotificationCenter defaultCenter] removeObserver:bandCell];
            [bandCell resetImage];
        }
        FilterNews *news = [bandFeed_ objectAtIndex:indexPath.row];
        
        NSString *trimmedTitle = [news.title stringByTrimmingCharactersInSet:
                                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        bandCell.primaryLabel.text = trimmedTitle;
        bandCell.primaryLabel.adjustsFontSizeToFitWidth = YES;
        
        bandCell.bodyLabel.text = news.body;
   //     NSLog(@"title %@ : %lu",news.title, (unsigned long)news.title.length);
   //     NSLog(@"body %@",news.body);
   //     NSLog(@"font : %@", bandCell.primaryLabel.font);
        //JDH fix for the bizarre height truncation for long titles
       
        if (trimmedTitle.length > 36) {
            bandCell.primaryLabel.font = FILTERFONT(12);
        }
        else {
            bandCell.primaryLabel.font = FILTERFONT(14);
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"eeee, MMMM dd, yyyy at HH:mm a"];
        bandCell.timestampLabel.text = [formatter stringFromDate:news.timestamp];
        [bandCell setImageURL:news.urlString];
        
        bandCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGSize maximumLabelSize = CGSizeMake(280,9999);
        /*CGSize expectedLabelSize = [news.body sizeWithFont:FILTERFONT(11)
                                         constrainedToSize:maximumLabelSize 
                                             lineBreakMode:UILineBreakModeWordWrap];
        */
        CGSize expectedLabelSize = [news.body sizeWithFont:FILTERFONT(11)
                                         constrainedToSize:maximumLabelSize
                                             lineBreakMode:UILineBreakModeTailTruncation ];
        
       // NSLog(@"expectedLabelSize -width - height %f,%f",expectedLabelSize.width, expectedLabelSize.height);
        [bandCell adjustCellFrames:expectedLabelSize];

        cell = bandCell;
    }
	
    // iOS 7 fix
    [cell setBackgroundColor:[UIColor clearColor]];
    
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([bandFeed_ count] > 0)
        return [bandFeed_ count] + 1;
    else
        return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // if the row selected is the very bottom row, then load more band data
	if (indexPath.row == [bandFeed_ count]) {
        if (pager_.hasNext) {
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            [params setObject:[NSString stringWithFormat:@"%d", (pager_.currentPage + 1)] forKey:@"page"];
            [params setObject:[NSString stringWithFormat:@"%d", pager_.perPage] forKey:@"limit"];
            [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeAccountNews andCallback:self];
        }
    }
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
    
   // NSLog(@"%@", [pager_ description]);
    
    
    
    [pager_ release], pager_ = nil;
    pager_ = [metadata retain];
    
    if (pager_.currentPage == 1 && [bandFeed_ count] > 0) {
        [bandFeed_ removeAllObjects];
        newsFeedInitialized_ = YES;
    }
    
    [indicator stopAnimatingAndRemove];
    
    for (FilterNews *news in (NSArray*)data) {
        BOOL found = FALSE;
        for (int x = 0; x < [bandFeed_ count]; x++) {
            FilterNews *oldNews = [bandFeed_ objectAtIndex:x];
            if (news.newsID == oldNews.newsID) {
                found = TRUE;
                break;
            }
        }
        
        if (!found) {
            [bandFeed_ addObject:news];   
        }            
    }

    [tableView_ reloadData];
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
