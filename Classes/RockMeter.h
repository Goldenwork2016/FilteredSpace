//
//  RockMeter.h
//  TheFilter
//
//  Created by Ben Hine on 2/23/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NeedleView;

@interface RockMeter : UIView {

	UIImageView *meterBottomLayer;
	UIImageView *meterTopLayer;
	UILabel *followersLabel;
    
	CGFloat rockLevel;
	
	NeedleView *needle;
	
}

-(void)setRockLevel:(CGFloat)level andFollowers:(NSInteger)followers;
- (void)bounceNeedle:(CGFloat)bounce;

@end
