//
//  BandNewsTableCell.h
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BandNewsTableCell : UITableViewCell {

	UILabel *primaryLabel_;
	UILabel *bodyLabel_;
	UILabel *timestampLabel_;
	UIImageView *artistImage_;
}

@property (nonatomic, retain, readonly) UILabel *primaryLabel;
@property (nonatomic, retain, readonly) UILabel *bodyLabel;
@property (nonatomic, retain, readonly) UILabel *timestampLabel;
@property (nonatomic, retain, readonly) UIImageView *artistImage;

- (void)setImageURL:(NSString*)url;
- (void)adjustCellFrames:(CGSize)labelSize;
- (void)resetImage;
@end
