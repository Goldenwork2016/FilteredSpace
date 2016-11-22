//
//  VenueProfileView.m
//  TheFilter
//
//  Created by Patrick Hernandez on 5/18/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import "VenueProfileView.h"
#import "FilterToolbar.h"
#import "VenueProfileTableViewCell.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@interface VenueProfileView () 
- (CGSize)sizeForString:(NSString *)string;
- (void)setVenue:(FilterVenue *)venue;
@end
    
@implementation VenueProfileView

@synthesize venue = venue_;

- (id)initWithFrame:(CGRect)frame andID:(NSNumber *)ID {
    self = [super initWithFrame:frame];
    
    if (self) {
        ID_ = [ID retain];
        
        headerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 267)];
        
        venueImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 75, 75)];
        venueImage_.image = [UIImage imageNamed:@"venue_image_avatar.png"];
        
        [headerView_ addSubview:venueImage_];
        
        venueName_ = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 215, 20)];
		venueName_.font = FILTERFONT(17);
		venueName_.textColor = LIGHT_TEXT_COLOR;
		venueName_.adjustsFontSizeToFitWidth = YES;
		venueName_.minimumFontSize = 10;
		venueName_.textAlignment = UITextAlignmentLeft;
		venueName_.backgroundColor = [UIColor clearColor];
        
        [headerView_ addSubview:venueName_];
        
        // City, State concept is not sent over API. 
        // venueCity_ = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 215, 20)];
		venueCity_.font = FILTERFONT(12);
		venueCity_.textColor = DARK_TEXT_COLOR;
		venueCity_.adjustsFontSizeToFitWidth = YES;
		venueCity_.minimumFontSize = 10;
		venueCity_.textAlignment = UITextAlignmentLeft;
		venueCity_.backgroundColor = [UIColor clearColor];
        
        [headerView_ addSubview:venueCity_];
        
        tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        tableView_.backgroundColor = [UIColor clearColor];
        tableView_.tableHeaderView = headerView_;
        tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView_.delegate = self;
        tableView_.dataSource = self;
        
        [self addSubview:tableView_];

        NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
        [params setObject:ID forKey:@"ID"];
        
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeVenueDetails andCallback:self];
    
        indicator_ = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height + 1) andType:kLargeIndicator];
        indicator_.message.text = @"Loading...";
        
        [self addSubview:indicator_];
        [indicator_ startAnimating];
    }
    
    return self;
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
    [[FilterToolbar sharedInstance] showPrimaryLabel:@"Venue"];
    [[FilterToolbar sharedInstance] showSecondaryLabel:nil];
}

- (void) dealloc {
    
    [headerView_ release];
    [venueName_ release];
    [venueCity_ release];
    [venueImage_ release];
    [tableView_ release]; 
    [super dealloc];
}

#pragma mark - 
#pragma mark Private Methods

- (CGSize)sizeForString:(NSString *)string {
    CGSize maximumLabelSize  = CGSizeMake(280,9999);
	CGSize expectedLabelSize = [string sizeWithFont:FILTERFONT(13) 
                                  constrainedToSize:maximumLabelSize 
                                      lineBreakMode:UILineBreakModeWordWrap]; 
    return expectedLabelSize;
}

- (void)setVenue:(FilterVenue *)venue {
    [venue_ release];
    venue_ = [venue retain];
    
    venueName_.text = venue_.venueName;
    venueCity_.text = [NSString stringWithFormat:@"%@, %@", venue_.city, venue_.venueState];
    
    for (int i = 0; i < 3; i++) {
        NSString *content = @"";
        
        switch (i) {
            case 0:
                content = [NSString stringWithFormat:@"%@%@", venue_.addressOne, venue_.addressTwo];
                break;
            case 1:
                content = [NSString stringWithString:venue_.phoneNumber];
                break;
            case 2:
                content = [NSString stringWithString:![venue_.webURL isEqualToString:@""] ? venue_.webURL : @"No Website"];
            default:
                break;
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 100 + (i * 59), 300, 44);
        button.titleLabel.font = FILTERFONT(13);
        button.tag = i;
        [button setTitleColor:LIGHT_TEXT_COLOR forState:UIControlStateNormal];
        [button setTitleColor:DARK_TEXT_COLOR forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"table_cell_button.png"] forState:UIControlStateNormal];
        [button setTitle:content forState:UIControlStateNormal];
        [headerView_ addSubview:button];
    }
    
    [tableView_ reloadData];
}

- (void)buttonTapped:(id)sender {
    NSString *url;
    
    switch ([sender tag]) {
        case 0: {
            NSString *address = [NSString stringWithFormat:@"%@%@ %@,%@",venue_.addressOne, venue_.addressTwo, venue_.city, venue_.venueState];
            url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", address];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];  
            break;
        }
        case 1: {
            url = [NSString stringWithFormat:@"tel:%@", [venue_.phoneNumber stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
            break;
        case 2:
            if (venue_.webURL != nil) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:venue_.webURL]];
            }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (venue_ == nil) {
        return 0;
    }
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *content = @"";
    CGSize textSize;
    
	VenueProfileTableViewCell *cell = (VenueProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"profileCell"];
	if(!cell) {
		cell = [[[VenueProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profileCell"] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    
    switch (indexPath.row) {
        case 0: 
            content = @"Upcoming shows";
            cell.label.text = [venue_.futureShows stringValue];
            break;
        case 1:
            content = [NSString stringWithString:![venue_.description isEqualToString:@""] ? venue_.description : @"No Description"];
            cell.label.text = @"";
            break;
        default:
            break;
    }
    
    [cell.contentLabel setText:content];
    
    textSize = [self sizeForString:content];
    
    [cell adjustCellFrames:textSize];
    // iOS 7 fix
    [cell setBackgroundColor:[UIColor clearColor]];
    
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        if ([venue_.description isEqualToString:@""]) {
            return 55;
        }
        else {
        return [self sizeForString:venue_.description].height + 35;
        }
    }
    
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"venueShowsView", @"viewToPush", ID_, @"ID", nil];
        [self.stackController pushFilterViewWithDictionary:dict];
    }
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
    switch (filterop.type) {
        case kFilterAPITypeVenueDetails:
            [self setVenue:(FilterVenue *)data];
            break;
        default:
            break;
    }
    
    [indicator_ stopAnimatingAndRemove];
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
    
    [indicator_ stopAnimatingAndRemove];
}

@end
