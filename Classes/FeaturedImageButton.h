//
//  FeaturedImageButton.h
//  TheFilter
//
//  Created by Ben Hine on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FeaturedImageButton : UIControl {

	UIImageView *imageView_;
	
}

@property (retain) UIImageView *imageView;

- (void)setImageURL:(NSString*)url;

@end
