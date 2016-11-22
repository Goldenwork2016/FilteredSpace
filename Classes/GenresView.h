//
//  GenresView.h
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "LoadingIndicator.h"
#import "FilterAPIOperationQueue.h"

@interface GenresView : FilterView <UITableViewDelegate, UITableViewDataSource, FilterAPIOperationDelegate>{

    UIImageView *backgroundImage;
	UITableView *genresTable_;
	NSMutableArray *genres_;
	NSMutableArray *checked_;
    LoadingIndicator *indicator;
}

@end
