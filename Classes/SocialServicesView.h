//
//  SocialServicesView.h
//  TheFilter
//
//  Created by John Thomas on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"

@interface SocialServicesView : FilterView <UITableViewDelegate, UITableViewDataSource,
											UIAlertViewDelegate> 
{

	NSArray *serviceIdentifiers_;

	UITableView *servicesTable_;
	UIButton *logoutButton;
    UIAlertView *objAlertView;
}

@end
