//
//  FilterLoginView.h
//  TheFilter
//
//  Created by Ben Hine on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "Common.h"

@interface FilterLoginView : FilterView <UITextFieldDelegate, FilterAPIOperationDelegate> {

	
    UILabel *loginLabel;
    
	UITextField *userField, *passField;
	
    UIButton *forgotButton;
	
	UIImageView *backgroundImage;
}

-(void)sendLoginRequest;

@end
