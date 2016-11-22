//
//  PasswordChangeView.m
//  TheFilter
//
//  Created by Patrick Hernandez on 4/6/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import "PasswordChangeView.h"
#import "FilterToolbar.h"
#import "SFHFKeychainUtils.h"
#import "FilterAPIOperationQueue.h"

@implementation PasswordChangeView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
		backgroundImage.frame = CGRectMake(0, -65, 320, 480);
		[self addSubview:backgroundImage];
        
		UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, 260, 20)];
		passwordLabel.font = FILTERFONT(15);
		passwordLabel.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
		passwordLabel.backgroundColor = [UIColor clearColor];
		passwordLabel.shadowColor = [UIColor blackColor];
		passwordLabel.shadowOffset = CGSizeMake(0, 1);
		passwordLabel.text = @"Change your FilteredSpace password";
		[self addSubview:passwordLabel];
        
  		UIView *topBackground = [[UIView alloc] initWithFrame:CGRectMake(10, 50, 300, 132)];
		UIView *topDivider1 = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 300, 1)];
		topDivider1.backgroundColor = [UIColor blackColor];
		[topBackground addSubview:topDivider1];
		UIView *topDivider2 = [[UIView alloc] initWithFrame:CGRectMake(0, 87, 300, 1)];
		topDivider2.backgroundColor = [UIColor blackColor];
		[topBackground addSubview:topDivider2];
		
		topBackground.backgroundColor = [UIColor colorWithRed:.27 green:.27 blue:.27 alpha:1.0];
		topBackground.layer.cornerRadius = 10;
		[topBackground.layer setBorderWidth: 1.0];
		[topBackground.layer setBorderColor: [[UIColor blackColor] CGColor]];
		[self addSubview:topBackground];
        
        [topDivider1 release];
        [topDivider2 release];
        
		oldPassField = [[UITextField alloc] initWithFrame:CGRectMake(20,61, 280, 22)];
		oldPassField.font = FILTERFONT(15);
        oldPassField.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
		oldPassField.delegate = self;
		oldPassField.placeholder = @"Old Password";
		oldPassField.autocorrectionType = UITextAutocorrectionTypeNo;
		oldPassField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		oldPassField.secureTextEntry = YES;
		[self addSubview:oldPassField];
		
		
		pass1Field = [[UITextField alloc] initWithFrame:CGRectMake(20, 104, 280, 22)];
		pass1Field.font = FILTERFONT(15);
        pass1Field.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
		pass1Field.delegate = self;
		pass1Field.placeholder = @"New Password";
		pass1Field.autocorrectionType = UITextAutocorrectionTypeNo;
		pass1Field.autocapitalizationType = UITextAutocapitalizationTypeNone;
		pass1Field.secureTextEntry = YES;
		[self addSubview:pass1Field];
		
        pass2Field = [[UITextField alloc] initWithFrame:CGRectMake(20, 149, 280, 22)];
		pass2Field.font = FILTERFONT(15);
        pass2Field.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
		pass2Field.delegate = self;
		pass2Field.placeholder = @"Confirm New Password";
		pass2Field.autocorrectionType = UITextAutocorrectionTypeNo;
		pass2Field.autocapitalizationType = UITextAutocapitalizationTypeNone;
		pass2Field.secureTextEntry = YES;
		[self addSubview:pass2Field];
        
		[oldPassField becomeFirstResponder];
        
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Change Password"];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
	
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
    [[FilterToolbar sharedInstance] showPlayerButton:NO];
	[[FilterToolbar sharedInstance] setRightButtonWithType:kToolbarButtonTypeDone];
    
	
}

-(void)donePushed:(id)sender {
	//NSLog(@"changePassword");

	if ([pass1Field.text length] == 0 || [pass2Field.text length] == 0 || ![pass1Field.text isEqualToString:pass2Field.text]) {
        
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: @"Error"
								   message: @"Password values you must match."
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
        [errorAlert release];
        
		return;
	}
    
    [self changePasswordRequest];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	
	if(textField == oldPassField) {
		[textField resignFirstResponder];
		[pass1Field becomeFirstResponder];
	
    } else if(textField == pass1Field) {
        [textField resignFirstResponder];
        [pass2Field becomeFirstResponder];
        
    } else if (textField == pass2Field) {
        
		[textField resignFirstResponder];
		[oldPassField becomeFirstResponder];
		
	}
	
	return NO;
}


-(void)changePasswordRequest {
		
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:oldPassField.text,@"old_password",
                            pass1Field.text,@"new_password1",
                            pass2Field.text,@"new_password2", nil];

    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeAccountChangePassword andCallback:self];
}


#pragma -
#pragma FilterAPIOperation methods

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	//Success! 
	
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY];
	NSError *err = nil;
	[SFHFKeychainUtils storeUsername:username andPassword:pass1Field.text forServiceName:KEYCHAIN_SERVICENAME updateExisting:YES error:&err];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    [self.stackController popNavigationStack];
}

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFailWithError:(NSError*)err; {
	//TODO: present errorz
    
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
}



- (void)dealloc {
    [super dealloc];
}


@end
