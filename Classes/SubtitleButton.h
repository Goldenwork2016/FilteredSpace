//
//  SubtitleButton.h
//  TheFilter
//
//  Created by Ben Hine on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SubtitleButton : UIButton {

	UILabel *secondaryLabel_;
	UILabel *primaryLabel_;
	
}

@property (nonatomic, readonly, retain) UILabel *primaryLabel, *secondaryLabel;


@end
