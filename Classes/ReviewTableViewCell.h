//
//  ReviewTableViewCell.h
//  TheFilter
//
//  Created by Patrick Hernandez on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReviewTableViewCell : UITableViewCell {
	UILabel *nameLabel;
	UIButton *voteButton;
	
}
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UIButton *voteButton;
@end
