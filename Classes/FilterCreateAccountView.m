//
//  FilterCreateAccountView.m
//  TheFilter
//
//  Created by John Thomas on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterCreateAccountView.h"
#import "FilterAPIOperationQueue.h"
#import "FilterToolbar.h"
#import "FilterCache.h"
#import "SFHFKeychainUtils.h"
#import "FilterGlobalImageDownloader.h"
#import "FilterAPIOperationQueue.h"

#define kEmailSection		0
#define kGenderBirthSection	1

#define kGenderRow	0
#define kBirthRow	1
				
#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1.0]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

#define CELL_COLOR [UIColor colorWithRed:.27 green:.27 blue:.27 alpha:1.0]

@implementation FilterCreateAccountView

@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame asModify:(BOOL)modify{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		modifying = modify;
        imageChanged = NO;
        removeImage = NO;
        
		backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
		backgroundImage.frame = CGRectMake(0, -65, 320, 480);
		[self addSubview:backgroundImage];
			
		accountScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		accountScrollView.contentSize = CGSizeMake(320, 740);
		[self addSubview:accountScrollView];
		

        if(modifying) {
            pictureIndicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(30, 30, 21, 21) andType:kSmallIndicator];
            [accountScrollView addSubview:pictureIndicator];
        }
        
		avatarImage = [UIButton buttonWithType:UIButtonTypeCustom];
		[avatarImage setImage:[UIImage imageNamed:@"no_image_avatar.png"] forState:UIControlStateNormal];
		[avatarImage addTarget:self action:@selector(profileImagePushed:) forControlEvents:UIControlEventTouchUpInside];
		avatarImage.frame = CGRectMake(10, 10, 60, 60);
		avatarImage.clipsToBounds = YES;
		avatarImage.layer.cornerRadius = 5;
		[accountScrollView addSubview:avatarImage];
        
        UILabel *photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, 60, 15)];
        photoLabel.text = @"Add a photo";
        photoLabel.textColor = LIGHT_TEXT_COLOR;
        photoLabel.font = FILTERFONT(8);
        photoLabel.backgroundColor = [UIColor clearColor];
        photoLabel.textAlignment = UITextAlignmentCenter;
        [accountScrollView addSubview:photoLabel];
        
		// background for the firstname, lastname, location
		UIView *topBackground = [[UIView alloc] initWithFrame:CGRectMake(85, 10, 225, 88)];
		UIView *topDivider1 = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 225, 1)];
		//UIView *topDivider2 = [[UIView alloc] initWithFrame:CGRectMake(0, 87, 225, 1)];
		topDivider1.backgroundColor = [UIColor blackColor];
		//topDivider2.backgroundColor = [UIColor blackColor];
		[topBackground addSubview:topDivider1];
		//[topBackground addSubview:topDivider2];
		
		topBackground.backgroundColor = CELL_COLOR;
		topBackground.layer.cornerRadius = 10;
		[topBackground.layer setBorderWidth: 1.0];
		[topBackground.layer setBorderColor: [[UIColor blackColor] CGColor]];
		[accountScrollView addSubview:topBackground];
		
		// background for the email and password
		if(modifying) {
            UIView *middleBackground = [[UIView alloc] initWithFrame:CGRectMake(10, 120, 300, 44)];
            UIView *middleSegment = [[UIView alloc] initWithFrame:CGRectMake(140, 0, 1, 44)];
            middleSegment.backgroundColor = [UIColor blackColor];
            [middleBackground addSubview:middleSegment];
            
            middleBackground.backgroundColor = CELL_COLOR;
            middleBackground.layer.cornerRadius = 10;
            [middleBackground.layer setBorderWidth: 1.0];
            [middleBackground.layer setBorderColor: [[UIColor blackColor] CGColor]];
            [accountScrollView addSubview:middleBackground];
        }
        else {
            UIView *middleBackground = [[UIView alloc] initWithFrame:CGRectMake(10, 120, 300, 132)];
            UIView *middleDivider1 = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 300, 1)];
            UIView *middleDivider2 = [[UIView alloc] initWithFrame:CGRectMake(0, 87, 300, 1)];
            UIView *middleSegment = [[UIView alloc] initWithFrame:CGRectMake(140, 0, 1, 132)];
            middleDivider1.backgroundColor = [UIColor blackColor];
            middleDivider2.backgroundColor = [UIColor blackColor];
            middleSegment.backgroundColor = [UIColor blackColor];
            [middleBackground addSubview:middleDivider1];
            [middleBackground addSubview:middleDivider2];
            [middleBackground addSubview:middleSegment];
            
            middleBackground.backgroundColor = CELL_COLOR;
            middleBackground.layer.cornerRadius = 10;
            [middleBackground.layer setBorderWidth: 1.0];
            [middleBackground.layer setBorderColor: [[UIColor blackColor] CGColor]];
            [accountScrollView addSubview:middleBackground];
        }
            
		firstName = [[UITextField alloc] initWithFrame:CGRectMake(95, 22, 205, 20)];
		firstName.font = FILTERFONT(15);
		firstName.textColor = LIGHT_TEXT_COLOR;
		firstName.adjustsFontSizeToFitWidth = YES;
		firstName.minimumFontSize = 10;
		firstName.textAlignment = UITextAlignmentLeft;
		firstName.backgroundColor = [UIColor clearColor];
		firstName.placeholder = @"Profile Name";
        firstName.autocapitalizationType = UITextAutocapitalizationTypeNone;
		firstName.delegate = self;
		[accountScrollView addSubview:firstName];
		/*
		lastName = [[UITextField alloc] initWithFrame:CGRectMake(95, 66, 205, 20)];
		lastName.font = FILTERFONT(15);
		lastName.textColor = LIGHT_TEXT_COLOR;
		lastName.adjustsFontSizeToFitWidth = YES;
		lastName.minimumFontSize = 10;
		lastName.textAlignment = UITextAlignmentLeft;
		lastName.backgroundColor = [UIColor clearColor];
		lastName.placeholder = @"Last Name";
		lastName.delegate = self;
		[accountScrollView addSubview:lastName];
		 */
		 
		location = [[UITextField alloc] initWithFrame:CGRectMake(95, 66, 205, 20)];
		location.font = FILTERFONT(15);
		location.textColor = LIGHT_TEXT_COLOR;
		location.adjustsFontSizeToFitWidth = YES;
		location.minimumFontSize = 10;
		location.textAlignment = UITextAlignmentLeft;
		location.backgroundColor = [UIColor clearColor];
		location.placeholder = @"Location (Zip Code)";
		location.keyboardType = UIKeyboardTypeNumberPad;
		location.delegate = self;
		[accountScrollView addSubview:location];
		
		emailControl = [[UIControl alloc] initWithFrame:CGRectMake(20, 122, 280, 40)];
		[emailControl addTarget:self action:@selector(cellTapped:) forControlEvents:UIControlEventTouchUpInside];
		[accountScrollView addSubview:emailControl];
		
		emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 132, 120, 20)];
		emailLabel.font = FILTERFONT(15);
		emailLabel.textColor = MEDIUM_TEXT_COLOR;
		emailLabel.adjustsFontSizeToFitWidth = YES;
		emailLabel.minimumFontSize = 10;
		emailLabel.textAlignment = UITextAlignmentRight;
		emailLabel.backgroundColor = [UIColor clearColor];
		emailLabel.text = @"Email";
		[accountScrollView addSubview:emailLabel];
		
		emailValue = [[UITextField alloc] initWithFrame:CGRectMake(160, 132, 140, 20)];
		emailValue.font = FILTERFONT(15);
		emailValue.textColor = LIGHT_TEXT_COLOR;
		emailValue.adjustsFontSizeToFitWidth = YES;
		emailValue.minimumFontSize = 10;
		emailValue.autocapitalizationType = UITextAutocapitalizationTypeNone; 
        emailValue.autocorrectionType = UITextAutocorrectionTypeNo;
		emailValue.textAlignment = UITextAlignmentLeft;
        emailValue.keyboardType = UIKeyboardTypeEmailAddress;
		emailValue.backgroundColor = [UIColor clearColor];
		emailValue.delegate = self;
		[accountScrollView addSubview:emailValue];
		
        if(modifying) {
            firstName.enabled = NO;
            //firstName.alpha = 0.3;
        }
		if(!modifying){
            passwordControl = [[UIControl alloc] initWithFrame:CGRectMake(20, 166, 280, 40)];
            [passwordControl addTarget:self action:@selector(cellTapped:) forControlEvents:UIControlEventTouchUpInside];
            [accountScrollView addSubview:passwordControl];

            passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 176, 120, 20)];
            passwordLabel.font = FILTERFONT(15);
            passwordLabel.textColor = MEDIUM_TEXT_COLOR;
            passwordLabel.adjustsFontSizeToFitWidth = YES;
            passwordLabel.minimumFontSize = 10;
            passwordLabel.textAlignment = UITextAlignmentRight;
            passwordLabel.backgroundColor = [UIColor clearColor];
            passwordLabel.text = @"Password";
            [accountScrollView addSubview:passwordLabel];

            passwordValue = [[UITextField alloc] initWithFrame:CGRectMake(160, 176, 140, 20)];
            passwordValue.font = FILTERFONT(15);
            passwordValue.textColor = LIGHT_TEXT_COLOR;
            passwordValue.adjustsFontSizeToFitWidth = YES;
            passwordValue.minimumFontSize = 10;
            passwordValue.secureTextEntry = YES;
            passwordValue.autocorrectionType =UITextAutocorrectionTypeNo;
            passwordValue.autocapitalizationType = UITextAutocapitalizationTypeNone;
            passwordValue.textAlignment = UITextAlignmentLeft;
            passwordValue.backgroundColor = [UIColor clearColor];
            passwordValue.delegate = self;
            [accountScrollView addSubview:passwordValue];
            
            password2Control = [[UIControl alloc] initWithFrame:CGRectMake(20, 210, 280, 40)];
            [password2Control addTarget:self action:@selector(cellTapped:) forControlEvents:UIControlEventTouchUpInside];
            [accountScrollView addSubview:password2Control];
            
            password2Label = [[UILabel alloc] initWithFrame:CGRectMake(20, 220, 120, 20)];
            password2Label.font = FILTERFONT(15);
            password2Label.textColor = MEDIUM_TEXT_COLOR;
            password2Label.adjustsFontSizeToFitWidth = YES;
            password2Label.minimumFontSize = 10;
            password2Label.textAlignment = UITextAlignmentRight;
            password2Label.backgroundColor = [UIColor clearColor];
            password2Label.text = @"Re-enter Password";
            [accountScrollView addSubview:password2Label];
            
            password2Value = [[UITextField alloc] initWithFrame:CGRectMake(160, 220, 140, 20)];
            password2Value.font = FILTERFONT(15);
            password2Value.textColor = LIGHT_TEXT_COLOR;
            password2Value.adjustsFontSizeToFitWidth = YES;
            password2Value.minimumFontSize = 10;
            password2Value.secureTextEntry = YES;
            password2Value.autocorrectionType =UITextAutocorrectionTypeNo;
            password2Value.autocapitalizationType = UITextAutocapitalizationTypeNone;
            password2Value.textAlignment = UITextAlignmentLeft;
            password2Value.backgroundColor = [UIColor clearColor];
            password2Value.delegate = self;
            [accountScrollView addSubview:password2Value];
        }
		
        NSInteger y_offset;
        
        if (modifying) {
            y_offset = 80;
        }
        else {
           y_offset = 0;
        }
        
        // background for the gender and birth
		UIView *bottomBackground = [[UIView alloc] initWithFrame:CGRectMake(10, 270 - y_offset, 300, 88)];
		UIView *bottomDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 300, 1)];
		UIView *bottomSegment = [[UIView alloc] initWithFrame:CGRectMake(140, 0, 1, 88)];
		bottomDivider.backgroundColor = [UIColor blackColor];
		bottomSegment.backgroundColor = [UIColor blackColor];
		[bottomBackground addSubview:bottomDivider];
		[bottomBackground addSubview:bottomSegment];
        
		bottomBackground.backgroundColor = CELL_COLOR;
		bottomBackground.layer.cornerRadius = 10;
		[bottomBackground.layer setBorderWidth: 1.0];
		[bottomBackground.layer setBorderColor: [[UIColor blackColor] CGColor]];
		[accountScrollView addSubview:bottomBackground];
        
		genderControl = [[UIControl alloc] initWithFrame:CGRectMake(20, 272 - y_offset, 280, 40)];
		[genderControl addTarget:self action:@selector(cellTapped:) forControlEvents:UIControlEventTouchUpInside];
		[accountScrollView addSubview:genderControl];

		genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 282 - y_offset, 120, 20)];
		genderLabel.font = FILTERFONT(15);
		genderLabel.textColor = MEDIUM_TEXT_COLOR;
		genderLabel.adjustsFontSizeToFitWidth = YES;
		genderLabel.minimumFontSize = 10;
		genderLabel.textAlignment = UITextAlignmentRight;
		genderLabel.backgroundColor = [UIColor clearColor];
		genderLabel.text = @"Gender";
		[accountScrollView addSubview:genderLabel];

		genderValue = [[UILabel alloc] initWithFrame:CGRectMake(160, 282 - y_offset, 140, 20)];
		genderValue.font = FILTERFONT(15);
		genderValue.textColor = LIGHT_TEXT_COLOR;
		genderValue.adjustsFontSizeToFitWidth = YES;
		genderValue.minimumFontSize = 10;
		genderValue.textAlignment = UITextAlignmentLeft;
		genderValue.backgroundColor = [UIColor clearColor];
		[accountScrollView addSubview:genderValue];
		
		
		birthConrol = [[UIControl alloc] initWithFrame:CGRectMake(20, 316 - y_offset, 280, 40)];
		[birthConrol addTarget:self action:@selector(cellTapped:) forControlEvents:UIControlEventTouchUpInside];
		[accountScrollView addSubview:birthConrol];

		birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 326 - y_offset, 120, 20)];
		birthLabel.font = FILTERFONT(15);
		birthLabel.textColor = MEDIUM_TEXT_COLOR;
		birthLabel.adjustsFontSizeToFitWidth = YES;
		birthLabel.minimumFontSize = 10;
		birthLabel.textAlignment = UITextAlignmentRight;
		birthLabel.backgroundColor = [UIColor clearColor];
		birthLabel.text = @"Year of Birth";
		[accountScrollView addSubview:birthLabel];

		birthValue = [[UILabel alloc] initWithFrame:CGRectMake(160, 326 - y_offset, 140, 20)];
		birthValue.font = FILTERFONT(15);
		birthValue.textColor = LIGHT_TEXT_COLOR;
		birthValue.adjustsFontSizeToFitWidth = YES;
		birthValue.minimumFontSize = 10;
		birthValue.textAlignment = UITextAlignmentLeft;
		birthValue.backgroundColor = [UIColor clearColor];
		[accountScrollView addSubview:birthValue];
        
		NSDate *now = [NSDate date];
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:now];
		NSInteger year = [components year] - 14;
		
		NSMutableArray *years = [[[NSMutableArray alloc] init] autorelease];
		for (int x = 0; x < 100; x++) {
			[years addObject:[NSString stringWithFormat:@"%d", year--]];
		}
		
		pickerType = PickerType_None;
		genderArray  = [[NSArray arrayWithObjects:@"Male",@"Female", nil] retain];
		yearArray = [[NSArray arrayWithArray:years] retain];

		cellPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 216)];
		cellPicker.showsSelectionIndicator = YES;
		cellPicker.dataSource = self;
		cellPicker.delegate = self;
		cellPicker.hidden = YES;
		[self addSubview:cellPicker];
		
        if(modifying) {
            indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height) andType:kLargeIndicator];
            indicator.message.text = @"Loading...";
            
            [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:nil andType:kFilterAPITypeGetAccount andCallback:self];
            
            [self addSubview:indicator];
            [indicator startAnimating];
            
        }
	}
		
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPlayerButton:NO];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];	
	
    if(!modifying) {
        [[FilterToolbar sharedInstance] showPrimaryLabel:@"New Account"];
        [[FilterToolbar sharedInstance] setRightButtonWithType:kToolbarButtonTypeCreateAccount];
    }
    else {
        [[FilterToolbar sharedInstance] showPrimaryLabel:@"Modify Account"];
        [[FilterToolbar sharedInstance] setRightButtonWithType:kToolbarButtonTypeDone];
    }
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
}

-(void)profileImagePushed:(id)sender {
    
	//if camera, show them an action sheet - otherwise just go straight to photo library
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		
		UIActionSheet *pickerActions = [[[UIActionSheet alloc] initWithTitle:@"Choose or Take a profile Picture" 
																	delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil 
														   otherButtonTitles:@"Remove Picture", @"Take Picture",@"Choose From Photos",nil] autorelease];
		[pickerActions showInView:self.superview];
		
	} else {
		
        UIActionSheet *pickerActions = [[[UIActionSheet alloc] initWithTitle:@"Choose or Take a profile Picture" 
                                                                    delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil 
                                                           otherButtonTitles:@"Remove Picture",@"Choose From Photos",nil] autorelease];
        [pickerActions showInView:self.superview];
		
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = YES;

	//if camera, show them an action sheet - otherwise just go straight to photo library
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

		switch (buttonIndex) {
            case 0://remove photo
                imageChanged = YES;            
                removeImage = YES;
                break;
            case 1://new photo
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                removeImage = NO;
                break;
            case 2://choose from photos
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                removeImage = NO;
                break;
            case 3: //Cancel button
                [picker release];
                return;
            default:
                break;
        }
        
    } else {
        
        switch (buttonIndex) {
            case 0://remove photo
                imageChanged = YES;            
                removeImage = YES;
                break;
            case 1://choose from photos
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                removeImage = NO;
                break;
            case 2: //Cancel button
                [picker release];
                return;
            default:
                break;
        }
    }
    
    if (modifying) {
        prevImage = [[avatarImage imageForState:UIControlStateNormal] retain];
        
        if (removeImage) {
            [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:nil andType:kFilterAPITypeAccountDeleteProfilePicture andCallback:self];
            [pictureIndicator startAnimating];
            [UIView animateWithDuration:.3 
                             animations:^{ avatarImage.alpha = 0.0; } 
                             completion:^(BOOL finished){  [avatarImage setImage:[UIImage imageNamed:@"no_image_avatar.png"] forState:UIControlStateNormal]; }];
        }
        else {
            [delegate_ presentImagePicker:picker];
        }
    }
    else {
        if (removeImage == NO) {
            [delegate_ presentImagePicker:picker];
        }
        else {
            [avatarImage setImage:[UIImage imageNamed:@"no_image_avatar.png"] forState:UIControlStateNormal];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	//TODO: pick the image outta here and store it - upload it to the server upon account create
    //JDH FIX     Wrong view controller was being dismissed
    [picker dismissModalViewControllerAnimated:YES];
	//[picker.parentViewController dismissModalViewControllerAnimated:YES];
    
    imageChanged = YES;
    
    [avatarImage setImage:[info objectForKey:UIImagePickerControllerEditedImage] forState:UIControlStateNormal];
    
    if(modifying) {
        NSData *data = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage], 1.0);
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:data,@"profile_picture",nil];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:dataDict andType:kFilterAPITypeAccountProfilePicture andCallback:self];
        
        [pictureIndicator startAnimating];
        [UIView animateWithDuration:.3 
                         animations:^{ avatarImage.alpha = 0.0; } 
                         completion:^(BOOL finished){ [avatarImage setImage:[info objectForKey:UIImagePickerControllerEditedImage] forState:UIControlStateNormal]; }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[picker.parentViewController dismissModalViewControllerAnimated:YES];
}


- (void)animatePickerIntoView:(BOOL)animated {	
    cellPicker.hidden = NO;
	
    float duration = (animated ? 0.3f : 0.0f);
    
    [UIView beginAnimations:@"AnimateIn" context:self];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
	
    cellPicker.frame = CGRectMake(0, 200, 320, 216);
	
    [UIView commitAnimations];
}

- (void)animatePickerOutofView:(BOOL)animated {
    float duration = (animated ? 0.3f : 0.0f);
	
    [UIView beginAnimations:@"AnimateOut" context:self];
    [UIView setAnimationDuration:duration];
        
    cellPicker.frame = CGRectMake(0, 480, 320, 216);

    [UIView commitAnimations];
}

- (void)cellTapped:(id)sender {
	
	[self endEditing:YES];
	
	UIControl *cell = sender;	
	if (pickerType != PickerType_None && cell != birthConrol && cell != genderControl)
		[self animatePickerOutofView:YES];
		
	pickerType = PickerType_None;
	if (cell == emailControl && ![emailValue isFirstResponder]) {
		[emailValue becomeFirstResponder];
	} else if (cell == passwordControl && ![passwordValue isFirstResponder]) {
		[passwordValue becomeFirstResponder];
	} else if (cell == password2Control && ![password2Label isFirstResponder]) {
		[password2Value becomeFirstResponder];
	} else if (cell == genderControl) {
		
		pickerType = PickerType_Gender;
		[self animatePickerIntoView:YES];
		[cellPicker reloadAllComponents];
		
		[accountScrollView setContentOffset:CGPointMake(0, MAX(0,genderControl.frame.origin.y-100)) animated:YES];

		if ([genderValue.text length] == 0) {   // set its initial state
            [cellPicker selectRow:0 inComponent:0 animated:YES];
			genderValue.text = [genderArray objectAtIndex:0];
        } else {
            NSInteger idx = [genderArray indexOfObject:genderValue.text];
            [cellPicker selectRow:idx inComponent:0 animated:NO];
        }

	} else if (cell == birthConrol) {
		
		pickerType = PickerType_Birth;
		[self animatePickerIntoView:YES];
		[cellPicker reloadAllComponents];
		
		[accountScrollView setContentOffset:CGPointMake(0, MAX(0,birthConrol.frame.origin.y-100)) animated:YES];

		if ([birthValue.text length] == 0) {    // set its initial state
            [cellPicker selectRow:18 inComponent:0 animated:YES];
			birthValue.text = [yearArray objectAtIndex:18];
		} else {
            NSInteger idx = [yearArray indexOfObject:birthValue.text];
            [cellPicker selectRow:idx inComponent:0 animated:NO];
        }
	}	
	
	currentCellFocus = cell;
}

- (void)donePushed:(id)button {
        
	// walk through fail cases
	if ([firstName.text length] == 0) {
		
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Missing Field"
								   message: @"Please fill in the username field."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
        
		return;
	}
	
	
	if ([location.text length] == 0) {
		
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Missing Field"
								   message: @"Please fill in the zip code field."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
        [errorAlert release];
        
		return;
	}
	if ([emailValue.text length] == 0) {
		
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Missing Field"
								   message: @"Please fill in the e-mail field."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
        [errorAlert release];
        
		return;
	}
	
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	
	[dict setObject:firstName.text forKey:@"username"];
	[dict setObject:emailValue.text forKey:@"email"];
	
	int genderIsNumber = 0;
	if([genderValue.text isEqualToString:@"Male"]) {
		genderIsNumber = 2;
	} else {
		genderIsNumber = 1;
	}
	
	[dict setObject:[NSNumber numberWithInt:genderIsNumber] forKey:@"gender"];
	[dict setObject:[NSString stringWithFormat:@"%@-01-01",birthValue.text] forKey:@"dob"];
	[dict setObject:location.text forKey:@"zipcode"];
    
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:dict andType:kFilterAPITypeAccountModify andCallback:self];
}

- (void)sendCreateRequest {
	
	// walk through fail cases
	if ([firstName.text length] == 0) {
		
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Missing Field"
								   message: @"Please fill in the username field."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
        
		return;
	}
	
	
	if ([location.text length] == 0) {
		
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Missing Field"
								   message: @"Please fill in the zip code field."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
        [errorAlert release];
        
		return;
	}
	if ([emailValue.text length] == 0) {
		
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Missing Field"
								   message: @"Please fill in the e-mail field."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
        [errorAlert release];
        
		return;
	}
	if (!modifying && [passwordValue.text length] == 0 || [password2Value.text length] == 0 || ![passwordValue.text isEqualToString:password2Value.text]) {

		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Password mismatch"
								   message: @"Password values must match."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
        [errorAlert release];

		return;
	}
	if([birthValue.text length] == 0) {
        
        UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Missing Field"
								   message: @"Please fill in year of birth field."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
        [errorAlert release];
        
		return;
    }
    if([genderValue.text length] == 0) {
        
        UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Missing Field"
								   message: @"Please fill in the gender field."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
        [errorAlert release];
        
		return;
    }
	
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	
	[dict setObject:firstName.text forKey:@"username"];
    if(!modifying) {
        [dict setObject:passwordValue.text forKey:@"password1"];
        [dict setObject:passwordValue.text forKey:@"password2"];
    }
	//[dict setObject:firstName.text forKey:@"first_name"];
	//[dict setObject:lastName.text forKey:@"last_name"];
	[dict setObject:emailValue.text forKey:@"email"];
	
	int genderIsNumber = 0;
	if([genderValue.text isEqualToString:@"Male"]) {
		genderIsNumber = 2;
	} else {
		genderIsNumber = 1;
	}
	
	[dict setObject:[NSNumber numberWithInt:genderIsNumber] forKey:@"gender"];
	[dict setObject:[NSString stringWithFormat:@"%@-01-01",birthValue.text] forKey:@"dob"];
	[dict setObject:location.text forKey:@"zipcode"];
		
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:dict andType:kFilterAPITypeAccountCreate andCallback:self];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)aTextField {
	[accountScrollView setContentOffset:CGPointMake(0, MAX(0,aTextField.frame.origin.y-100)) animated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)aPickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)aPickerView numberOfRowsInComponent:(NSInteger)component {

	if (pickerType == PickerType_Gender)
		return 2;
	
	return 100;	// birth year
}

#pragma mark -
#pragma mark UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	if (pickerType == PickerType_Gender) {
		genderValue.text = [genderArray objectAtIndex:row];
	}
	else {
		birthValue.text = [yearArray objectAtIndex:row];
	}
}

- (NSString *)pickerView:(UIPickerView *)aPickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

	if (pickerType == PickerType_Gender)
		return [genderArray objectAtIndex:row];
	
    return [yearArray objectAtIndex:row];
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	//[self.delegate accountCreatedWithObject:data];
    if(self.stackController.controllerType == AccountStackController) {
        switch (filterop.type) {
            case kFilterAPITypeAccountCreate: {
            
                NSString *username = emailValue.text; 
                [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERNAME_KEY];
                NSError *err = nil;
                
                [SFHFKeychainUtils storeUsername:username andPassword:passwordValue.text forServiceName:KEYCHAIN_SERVICENAME updateExisting:YES error:&err];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
              
                if (imageChanged == NO) {
                    [self.stackController pushFilterViewWithDictionary:[NSDictionary dictionaryWithObject:@"genresDirectory" forKey:@"viewToPush"]];
              
                } else {
                    NSData *data = UIImageJPEGRepresentation([avatarImage imageForState:UIControlStateNormal], 1.0);
                    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:data,@"profile_picture",nil];
                    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:dataDict andType:kFilterAPITypeAccountProfilePicture andCallback:self];
                }
                
                break;
            }
                
            case kFilterAPITypeAccountProfilePicture: {
                
                [self.stackController pushFilterViewWithDictionary:[NSDictionary dictionaryWithObject:@"genresDirectory" forKey:@"viewToPush"]];
                break;
            }
                
            default:
                break;
        }
    }
    else {
        switch (filterop.type) {
            case kFilterAPITypeGetAccount: {
                FilterUserAccount *user = data;
                
                emailValue.text = user.userEmail;
                firstName.text = user.userName;
                location.text = user.userZip;
                genderValue.text = user.userGender;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy"];
                birthValue.text = [formatter stringFromDate:user.dateOfBirth];
                [formatter release];
                
                [pictureIndicator startAnimating];
                if (user.profilePicURL != nil)
                    [avatarImage setImage:[[FilterGlobalImageDownloader globalImageDownloader] imageForURL:user.profilePicURL object:self selector:@selector(profilePicDownloaded:)] forState:UIControlStateNormal];
                
                [indicator stopAnimatingAndRemove];
            }
                break;
            case kFilterAPITypeAccountModify: {
                [self.stackController popNavigationStack];
                
                break;
            }
                
            case kFilterAPITypeAccountDeleteProfilePicture:
                [UIView animateWithDuration:.3 animations:^{ avatarImage.alpha = 1.0; }];
                [pictureIndicator stopAnimating];
                
                break;
            case kFilterAPITypeAccountProfilePicture: {
                [UIView animateWithDuration:.3 animations:^{ avatarImage.alpha = 1.0; }];
                [pictureIndicator stopAnimating];
                break;
            }
                
            default:
                break;
        }
    }
}

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFailWithError:(NSError*)err {
	
    NSString *title;
    NSString *message;
    
    if ([[err domain] isEqualToString:@"USR"]) {
        title = [[err userInfo] objectForKey:@"name"];
        message = [[err userInfo] objectForKey:@"description"];
    }
    else {
        title = @"Sorry";
        message = @"The Server could not be reached";
    }
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle: title
							   message: message
							   delegate:self
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
    
    if(modifying) {
        [indicator stopAnimatingAndRemove];
        [avatarImage setImage:prevImage forState:UIControlStateNormal];
        [UIView animateWithDuration:.3 animations:^{ avatarImage.alpha = 1.0; }];
        [pictureIndicator stopAnimating];
    }
}

-(void)profilePicDownloaded:(id)sender {
    [pictureIndicator stopAnimating];
    [avatarImage setImage:[(NSNotification*)sender image] forState:UIControlStateNormal];
}

@end
