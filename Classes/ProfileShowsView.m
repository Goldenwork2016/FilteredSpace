//
//  ProfileShowsView.m
//  TheFilter
//
//  Created by Ben Hine on 2/23/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "ProfileShowsView.h"
#import "FilterPosterView.h"
#import "FilterDataObjects.h"
#import "FilterAPIOperationQueue.h"

#define SHOWPAGELIMIT   10

#define XPadding        10
#define YPadding        10

#pragma -  
#pragma ProfileShowsData object
@implementation ProfileShowsData

@synthesize showID = showID_;
@synthesize posterURL = posterURL_;
@synthesize useBookmark = useBookmark_;

-(id)init {
	
	self = [super init];
	if(self) {
        
        
    }
    
    return self;
}

- (void)dealloc {
    [posterURL_ release];
    
    [super dealloc];
}

@end

#pragma -
#pragma ProfileShowsView implementation

@implementation ProfileShowsView

@synthesize pager_;
@synthesize type = type_;
@synthesize showsArray = showsArray_;
@synthesize stackController = stackController_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		showsArray_ = [[NSMutableArray alloc] init];

		moreButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
		[moreButton_ setTitle:@"More.." forState:UIControlStateNormal];
		moreButton_.titleLabel.font = FILTERFONT(13);
		[moreButton_ setBackgroundImage:[[UIImage imageNamed:@"featured_screen_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateNormal];
		[moreButton_ setBackgroundImage:[[UIImage imageNamed:@"pressed_down_featured_screen_button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateHighlighted];
		[moreButton_ addTarget:self action:@selector(moreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];		
        [self addSubview:moreButton_];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/


- (void)adjustMoreButton {

    if (pager_ != nil && pager_.hasNext == NO) {
        moreButton_.hidden = YES;
    }
    if (pager_ != nil && pager_.hasNext == YES) {
        moreButton_.hidden = NO;
    }
    if (pager_ == nil) {
        moreButton_.hidden = YES;
    }
    
    moreButton_.frame = CGRectMake(90, self.contentSize.height + 15, 148, 30);
    
    self.contentSize = CGSizeMake(320, self.contentSize.height + 60);
}

- (void)setPager_:(FilterPaginator *)metadata_ {
    [pager_ release], pager_ = nil;
    
    pager_ = [metadata_ retain];
}

-(void)setShowsArray:(NSMutableArray *)shows {
	
    for (FilterPosterView *poster in showsArray_) {
        [poster removeFromSuperview];
    }
    
    [showsArray_ removeAllObjects];
    
	for (ProfileShowsData *showData in shows) {
		
        int i = [showsArray_ count];
		CGRect posterFrame = CGRectMake(XPadding + (i % 3) * 105, YPadding + (i / 3) * 148, 90, 139);
		
        NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
        [params setObject:[NSNumber numberWithInt:showData.showID] forKey:@"showID"];
        [params setObject:[NSNumber numberWithBool:showData.useBookmark] forKey:@"useBookmark"];
        if (showData.posterURL != nil) {
            [params setObject:showData.posterURL forKey:@"posterURL"];
        }

		FilterPosterView *poster = [[FilterPosterView alloc] initWithFrame:posterFrame withDictionary:params];
        [poster addTarget:self action:@selector(filterPosterTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:poster];
		
		[showsArray_ addObject:poster];
    }
	
	self.contentSize = CGSizeMake(320, YPadding + (1 + ([showsArray_ count] / 3)) * 148);
	
	[self adjustMoreButton];
}


- (void)dealloc {
    [super dealloc];
}

- (void)filterPosterTapped:(id)button {
    
	FilterPosterView *poster = button;
    
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:@"showDetails",@"viewToPush", [NSNumber numberWithInt:poster.filterShowID],@"showID",nil];
    [self.stackController pushFilterViewWithDictionary:aDict];
}

- (void)moreButtonTapped:(id)button {
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:[[UIDevice currentDevice] identifierForVendor] forKey:@"udid"];
    [params setObject:[NSString stringWithFormat:@"%d", (pager_.currentPage + 1)] forKey:@"page"];
    [params setObject:[NSString stringWithFormat:@"%d", pager_.perPage] forKey:@"limit"];

    if(type_ == ProfileType_Shows) {
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeAccountShows andCallback:self];
    } else if(type_ == ProfileType_Checkin) {
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeAccountCheckins andCallback:self];
    }
}

- (void)addShowToArray:(ProfileShowsData*)show {
    
    CGRect posterFrame = CGRectMake(XPadding + ([showsArray_ count] % 3) * 105, YPadding + ([showsArray_ count] / 3) * 148, 90, 139);

    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:[NSNumber numberWithInt:show.showID] forKey:@"showID"];
    [params setObject:[NSNumber numberWithBool:show.useBookmark] forKey:@"useBookmark"];
    if (show.posterURL != nil) {
        [params setObject:show.posterURL forKey:@"posterURL"];
    }
    
    FilterPosterView *poster = [[FilterPosterView alloc] initWithFrame:posterFrame withDictionary:params];
    [self addSubview:poster];
    
    [showsArray_ addObject:poster];

	self.contentSize = CGSizeMake(320, YPadding + (1 + ([showsArray_ count] / 3)) * 148);
    
    [self adjustMoreButton];
}

#pragma -
#pragma FilterAPIDelegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	//NSLog(@"finished With Data: %@", [data description]);
	
    [pager_ release], pager_ = nil;
    pager_ = [metadata retain];
	switch (filterop.type) {
			
		case kFilterAPITypeAccountShows: {
                    
            for (FilterAccountShow *show in (NSArray*)data) {
                
                BOOL found = FALSE;
                for (int x = 0; x < [showsArray_ count]; x++) {
                    FilterPosterView *oldShow = [showsArray_ objectAtIndex:x];
                    if (show.showID == oldShow.filterShowID) {
                        found = TRUE;
                        break;
                    }
                }
                
                if (!found) {
                    ProfileShowsData *showData = [[[ProfileShowsData alloc] init] autorelease];
                    showData.showID = show.showID;
                    showData.useBookmark = show.attending;
                    showData.posterURL = show.showPoster;
                    
                    [self addShowToArray:showData];
                }
            }
			break;
		}
            
        case kFilterAPITypeAccountCheckins: {
            
            for (FilterCheckin *checkin in (NSArray*)data) {
                
                BOOL found = FALSE;
                for (int x = 0; x < [showsArray_ count]; x++) {
                    FilterPosterView *oldCheckin = [showsArray_ objectAtIndex:x];
                    if (checkin.checkinShowID == oldCheckin.filterShowID) {
                        found = TRUE;
                        break;
                    }
                }
                
                if (!found) {
                    ProfileShowsData *showData = [[[ProfileShowsData alloc] init] autorelease];
                    showData.showID = checkin.checkinShowID;
                    showData.useBookmark = checkin.bookmarked;
                    showData.posterURL = checkin.checkinPoster;
                    
                    [self addShowToArray:showData];
                }
            }
            break;
        }
			
		default:
			break;
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
}

@end
