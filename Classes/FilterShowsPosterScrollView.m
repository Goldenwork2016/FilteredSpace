//
//  FilterShowsPosterScrollView.m
//  TheFilter
//
//  Created by John Thomas on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterShowsPosterScrollView.h"
#import "FilterPosterView.h"

#define POSTER_WIDTH 310
#define POSTER_HEIGHT 480

@implementation FilterShowsPosterScrollView

@synthesize delegate = delegate_;
@synthesize posterIndex = posterIndex_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
        //JDH can this be reset here?
       // frame.size.height = 480;
        
		posterIndex_ = 0;
		expandedPosterShows_ = [[NSMutableArray alloc] init];
		
		posterScrollView = [[FilterScrollView alloc] initWithFrame:CGRectMake(0, 0, POSTER_WIDTH + 10, POSTER_HEIGHT)];
		//posterScrollView.clipsToBounds = NO;						// this creates the "preview"
		posterScrollView.pagingEnabled = YES;
		posterScrollView.delegate = self;
		[self addSubview:posterScrollView];
	}
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	// If the point is in the preview areas we need to return the scrollview here for interaction to work
	if (!CGRectContainsPoint(posterScrollView.frame, point)) {
		return posterScrollView;
	}
	
	// If the point is inside our scrollview, let it be handled as normal.
	return [super hitTest:point	withEvent:event];
}

- (void)setPosterDataArray:(NSArray *)array startingAtIndex:(NSInteger)idx {
	
	posterIndex_ = idx;
	[expandedPosterShows_ addObjectsFromArray:array];
	
	for (int x = 0; x < [expandedPosterShows_ count]; x++) {
				
		FilterShow *show = [expandedPosterShows_ objectAtIndex:x];
		
        NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
        [params setObject:[NSNumber numberWithInt:show.showID] forKey:@"showID"];
        [params setObject:[NSNumber numberWithBool:show.attending] forKey:@"useBookmark"];
        if (show.posterLargeURL != nil) {
            [params setObject:show.posterLargeURL forKey:@"posterURL"];
        }
        // JDH FIX 7/25/12
        else{
            show.posterLargeURL = @"";
            [params setObject:show.posterLargeURL forKey:@"posterURL"];
        }
        
		FilterPosterView *poster = [[FilterPosterView alloc] initWithFrame:CGRectMake(x*320+5, 0, POSTER_WIDTH, POSTER_HEIGHT) withDictionary:params];
		//FilterPosterView *poster = [[FilterPosterView alloc] initWithFrame:CGRectMake(x*320+5, 0, POSTER_WIDTH, POSTER_HEIGHT)  withShow:show withBookmark:show.attending];
		[poster addTarget:self action:@selector(filterPosterTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		[posterScrollView addSubview:poster];
        
        [poster release];
	}
	
	// set the scrollview content size to the appropriate number of pages
	posterScrollView.contentSize = CGSizeMake([array count] * (POSTER_WIDTH + 10), POSTER_HEIGHT);
	
	// set the scrollview contentoffset to the one that we want
	posterScrollView.contentOffset = CGPointMake(posterIndex_* (POSTER_WIDTH + 10), 0);
}

- (FilterShow*)getCurrentShow {
	return [expandedPosterShows_ objectAtIndex:posterIndex_];
}

- (void)filterPosterTapped:(id)sender {
	[self.delegate ExpandedPosterTapped:[expandedPosterShows_ objectAtIndex:posterIndex_]];
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	NSInteger pageWidth = scrollView.frame.size.width;
	posterIndex_ = scrollView.contentOffset.x / pageWidth;
	
	[self.delegate ScrollingStoppedOnShow:[expandedPosterShows_ objectAtIndex:posterIndex_]];
}

@end
