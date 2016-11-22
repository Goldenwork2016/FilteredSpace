//
//  FilterCheckInCommentField.h
//  TheFilter
//
//  Created by John Thomas on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"


@interface FilterCheckInCommentView : UIView {

	UITextView *commentView_;
}

@property (nonatomic, retain) UITextView *commentView;

@end
