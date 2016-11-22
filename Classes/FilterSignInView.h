//
//  FilterSignInView.h
//  TheFilter
//
//  Created by John Thomas on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"

@interface FilterSignInView : FilterView {

	UIImageView *backgroundImage;
	UIButton *joinButton, *loginButton;
    UIControl *serverButton;
    UILabel *welcomeLabel;
}

@end
