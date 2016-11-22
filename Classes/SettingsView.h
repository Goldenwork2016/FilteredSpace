//
//  SettingsView.h
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"

typedef enum {
	
	kEditProfileRow,
	kServicesRow,
    kChangePassword,

} SettingsRowType;

@interface SettingsView : FilterView <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {

	UITableView *settingsTable_;
	
	
}

@end
