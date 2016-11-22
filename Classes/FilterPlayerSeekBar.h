//
//  FilterPlayerSeekBar.h
//  TheFilter
//
//  Created by Ben Hine on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FilterPlayerSeekBar : UIControl {

	UILabel *leftLabel, *rightLabel;
	
	CGFloat currentProgress_, totalLength_, downloadProgress_;
	
	UIImageView *progressBackground;
	UIImage *downloadProgressImage, *playProgressImage, *buttonImage;
	
	BOOL scrubbing;
	
	NSDateFormatter *dateFormatter;
	
}

@property (nonatomic, assign) CGFloat currentProgress, totalLength, downloadProgress;
@property (readonly, assign) BOOL scrubbing;

- (void) resetBar;

@end
