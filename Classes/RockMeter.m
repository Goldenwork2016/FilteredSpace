//
//  RockMeter.m
//  TheFilter
//
//  Created by Ben Hine on 2/23/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "RockMeter.h"
#import "NeedleView.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1]
@implementation RockMeter


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		meterBottomLayer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"meter_background.png"]];
		[self addSubview:meterBottomLayer];
        
		needle = [[NeedleView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height * 6.5)];
		[self addSubview:needle];
		self.clipsToBounds = YES;
        
        followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 56, 150, 14)];
        followersLabel.backgroundColor = [UIColor clearColor];
        followersLabel.textColor = DARK_TEXT_COLOR;
        followersLabel.font = FILTERFONT(10);
        followersLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:followersLabel];
		
		meterTopLayer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_gloss_meter.png"]];
		[self addSubview:meterTopLayer];
		
    }
    return self;
}

-(void)setRockLevel:(CGFloat)level andFollowers:(NSInteger)followers {
    
	CGFloat tenAngle = 0.97;
	rockLevel        = level;
    
    if (!(followers == 1)) {
        followersLabel.text = [NSString stringWithFormat:@"%d followers",followers];
    }
    else {
        followersLabel.text = [NSString stringWithFormat:@"%d follower", followers];
    }
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:2];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	needle.transform = CGAffineTransformMakeRotation(tenAngle * (level / 100));
	[UIView commitAnimations];
	
}

- (void)bounceNeedle:(CGFloat)bounce {
    CGFloat xRotation = 0.97 * (rockLevel / 100.0);
    
    CAKeyframeAnimation *animation  = [CAKeyframeAnimation animation];
	animation.values                = [NSArray arrayWithObjects:
                                            [NSValue valueWithCATransform3D:CATransform3DMakeRotation(xRotation, 0,0,1)],
                                            [NSValue valueWithCATransform3D:CATransform3DMakeRotation(xRotation + bounce, 0,0,1)],
                                            [NSValue valueWithCATransform3D:CATransform3DMakeRotation(xRotation, 0,0,1)],
                                            nil];
	animation.cumulative            = YES;
	animation.duration              = .4;
	animation.repeatCount           = 0;
	animation.removedOnCompletion   = YES;
    
    [needle.layer addAnimation:animation forKey:@"transform"];
}

- (void)dealloc {
    [meterBottomLayer release];
    [needle release];
    [followersLabel release];
    [meterTopLayer release];
    
    [super dealloc];
}


@end
