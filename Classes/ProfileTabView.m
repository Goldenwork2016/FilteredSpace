//
//  ProfileTabView.m
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileTabView.h"
#import "FilterToolbar.h"

#import "SubtitleButton.h"
#import "FollowBandTableCell.h"
#import "FilterDataObjects.h"
#import "ProfileShowsView.h"
#import "FilterGlobalImageDownloader.h"
#import "FilterAPIOperationQueue.h"

#define BANDPAGELIMIT       20
#define SHOWPAGELIMIT       10
#define CHECKINPAGELIMIT    10

@implementation ProfileTabView
@synthesize profilePic = profilePic_;
@synthesize nameLabel = nameLabel_;
@synthesize segmentButtonArray = segmentButtonArray_;
@synthesize isSelf = isSelf_;
@synthesize fanAccount = fanAccount_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
        bandListInitialized_ = NO;
        showListInitialized_ = NO;
        checkinListInitialized_ = NO;
		bandArray_ = [[NSMutableArray alloc] init];
		
		UIImageView *topBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_profile_background.png"]] autorelease];
		[self addSubview:topBackground];
		
		profilePic_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 75, 75)];
		profilePic_.image = [UIImage imageNamed:@"lrg_no_image.png"];
		profilePic_.clipsToBounds = YES;
		profilePic_.layer.cornerRadius = 5;
		
		
		profilePic_.backgroundColor = [UIColor clearColor];
		
		
		[self addSubview:profilePic_];
		
		SubtitleButton *showsButton = [SubtitleButton buttonWithType:UIButtonTypeCustom];
		[showsButton setBackgroundImage:[UIImage imageNamed:@"unselected_left_profile_button.png"] forState:UIControlStateNormal];
		[showsButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_left_profile_button.png"] forState:UIControlStateHighlighted];
		[showsButton setBackgroundImage:[UIImage imageNamed:@"selected_left_profile_button.png"] forState:UIControlStateSelected];
		[showsButton setBackgroundImage:[UIImage imageNamed:@"selected_left_profile_button.png"] forState:(UIControlStateHighlighted | UIControlStateSelected)];
		showsButton.frame = CGRectMake(95, 40, 70, 45);
		showsButton.selected = YES;
		showsButton.secondaryLabel.text = @"shows";
		[self addSubview:showsButton];
		[showsButton addTarget:self action:@selector(segmentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		SubtitleButton *bandsButton = [SubtitleButton buttonWithType:UIButtonTypeCustom];
		[bandsButton setBackgroundImage:[UIImage imageNamed:@"unselected_middle_profile_button.png"] forState:UIControlStateNormal];
		[bandsButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_middle_profile_button.png"] forState:UIControlStateHighlighted];
		[bandsButton setBackgroundImage:[UIImage imageNamed:@"selected_middle_profile_button.png"] forState:UIControlStateSelected];
		[bandsButton setBackgroundImage:[UIImage imageNamed:@"selected_middle_profile_button.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
		bandsButton.frame = CGRectMake(165, 40, 70, 45);
		bandsButton.secondaryLabel.text = @"checkins";
		bandsButton.tag = 1;
		[self addSubview:bandsButton];
		[bandsButton addTarget:self action:@selector(segmentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		SubtitleButton *friendButton = [SubtitleButton buttonWithType:UIButtonTypeCustom];
		[friendButton setBackgroundImage:[UIImage imageNamed:@"unselected_right_profile_button.png"] forState:UIControlStateNormal];
		[friendButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_right_profile_button.png"] forState:UIControlStateHighlighted];
		[friendButton setBackgroundImage:[UIImage imageNamed:@"selected_right_profile_button.png"] forState:UIControlStateSelected];
		[friendButton setBackgroundImage:[UIImage imageNamed:@"selected_right_profile_button.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
		friendButton.frame = CGRectMake(235, 40, 70, 45);
		friendButton.secondaryLabel.text = @"bands";
		friendButton.tag = 2;
		[self addSubview:friendButton];
		[friendButton addTarget:self action:@selector(segmentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		segmentButtonArray_ = [[NSArray alloc] initWithObjects:showsButton, bandsButton, friendButton, nil];
		
		
		nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 130, 30)];
		nameLabel_.backgroundColor = [UIColor clearColor];
		nameLabel_.font = FILTERFONT(18);
		nameLabel_.textColor = [UIColor  colorWithRed:0.83 green:0.85 blue:0.85 alpha:1];
		nameLabel_.adjustsFontSizeToFitWidth = YES;
		nameLabel_.minimumFontSize = 14;
		
		[self addSubview:nameLabel_];
		
		/****************
		 This won't be needed in version 1 since we're not allowing friends
		 ////////////////
		followButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
		followButton_.frame = CGRectMake(235, 5, 70, 30);
		[followButton_ setBackgroundImage:[UIImage imageNamed:@"unselected_profile_follow_button.png"] forState:UIControlStateNormal];
		[followButton_ setBackgroundImage:[UIImage imageNamed:@"pressed_down_profile_follow_button.png"] forState:UIControlStateHighlighted];
		[followButton_ setBackgroundImage:[UIImage imageNamed:@"selected_profile_follow_button.png"] forState:UIControlStateSelected];
		[followButton_ setBackgroundImage:[UIImage imageNamed:@"selected_profile_follow_button.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
		followButton_.titleLabel.font = FILTERFONT(14);
		[followButton_ setTitle:@"Follow" forState:UIControlStateNormal];
		[followButton_ setTitle:@"Following" forState:UIControlStateSelected];
		[followButton_ setTitle:@"Following" forState:UIControlStateSelected | UIControlStateHighlighted];
		followButton_.hidden = YES;
		[followButton_ addTarget:self action:@selector(followPushed:) forControlEvents:UIControlEventTouchUpInside];
		
		
		[self addSubview:followButton_]; //TODO: make conditional depending upon whether this is the user's profile or not
		*/
		
		bandTable_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 95, 320, frame.size.height - 98)];
		UIView *tableBackground = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		tableBackground.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		bandTable_.backgroundView = tableBackground;
		bandTable_.separatorColor = [UIColor blackColor];
		bandTable_.delegate = self;
		bandTable_.dataSource = self;
		
		
		
		showScroll_ = [[ProfileShowsView alloc] initWithFrame:CGRectMake(0, 95, 320, frame.size.height - 98)];
		showScroll_.delegate = self;
        showScroll_.type = ProfileType_Shows;
		[self addSubview:showScroll_];
		
		checkinScroll_ = [[ProfileShowsView alloc] initWithFrame:CGRectMake(0, 95, 320, frame.size.height - 98)];
        checkinScroll_.type = ProfileType_Checkin;
		checkinScroll_.delegate = self;
		
		
		//testing
		//[self addSubview:bandTable_];
		//[self sendSubviewToBack:bandTable_];
		
        indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, -1, 320, frame.size.height + 1) andType:kLargeIndicator];
        indicator.message.text = @"Loading...";
		
		
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview {
	if(newSuperview) {
		
		// if the fan account is set prior to coming here then e are viewing another fan prfile
		// otherwise we are viewing our own profile
		
		//NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
		//[paramsDict setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];

		// if we are getting another fan's profile we need to submit the request a little different
		if (fanAccount_ != nil) {
			//[paramsDict setObject:[NSString stringWithFormat:@"%d", fanAccount_.accountID] forKey:@"user_id"];
			//[[FilterAPIOperationQueue sharedInstance] FilterAPIOperationGetAccountDetailsWithParams:paramsDict withCallback:self];
		} else {
			
			//fanAccount_ = [FilterFanAccount getMyAccountWithRequester:self];
		}		
		
	} else {
		[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	}

}


-(void)followPushed:(id)sender {
	
	
	
}

- (void) refreshData {
    fanAccount_ = [FilterFanAccount getMyAccountWithRequester:self];
    
    [self addSubview:indicator];
    [indicator startAnimating];
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];

	// a fan profile will already be set here, if its nil then we are viewing our own
	/*	if (fanAccount_ != nil && fanAccount_.isSelf == NO) {
		[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
		
		[[FilterToolbar sharedInstance] showPrimaryLabel:@"Fan Profile"];
        
        [[FilterToolbar sharedInstance] showSecondaryLabel:nil];
		
	} else { */
		[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeNone];
		
        [[FilterToolbar sharedInstance] showLogo];
	//}
	
}

-(void)segmentButtonPressed:(id)sender {
	
	SubtitleButton *pushed = (SubtitleButton*)sender;
	if(pushed.selected) { return;} //no-op if already selected
	else {
		
		for(SubtitleButton *aButton in segmentButtonArray_) {
			aButton.selected = NO;
		}
		pushed.selected = YES;
		
		if (pushed.tag == 2) {
			[bandTable_ reloadData];
			if(bandTable_.superview == nil) {
				[self addSubview:bandTable_];
			}
			
			if(showScroll_.superview) {
				[showScroll_ removeFromSuperview];
			} else if (checkinScroll_.superview) {
				[checkinScroll_ removeFromSuperview];
			}
			
			
		} else if (pushed.tag == 0) {
			
			if(bandTable_.superview) {
				[bandTable_ removeFromSuperview];
			} else if (checkinScroll_.superview) {
				[checkinScroll_ removeFromSuperview];
			}
			
			[self addSubview:showScroll_];
		} else if (pushed.tag == 1) {
			
			if (bandTable_.superview) {
				[bandTable_ removeFromSuperview];
			} else if (showScroll_.superview) {
				[showScroll_ removeFromSuperview];
			}
				
			[self addSubview:checkinScroll_];
			
			
		}
		
		//TODO: change the rest of the view
		
	}
	
	
	
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

-(void)setFanAccount:(FilterFanAccount*)acct {
	fanAccount_ = [acct retain];
	nameLabel_.text = acct.userName;
	
	/*
	if(acct.isSelf) {
		followButton_.hidden = YES;
	} else {
		followButton_.hidden = NO;
	}
	 */
	 
    showScroll_.stackController = [self stackController];
    checkinScroll_.stackController = [self stackController];
	
    profilePic_.image = [UIImage imageNamed:@"lrg_no_image.png"];
	if (fanAccount_.profilePicURL != nil)
		profilePic_.image = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:fanAccount_.profilePicURL object:self selector:@selector(profilePicDownloaded:)];
	
}

-(void)profilePicDownloaded:(id)sender {
	profilePic_.image = [(NSNotification*)sender image];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
    UITableViewCell *cell = nil;
    if (indexPath.row == [bandArray_ count]) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreShowsCell"] autorelease];
        
        UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,14,300,40)];
        cellLabel.backgroundColor = [UIColor clearColor];
        cellLabel.font = FILTERFONT(15);
        cellLabel.textAlignment = UITextAlignmentCenter;
        
        if (bandPager_.hasNext) {
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
        
        FollowBandTableCell *bandCell = (FollowBandTableCell*)[tableView dequeueReusableCellWithIdentifier:@"tableCell"];
        
        if(!bandCell) {
            bandCell = [[[FollowBandTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCell"] autorelease];
        }
        else {
            [[NSNotificationCenter defaultCenter] removeObserver:bandCell];
            [bandCell resetImage];
        }
        
        if ([(UIButton*)[self viewWithTag:2] isSelected]) {
            //TODO: set cell attributes for bands
            FilterAccountBand *band = [bandArray_ objectAtIndex:indexPath.row];
            bandCell.nameLabel.text = band.bandName;
            [bandCell setImageURL:band.bandPoster];
            
        }

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

    if ([bandArray_ count] > 0)
        return [bandArray_ count] + 1;
    else
        return 0; 
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row == [bandArray_ count]) {
        if (bandPager_.hasNext) {
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            [params setObject:[[UIDevice currentDevice] identifierForVendor] forKey:@"udid"];
            [params setObject:[NSString stringWithFormat:@"%d", (bandPager_.currentPage + 1)] forKey:@"page"];
            [params setObject:[NSString stringWithFormat:@"%d", bandPager_.perPage] forKey:@"limit"];
            [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeAccountBands andCallback:self];
        }        
    } else {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"bandProfile",@"viewToPush",[NSNumber numberWithInt:[[bandArray_ objectAtIndex:indexPath.row] bandID]],@"ID",nil];
        [self.stackController pushFilterViewWithDictionary:dict];
    }
	
	
}


-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	//NSLog(@"finished With Data: %@", [data description]);
	
	switch (filterop.type) {
		case kFilterAPITypeAccountDetails: {
			self.fanAccount = data;
			SubtitleButton *bandsButton = [segmentButtonArray_ objectAtIndex:2];
			bandsButton.primaryLabel.text = [NSString stringWithFormat:@"%d", fanAccount_.bandsCount];
			
			SubtitleButton *showsButton = [segmentButtonArray_ objectAtIndex:0];
			showsButton.primaryLabel.text = [NSString stringWithFormat:@"%d", fanAccount_.showsCount];
			
			SubtitleButton *checkinsButton = [segmentButtonArray_ objectAtIndex:1];
			checkinsButton.primaryLabel.text = [NSString stringWithFormat:@"%d", fanAccount_.checkinsCount];
			
			//TODO: make this also depend on which tab is selected so we're not firing off a ton of API calls at once.
            NSMutableDictionary *paramDict = [[[NSMutableDictionary alloc] init] autorelease];
            [paramDict setObject:[[UIDevice currentDevice] identifierForVendor] forKey:@"udid"];
			if(fanAccount_.showsCount > 0) {
                [paramDict setObject:[NSString stringWithFormat:@"%d", SHOWPAGELIMIT] forKey:@"limit"];
                [paramDict setObject:@"1" forKey:@"page"];
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:paramDict andType:kFilterAPITypeAccountShows andCallback:self];
			}
            else {
                showScroll_.pager_ = nil;
                showScroll_.showsArray = nil;
                
                fanAccount_.showsLoaded = YES;
            }
			if(fanAccount_.bandsCount > 0) {
                [paramDict setObject:[NSString stringWithFormat:@"%d", BANDPAGELIMIT] forKey:@"limit"];
                [paramDict setObject:@"1" forKey:@"page"];
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:paramDict andType:kFilterAPITypeAccountBands andCallback:self];
                [bandArray_ removeAllObjects];
			}
            else {
                [bandArray_ removeAllObjects];
                [bandTable_ reloadData];
                bandPager_ = nil;
                fanAccount_.bandsLoaded = YES;
            }
			if(fanAccount_.checkinsCount > 0) {
                [paramDict setObject:[NSString stringWithFormat:@"%d", CHECKINPAGELIMIT] forKey:@"limit"];
                [paramDict setObject:@"1" forKey:@"page"];
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:paramDict andType:kFilterAPITypeAccountCheckins andCallback:self];
			}
            else {
                fanAccount_.checkinsLoaded = YES;
            }
			
			break;
		}
			
		case kFilterAPITypeAccountBands: {

            if (!bandListInitialized_) {
                [bandArray_ removeAllObjects];
                bandListInitialized_ = YES;
            }

            [bandPager_ release], bandPager_ = nil;
            bandPager_ = [metadata retain];
            
            for (FilterAccountBand *band in (NSArray*)data) {
                BOOL found = FALSE;
                for (int x = 0; x < [bandArray_ count]; x++) {
                    FilterAccountBand *oldBand = [bandArray_ objectAtIndex:x];
                    if (band.bandID == oldBand.bandID) {
                        found = TRUE;
                        break;
                    }
                }
                
                if (!found) {
                    [bandArray_ addObject:band];   
                }            
            }
            			
			[bandTable_ reloadData];
			
            fanAccount_.bandsLoaded = YES;
			break;
		}
			
		case kFilterAPITypeAccountShows: {
			
            NSMutableArray *showsBookmarked = [[[NSMutableArray alloc] init] autorelease];
            for (FilterAccountShow *show in (NSArray*)data) {
                ProfileShowsData *showData = [[[ProfileShowsData alloc] init] autorelease];
                showData.showID = show.showID;
                showData.useBookmark = show.attending;
                showData.posterURL = show.showPoster;
                
                [showsBookmarked addObject:showData];
            }
    
            showScroll_.pager_ = [metadata retain];
			showScroll_.showsArray = showsBookmarked;

			fanAccount_.showsLoaded = YES;
			
			break;
		}
            
        case kFilterAPITypeAccountCheckins: {
            
            NSMutableArray *showCheckins = [[[NSMutableArray alloc] init] autorelease];
            for (FilterCheckin *checkin in (NSArray*)data) {
                ProfileShowsData *showData = [[[ProfileShowsData alloc] init] autorelease];
                showData.showID = checkin.checkinShowID;
                showData.useBookmark = checkin.bookmarked;
                showData.posterURL = checkin.checkinPoster;
                
                [showCheckins addObject:showData];
            }
            
            checkinScroll_.pager_ = [metadata retain];
			checkinScroll_.showsArray = showCheckins;
            
			fanAccount_.checkinsLoaded = YES;

            break;
        }
			
		default:
			break;
	}
	
    if (fanAccount_.checkinsLoaded && fanAccount_.showsLoaded && fanAccount_.bandsLoaded) {
        [indicator stopAnimatingAndRemove];
    }
	
	
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
