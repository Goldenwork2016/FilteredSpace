//
//  FilterToolbarButton.h
//  TheFilter
//
//  Created by Ben Hine on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"


@interface FilterToolbarButton : UIButton {

	ToolbarButtonType buttonType_;
	
}

@property (nonatomic, assign) ToolbarButtonType toolbarButtonType;

@end
