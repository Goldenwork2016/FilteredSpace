//
//  VenueProfileTableViewCell.h
//  TheFilter
//
//  Created by Patrick Hernandez on 5/23/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface VenueProfileTableViewCell : UITableViewCell {
    UIImageView* background_;
    UILabel *contentLabel_;
    UILabel *label_;
}

- (void)adjustCellFrames:(CGSize)labelSize; 

@property (nonatomic, retain) UIImageView *background;
@property (nonatomic, retain) UILabel *contentLabel;
@property (nonatomic, retain) UILabel *label;

@end
