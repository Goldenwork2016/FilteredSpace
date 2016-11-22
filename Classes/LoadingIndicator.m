//
//  LoadingIndicator.m
//  TheFilter
//
//  Created by Patrick Hernandez on 4/5/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import "LoadingIndicator.h"
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.85 green:0.83 blue:0.83 alpha:1]

@interface  LoadingIndicator ()

- (void) setupSmallIndicator;
- (void) setupLargeIndicator;
- (void) setupPlayerIndicator;

@end

@implementation LoadingIndicator

@synthesize message;

#pragma mark - 
#pragma mark Initialization

- (id) initWithFrame:(CGRect)frame andType:(kIndicatorType)type {
    self = [super initWithFrame:frame];
    if (self) {
        
        type_ = type;
        
        switch (type) {
            case kSmallIndicator: {
                [self setupSmallIndicator];
            }
                break;
            case kLargeIndicator: {
                fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
                fadeView.backgroundColor = [UIColor blackColor];
                fadeView.alpha = 0.0;
                [self addSubview:fadeView];
                
                [self setupLargeIndicator];
            }
                break;
            case kPlayerIndicator: {
                [self setupPlayerIndicator];
            }
            default:
                break;
        }
    }
    return self;
}

- (void) setupSmallIndicator {
    
    backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sm_indicator_bkg.png"]];
    midCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sm_s_loading.png"]];
    outCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sm_l_loading.png"]];
    
    [self addSubview:backView];
    [self addSubview:midCircle];
    [self addSubview:outCircle];
}

- (void) setupLargeIndicator {
    
    backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_bkg.png"]];
    backgroundView.alpha = 0.0;
    backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lrg_indicator_bkg.png"]];
    midCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lrg_s_loading.png"]];
    outCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lrg_l_loading.png"]];
    
    message = [[UILabel alloc] initWithFrame:CGRectMake(10, backgroundView.center.y + 20, backgroundView.frame.size.width - 20, 20)];
    message.font = FILTERFONT(16);
    message.textColor = LIGHT_TEXT_COLOR;
    message.backgroundColor = [UIColor clearColor];
    message.textAlignment = UITextAlignmentCenter;
    
    backView.center = midCircle.center = outCircle.center = CGPointMake(backgroundView.center.x, 35);
    backgroundView.center = fadeView.center;
    
    [self addSubview:backgroundView];
    [backgroundView addSubview:message];
    [backgroundView addSubview:backView];
    [backgroundView addSubview:midCircle];
    [backgroundView addSubview:outCircle];
}

- (void) setupPlayerIndicator {
    
    backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"player_indicator_bkg.png"]];
    midCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"player_s_loading.png"]];
    outCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"player_l_loading.png"]];
    
    [self addSubview:backView];
    [self addSubview:midCircle];
    [self addSubview:outCircle];
}

#pragma mark - 
#pragma mark Animations

- (void) startAnimating {
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{ 
                         fadeView.alpha = 0.5;
                         backgroundView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){}];
    
    CAKeyframeAnimation *leftAnimation = [CAKeyframeAnimation animation];
	leftAnimation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.13, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(6.26, 0,0,1)],
						   nil];
	leftAnimation.cumulative = YES;
	leftAnimation.duration = 1.5;
	leftAnimation.repeatCount = HUGE_VALF;
	leftAnimation.removedOnCompletion = YES;
    
    [outCircle.layer addAnimation:leftAnimation forKey:@"transform"];
    
    CAKeyframeAnimation *rightAnimation = [CAKeyframeAnimation animation];
	rightAnimation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(6.26, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.13, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,0,1)],
						   nil];
	rightAnimation.cumulative = YES;
	rightAnimation.duration = 1.5;
	rightAnimation.repeatCount = HUGE_VALF;
	rightAnimation.removedOnCompletion = YES;
    
    [midCircle.layer addAnimation:rightAnimation forKey:@"transform"];
}

- (void) stopAnimating {
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{ 
                         fadeView.alpha = 0.0;
                         backgroundView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){}];
    
    [midCircle.layer removeAnimationForKey:@"transform"];
    [outCircle.layer removeAnimationForKey:@"transform"];
}

- (void) stopAnimatingAndRemove {
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{ 
                         fadeView.alpha = 0.0;
                         backgroundView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [midCircle.layer removeAnimationForKey:@"transform"];
                         [outCircle.layer removeAnimationForKey:@"transform"];
                         [self removeFromSuperview];
                     }];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
    if (type_ == kLargeIndicator) {
        [backgroundView release];
    }
    [message release];
    [backView release];
    [midCircle release];
    [outCircle release];
    
    [super dealloc];
}

@end
