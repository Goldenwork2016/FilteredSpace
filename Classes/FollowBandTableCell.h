//
//  FollowBandTableCell.h
//  TheFilter
//
//  Created by Ben Hine on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FollowBandTableCell : UITableViewCell {

	UILabel *nameLabel_;
	
	UIImageView *profileImage_;
	
	
	
	
}

@property (nonatomic, readonly, retain) UILabel *nameLabel;
@property (nonatomic, retain) UIImageView *profileImage;

- (void)setImageURL:(NSString*)url;
- (void)resetImage;

@end