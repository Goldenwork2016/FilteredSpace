//
//  FilterBandVideoTableCell.h
//  TheFilter
//
//  Created by John Thomas on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterYoutubeView.h"

@interface FilterBandVideoTableCell : UITableViewCell {

	UILabel *durationLabel_;
	
	UILabel *nameLabel_;
	
	UIImageView *videoImage_;

	UIImageView *chevronView_;
    
    FilterYoutubeView *webView_;
    UIWebView *test;
}

@property (nonatomic, retain) UILabel *durationLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UIImageView *videoImage;
@property (nonatomic, retain) FilterYoutubeView *webView;

@end
