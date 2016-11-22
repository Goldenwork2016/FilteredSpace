//
//  BandsDirectoryTableViewCell.h
//  TheFilter
//
//  Created by Patrick Hernandez on 3/9/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BandsDirectoryTableViewCell : UITableViewCell {
	
	UILabel *genreLabel_, *artistLabel_;

	UIImageView *artistImage_;

}

@property (nonatomic, readonly, retain) UILabel *genreLabel, *artistLabel;
@property (nonatomic, readonly, retain) UIImageView *artistImage;

- (void)setImageURL:(NSString*)url;
- (void)resetImage;

@end

