//
//  FilterBandProfileView.m
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterBandProfileView.h"
#import "FilterToolbar.h"
#import	"FilterBandMediaTableController.h"
#import "FilterBandBioTableController.h"
#import "FilterBandVideoTableController.h"
#import "FilterBandShowsTableController.h"
#import "FilterGlobalImageDownloader.h"
#import "FilterAPIOperationQueue.h"

#define BANDPAGELIMIT   20
#define SLIDER_X_OFFSET -11
#define SLIDER_WIDTH    103
#define SLIDER_HEIGHT   44

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation FilterBandProfileView

@synthesize bandProfile = bandProfile_;

- (id)initWithFrame:(CGRect)frame andID:(NSNumber *)ID{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		bandID = [ID retain];
        
		backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_background.png"]];
        
		headerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 141)];
		headerContainer.clipsToBounds = YES;
		[self addSubview: headerContainer];
		[headerContainer addSubview:backgroundImage];
		
		sliderButtons = [[NSMutableArray alloc] init];
		profileTableControllers = [[NSMutableArray alloc] initWithCapacity:4];
		
		profileSlider = [[UIImageView alloc] initWithFrame:CGRectMake(SLIDER_X_OFFSET, 0, SLIDER_WIDTH, SLIDER_HEIGHT)];
		profileSlider.image = [[UIImage imageNamed:@"tab_slider.png"] stretchableImageWithLeftCapWidth:35 topCapHeight:10];
		profileSlider.contentMode = UIViewContentModeScaleToFill;
		
		[headerContainer addSubview:profileSlider];
		
		NSArray *labelFiles = [NSArray arrayWithObjects:@"music_text.png",
														@"video_text.png",
														@"shows_text.png",
                                                        @"bio_text.png",
                                                        nil];
		
		for (int x= 0; x < 4; x++) {
			
			CGRect buttonFrame = CGRectMake(0 + (x * 80), 0, 80, 44);

			UIControl *sliderButton = [[UIControl alloc] initWithFrame:buttonFrame];
			[sliderButton addTarget:self action:@selector(sliderTapped:) forControlEvents:UIControlEventTouchUpInside];
		
            sliderButton.selected = (x == 0);
			
			[sliderButtons addObject:sliderButton];
			[headerContainer addSubview:sliderButton];
			
			UIImageView *textImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[labelFiles objectAtIndex:x]]];
			textImage.frame = buttonFrame;
			[headerContainer addSubview:textImage];
            
            [sliderButton release];
            [textImage release];
		}
		
		profileHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 45, 320, 95)];
		profileHeaderView.backgroundColor = [UIColor clearColor];
		profileHeaderView.userInteractionEnabled = YES;
		
		bandProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 75, 75)];
		bandProfileImage.image = [UIImage imageNamed:@"lrg_no_image.png"];
		bandProfileImage.layer.cornerRadius = 5;
		bandProfileImage.clipsToBounds = YES;
		bandProfileImage.backgroundColor = [UIColor clearColor];
		[profileHeaderView addSubview:bandProfileImage];
		
		bandLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 210, 16)];
		bandLabel.backgroundColor = [UIColor clearColor];
		bandLabel.font = FILTERFONT(16);
		bandLabel.textColor = LIGHT_TEXT_COLOR;
		bandLabel.adjustsFontSizeToFitWidth = YES;
		bandLabel.minimumFontSize = 10;
		bandLabel.textAlignment = UITextAlignmentLeft;
		[profileHeaderView addSubview:bandLabel];

		bandLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 28, 210, 16)];
		bandLocationLabel.backgroundColor = [UIColor clearColor];
		bandLocationLabel.font = FILTERFONT(13);
		bandLocationLabel.textColor = DARK_TEXT_COLOR;
		bandLocationLabel.adjustsFontSizeToFitWidth = YES;
		bandLocationLabel.minimumFontSize = 10;
		bandLocationLabel.textAlignment = UITextAlignmentLeft;
		[profileHeaderView addSubview:bandLocationLabel];
        
        
        followIndicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(121, 59, 0, 0) andType:kSmallIndicator];
        [profileHeaderView addSubview:followIndicator];
        
        
        indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height) andType:kLargeIndicator];
        indicator.message.text = @"Loading...";
        
		followButton = [[UIButton alloc] initWithFrame:CGRectMake(95, 54, 73, 31)];
		followButton.titleLabel.font = FILTERFONT(13);
		[followButton setTitle:@"Follow" forState:UIControlStateNormal];        
		[followButton setTitle:@"Following" forState:UIControlStateSelected];
		[followButton setTitle:@"Following" forState:(UIControlStateSelected | UIControlStateHighlighted)];
		[followButton setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] forState:UIControlStateNormal];
		followButton.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.29];
		followButton.titleLabel.shadowOffset = CGSizeMake(0,1);
		[followButton setBackgroundImage:[UIImage imageNamed:@"band_profile_follow_button.png"] forState:UIControlStateNormal];
        //[followingButton setBackgroundImage:[[UIImage imageNamed:@"unselected_profile_follow_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateNormal];
		[followButton setBackgroundImage:[[UIImage imageNamed:@"pressed_down_profile_follow_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateHighlighted];
		[followButton setBackgroundImage:[[UIImage imageNamed:@"selected_profile_follow_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:(UIControlStateSelected | UIControlStateNormal)];
		[followButton addTarget:self action:@selector(followButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[profileHeaderView addSubview:followButton];
		
		//[self addSubview:profileHeaderView];
		[headerContainer addSubview:profileHeaderView];
		
		//profileTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44 + 95, frame.size.width, frame.size.height-44-95)];
		profileTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height + 1)];
        // JDH
        profileTable.backgroundView.backgroundColor = [UIColor blackColor];
        //profileTable.sectionIndexBackgroundColor = [UIColor blackColor];
        
		profileTable.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		profileTable.delegate = self;
		profileTable.dataSource = self;
		profileTable.scrollsToTop = YES;
		
		[self addSubview:profileTable];
		
		// these controllers need to be placed in the array in the same order as the slider buttons... for indexing purposes
		FilterBandMediaTableController *mediaController = [[FilterBandMediaTableController alloc] initWithHeader:nil];
		[profileTableControllers insertObject:mediaController atIndex:BandMediaTableController];
        mediaController.tracksTable = profileTable;		
		
        FilterBandVideoTableController *videoController = [[FilterBandVideoTableController alloc] initWithHeader:nil];
		[profileTableControllers insertObject:videoController atIndex:BandVideoTableController];
        videoController.videoTable = profileTable;

		FilterBandShowsTableController *showsController = [[FilterBandShowsTableController alloc] initWithHeader:nil];
		[profileTableControllers insertObject:showsController atIndex:BandShowsTableController];
        showsController.showsTable = profileTable;
        
        FilterBandBioTableController *bioController = [[FilterBandBioTableController alloc] initWithHeader:nil];
		[profileTableControllers insertObject:bioController atIndex:BandBioTableController];
        
		[mediaController configureTable:profileTable];
		profileTable.tableHeaderView = headerContainer;
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", bandID] forKey:@"bandID"]; 
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:paramDict andType:kFilterAPITypeBandDetails andCallback:self];
        
        [paramDict setObject:[NSString stringWithFormat:@"%d", BANDPAGELIMIT] forKey:@"limit"];
        [paramDict setObject:@"1" forKey:@"page"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:paramDict andType:kFilterAPITypeBandShows andCallback:self];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:paramDict andType:kFilterAPITypeBandTracks andCallback:self];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:paramDict andType:kFilterAPITypeBandVideos andCallback:self];
        [self addSubview:indicator];
        [indicator startAnimating];
    }
    return self;
}

-(void)setBandProfile:(FilterBand *)band {
	bandProfile_ = band;
	
    bandLabel.text = bandProfile_.bandName;
    bandLocationLabel.text = bandProfile_.city;
    if (bandProfile_.profilePicURL != nil)
        bandProfileImage.image = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:bandProfile_.profilePicURL object:self selector:@selector(posterImageDownloaded:)];
    
    [self updateToolbarLabels];
    
    NSMutableArray *bandInfo = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ([band.genres length] > 0) {
        [bandInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:band.genres, @"content", @"Genres", @"title", nil]];
    }
    if ([band.bio length] > 0) {
        [bandInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:band.bio, @"content", @"Biography", @"title", nil]];
    }
    if ([band.influences length] > 0) {
        [bandInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:band.influences, @"content", @"Influences", @"title", nil]];
    }
    if ([band.members length] > 0) {
        [bandInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:band.members, @"content", @"Members", @"title", nil]];
    }
    if ([band.discography length] > 0) {
        [bandInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:band.discography, @"content", @"Discography", @"title", nil]];
    }
    
    FilterBandBioTableController *bController = [profileTableControllers objectAtIndex:BandBioTableController];
    bController.bandInfo = bandInfo;
    
    FilterBandShowsTableController *sController = [profileTableControllers objectAtIndex:BandShowsTableController];
    sController.bandProfile = bandProfile_;
    
	followButton.selected = bandProfile_.following;
	
    FilterBandMediaTableController *tController = [profileTableControllers objectAtIndex:BandMediaTableController];
    tController.bandProfile = bandProfile_;

    FilterBandVideoTableController *vController = [profileTableControllers objectAtIndex:BandVideoTableController];
    vController.bandProfile = bandProfile_;
    //JDH Sept 2013
    vController.stackController = self.stackController;
    
	if([band.trackArray count] > 0) {
		tController.stackController = self.stackController;
	
		[tController.bandTracks removeAllObjects];
		[tController.bandTracks addObjectsFromArray:band.trackArray];
	}
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)slideProfileTab:(CGRect)newRect {
	
	[UIView beginAnimations:@"SlideTab" context:self];
	[UIView setAnimationDuration:0.3];
	
	profileSlider.frame = newRect;
	
	[UIView commitAnimations];
}

- (void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];

	[self updateToolbarLabels];
}

- (void)updateToolbarLabels {
	
	[[FilterToolbar sharedInstance] showPrimaryLabel:bandProfile_.bandName];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	// make sure the main toolbar displays the correct subtoolbar
	if (newSuperview == nil){
		[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	}
}

- (void)sliderTapped:(id)sender {

	if ([sliderButtons indexOfObject:sender] == currentSliderIndex)
		return;
	
	for (int x = 0; x < [sliderButtons count]; x++) {
		UIControl *slider = [sliderButtons objectAtIndex:x];
		if (slider == sender) {

			[self slideProfileTab:CGRectMake(SLIDER_X_OFFSET + (x * 80), 0, SLIDER_WIDTH, SLIDER_HEIGHT)];
			
			currentSliderIndex = x;
			[[profileTableControllers objectAtIndex:currentSliderIndex] configureTable:profileTable];
			[profileTable reloadData];
			
            if (currentSliderIndex == BandBioTableController) {
                cellsBackground.alpha = 0.0;
            }
            else {
                cellsBackground.alpha = 1.0;
            }
		}
	}
}

- (void)followButtonTapped:(id)sender {
	NSDictionary *params = [NSDictionary dictionaryWithObject:bandID forKey:@"bandID"];
    
	if(followButton.selected) {
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandUnfollow andCallback:self];
        
	} else {
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeBandFollow andCallback:self];
	}
    
    [UIView animateWithDuration:0.3 animations:^{ followButton.alpha = 0.0; }];
    
    [followIndicator startAnimating];
}

-(void)posterImageDownloaded:(id)sender {
	bandProfileImage.image = [(NSNotification*)sender image];
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[profileTableControllers objectAtIndex:currentSliderIndex] numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[profileTableControllers objectAtIndex:currentSliderIndex] tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[profileTableControllers objectAtIndex:currentSliderIndex] tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[profileTableControllers objectAtIndex:currentSliderIndex] tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[profileTableControllers objectAtIndex:currentSliderIndex] tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [[profileTableControllers objectAtIndex:currentSliderIndex] tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [[profileTableControllers objectAtIndex:currentSliderIndex] tableView:tableView heightForHeaderInSection:section];
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	
	switch (filterop.type) {

		case kFilterAPITypeBandShows: {
			
			FilterBandShowsTableController *tController = [profileTableControllers objectAtIndex:BandShowsTableController];
			tController.stackController = self.stackController;
            tController.pager = [metadata retain];
			
			[tController.bandShows removeAllObjects];
			[tController.bandShows addObjectsFromArray:(NSArray*)data];
            
            showsLoaded = YES;
		}
		break;
			
		case kFilterAPITypeBandTracks: {
			
			FilterBandMediaTableController *tController = [profileTableControllers objectAtIndex:BandMediaTableController];
			tController.stackController = self.stackController;
            tController.pager = [metadata retain];
			
			[tController.bandTracks removeAllObjects];
			[tController.bandTracks addObjectsFromArray:(NSArray*)data];
            
            mediaLoaded = YES;
		}
		break;
        case kFilterAPITypeBandVideos: {
            FilterBandVideoTableController *tController = [profileTableControllers objectAtIndex:BandVideoTableController];
            
            [tController.bandVideos removeAllObjects];
            [tController.bandVideos addObjectsFromArray:(NSArray*)data];
            
            videosLoaded = YES;
        }
        break;
        case kFilterAPITypeBandDetails:{
            
            [self setBandProfile:(FilterBand*)data];
        
            detailsLoaded = YES;
			break;
		}
        case kFilterAPITypeBandFollow:
            followButton.selected = YES;
            [UIView animateWithDuration:0.3 animations:^{ followButton.alpha = 1.0;} completion:^(BOOL finished){ [followIndicator stopAnimating]; }];
            break;
		case kFilterAPITypeBandUnfollow:
			followButton.selected = NO;
            [UIView animateWithDuration:0.3 animations:^{ followButton.alpha = 1.0;} completion:^(BOOL finished){ [followIndicator stopAnimating]; }];
			break;
		default:
			break;
	}
	
    if(mediaLoaded && detailsLoaded && showsLoaded && videosLoaded) {
        [indicator stopAnimatingAndRemove];
    }
    
	[profileTable reloadData];
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
    
    [UIView animateWithDuration:0.3 animations:^{ followButton.alpha = 1.0; } completion:^(BOOL finished){ [indicator stopAnimating]; }];
    [indicator stopAnimatingAndRemove];
}

@end
