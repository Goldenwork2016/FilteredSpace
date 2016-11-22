//
//  LoadingIndicator.h
//  TheFilter
//
//  Created by Patrick Hernandez on 4/5/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    kSmallIndicator,
    kLargeIndicator,
    kPlayerIndicator,
    
} kIndicatorType;

@interface LoadingIndicator : UIView {
    UIView *fadeView;
    UIImageView *backgroundView;
    UIImageView *backView;
    UIImageView *midCircle;
    UIImageView *outCircle;
    UILabel *message;
    
    CGFloat *currentRotation;
    kIndicatorType type_;
}

@property (nonatomic, retain) UILabel *message;

- (id) initWithFrame:(CGRect)frame andType:(kIndicatorType)type;
- (void) startAnimating;
- (void) stopAnimating;
- (void) stopAnimatingAndRemove;
@end
