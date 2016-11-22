//
//  NotificationsTableViewCell.h
//  TheFilter
//
//  Created by Patrick Hernandez on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NotificationsTableViewCell : UITableViewCell {

	UIButton *button;
	UIImageView *leftImageView;
	UILabel *notifactionLabel;
	UILabel *nameLabel;
	UILabel *locationLabel;
	
}

@property (nonatomic, retain) UIImageView *leftImageView;
@property (nonatomic, retain) UILabel *notificationLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *locationLabel;
@property (nonatomic, retain) UIButton *button;
@end
