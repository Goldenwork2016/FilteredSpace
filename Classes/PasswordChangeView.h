//
//  PasswordChangeView.h
//  TheFilter
//
//  Created by Patrick Hernandez on 4/6/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "Common.h"

@interface PasswordChangeView : FilterView <UITextFieldDelegate, FilterAPIOperationDelegate>{
    
	UITextField *oldPassField, *pass1Field, *pass2Field;
	
	UIImageView *backgroundImage;
}

- (void)changePasswordRequest;

@end
