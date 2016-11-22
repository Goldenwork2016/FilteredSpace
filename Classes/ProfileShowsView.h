//
//  ProfileShowsView.h
//  TheFilter
//
//  Created by Ben Hine on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterDataObjects.h"
#import "FilterStackController.h"
#import "Common.h"

typedef enum {
	ProfileType_None = 0,
	ProfileType_Checkin = 1,
	ProfileType_Shows = 2,
} ProfileViewType;

#pragma -
#pragma ProfileShowsData

@interface ProfileShowsData : NSObject {

    NSInteger showID_;
    NSString *posterURL_;
    
    BOOL useBookmark_;
}

@property (nonatomic, assign) NSInteger showID;
@property (nonatomic, retain) NSString *posterURL;
@property (nonatomic, assign) BOOL useBookmark;

@end


#pragma -
#pragma ProfileShowsView

@interface ProfileShowsView : UIScrollView <FilterAPIOperationDelegate>{

    FilterPaginator *pager_;
    ProfileViewType type_;
    
    UIButton *moreButton_;
	NSMutableArray *showsArray_;    // this needs to be an array of showIDs
	
	FilterStackController *stackController_;
}

@property (nonatomic, retain) FilterPaginator* pager_;
@property (nonatomic, assign) ProfileViewType type;
@property (nonatomic, retain) NSMutableArray *showsArray;
@property (nonatomic, retain) FilterStackController *stackController;


- (void)addShowToArray:(ProfileShowsData*)show;

@end
