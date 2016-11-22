//
//  FilterPosterView.h
//  TheFilter
//
//  Created by John Thomas on 2/18/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FilterDataObjects.h"

@interface FilterPosterView : UIControl {

	UIImageView *posterImage_;
	UIImageView *bookmarkImage;
	
	NSInteger filterShowID_;
}    
@property (nonatomic, assign) NSInteger filterShowID;
@property (nonatomic, retain) UIImageView *posterImage;


- (id)initWithFrame:(CGRect)frame withShow:(FilterShow*)showObj withBookmark:(BOOL)useBookmark;
- (id)initWithFrame:(CGRect)frame withDictionary:(NSDictionary*)dict;
- (void)setImageCornerRadius:(NSInteger)radius;

@end
