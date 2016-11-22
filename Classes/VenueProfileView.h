//
//  VenueProfileView.h
//  TheFilter
//
//  Created by Patrick Hernandez on 5/18/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterView.h"
#import "FilterDataObjects.h"
#import "LoadingIndicator.h"

@interface VenueProfileView : FilterView <UITableViewDelegate, UITableViewDataSource, FilterAPIOperationDelegate> {
    UIImageView *venueImage_;
    UITableView *tableView_;
    UIView *headerView_;
    
    UILabel *venueName_;
    UILabel *venueCity_;
    
    LoadingIndicator *indicator_;
    
    NSArray *venueArray_;
    
    FilterVenue *venue_;
    
    NSNumber *ID_;
}

- (id)initWithFrame:(CGRect)frame andID:(NSNumber *)ID;

@property (nonatomic, retain) FilterVenue *venue;

@end
