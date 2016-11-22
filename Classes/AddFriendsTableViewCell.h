//
//  AddFriendsTableViewCell.h
//  TheFilter
//
//  Created by John Thomas on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddFriendsTableViewCell : UITableViewCell {

	UILabel *profileName_;
	
	UIImageView *profileImage_;
	
}

@property (nonatomic, readonly, retain) UILabel *profileName;
@property (nonatomic, readonly, retain) UIImageView *profileImage;

@end
