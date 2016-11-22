//
//  FilterMainScrollView.m
//  TheFilter
//
//  Created by Patrick Hernandez on 3/24/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import "FilterMainScrollView.h"
#import "FilterMainFeaturedView.h"
#import "FilterToolbar.h"

@implementation FilterMainScrollView

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 20)];
		scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 40, 320, 20)];
        pageControl.numberOfPages = 1;
        pageControl.currentPage   = 0;
        pageControl.hidesForSinglePage = YES;
        pageControl.userInteractionEnabled = NO;
        
        featuredViews = [[NSMutableArray alloc] initWithCapacity:0];
        
        [self addSubview:scrollView];
        [self addSubview:pageControl];
            
        indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, 0, 320, 364) andType:kLargeIndicator];
        indicator.message.text = @"Loading...";
    }
    
    return self;
}

//need to pass stack controller down to each view - this could be a hack or we could leave it this way
-(void)setStackController:(FilterStackController *)stack {
	stackController = stack;
	for(FilterMainFeaturedView *aView in featured) {
		aView.stackController = stack;
	}
}

-(void)refreshData {
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:nil andType:kFilterAPITypeGeoGetFeaturedBands andCallback:self];
    [self addSubview:indicator];
    [indicator startAnimating];
    
    for(FilterMainFeaturedView *oldView in featuredViews) {
        [oldView removeFromSuperview];
    }
    
    [featuredViews removeAllObjects];
}


- (void) configureToolbar {
    [[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeNone];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	[[FilterToolbar sharedInstance] showLogo];
}

#pragma mark - 
#pragma mark UIScrollViewDelegate conformance

- (void)scrollViewDidScroll:(UIScrollView *)modifiedScrollView {
    NSInteger page = (modifiedScrollView.contentOffset.x + modifiedScrollView.center.x) / (modifiedScrollView.frame.size.width);
    
    pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [[featuredViews objectAtIndex:pageControl.currentPage] updateRockMeter];
}

#pragma mark - 
#pragma mark FilterAPIOperationDelegate conformance
-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	
    NSMutableArray *tempViews = [[NSMutableArray alloc] initWithCapacity:0];
    
	switch (filterop.type) {
			
		case kFilterAPITypeGeoGetFeaturedBands: {
			
            [indicator stopAnimatingAndRemove];
            
            featured = [[NSMutableArray alloc] initWithArray:(NSArray*)data];
            
            //TODO: change this once paginated results are returned
            NSInteger max = MIN([featured count], 5);
            
            for(int i = 0; i < max; i++) {
                FilterMainFeaturedView *newView = [[FilterMainFeaturedView alloc] initWithFrame:CGRectMake(0 + (self.frame.size.width * i), 0, self.frame.size.width, self.frame.size.height - 60)];
                
                newView.stackController = self.stackController;
                
                [newView setInfoWithData:[featured objectAtIndex:i]];
                
                [scrollView addSubview:newView];
                
                [tempViews addObject: newView];
                
                [newView release];
            }
        
            [featuredViews addObjectsFromArray:tempViews];
            
            scrollView.contentSize = CGSizeMake(320 * max, self.frame.size.height - 60);
            [pageControl setNumberOfPages:max];
			
            if ([featuredViews count] > 0) {
                [[featuredViews objectAtIndex:pageControl.currentPage] updateRockMeter];
            }
		}
            break;	
		default:
			break;
	}
    [tempViews release];
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
