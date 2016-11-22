//
//  FilterTabButton.h
//  TheFilter
//
//  Created by Ben Hine on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FilterTabButton : UIControl {

	UIImageView *unselectedImage_;
	UIImageView *selectedImage_;
	
	
	BOOL disableTap;
	
}

@property (nonatomic, retain) UIImageView *unselectedImage, *selectedImage;



@end
