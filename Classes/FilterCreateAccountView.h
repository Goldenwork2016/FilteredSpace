//
//  FilterCreateAccountView.h
//  TheFilter
//
//  Created by John Thomas on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "Common.h"
#import "LoadingIndicator.h"

typedef enum {
		
	PickerType_None,
	PickerType_Gender,
	PickerType_Birth
	
} FilterPickerType;

@protocol FilterCreateAccountViewDelegate

-(void)presentImagePicker:(UIImagePickerController*)picker;

-(void)accountCreatedWithObject:(id)data;

@end


@interface FilterCreateAccountView : FilterView <UITextFieldDelegate, FilterAPIOperationDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{

	UIImageView *backgroundImage;
	
	UIButton *avatarImage;
    UIImage *prevImage;
    
	UIScrollView *accountScrollView;
	UIView *currentCellFocus;
	UITextField *firstName, *lastName, *location;
	
	UIControl *emailControl, *passwordControl, *password2Control;
	UILabel *emailLabel, *passwordLabel, *password2Label;
	UITextField *emailValue, *passwordValue, *password2Value;

	UIControl *genderControl, *birthConrol;
	UILabel *genderLabel, *birthLabel;
	UILabel *genderValue, *birthValue;
	
	UIPickerView *cellPicker;
	FilterPickerType pickerType;
	NSArray *genderArray;
	NSArray *yearArray;
	
    BOOL modifying;
    BOOL imageChanged;
    BOOL removeImage;
	id<FilterCreateAccountViewDelegate> delegate_;
    
    LoadingIndicator *indicator;
    LoadingIndicator *pictureIndicator;
}

@property (nonatomic, assign) id<FilterCreateAccountViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame asModify:(BOOL)modify;
- (void)sendCreateRequest;

@end
