//
//  FilterLoginView.m
//  TheFilter
//
//  Created by Ben Hine on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterLoginView.h"
#import "FilterToolbar.h"
#import "SFHFKeychainUtils.h"
#import "FilterAPIOperationQueue.h"

@implementation FilterLoginView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
		backgroundImage.frame = CGRectMake(0, -65, 320, 480);
		[self addSubview:backgroundImage];
        
		loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 15, 250, 20)];
		loginLabel.font = FILTERFONT(15);
		loginLabel.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
		loginLabel.backgroundColor = [UIColor clearColor];
		loginLabel.shadowColor = [UIColor blackColor];
		loginLabel.shadowOffset = CGSizeMake(0, 1);
		loginLabel.text = @"Login to your FilteredSpace account";
		[self addSubview:loginLabel];

  		UIView *topBackground = [[UIView alloc] initWithFrame:CGRectMake(10, 50, 300, 88)];
		UIView *topDivider1 = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 300, 1)];
		topDivider1.backgroundColor = [UIColor blackColor];
		[topBackground addSubview:topDivider1];
		
		topBackground.backgroundColor = [UIColor colorWithRed:.27 green:.27 blue:.27 alpha:1.0];
		topBackground.layer.cornerRadius = 10;
		[topBackground.layer setBorderWidth: 1.0];
		[topBackground.layer setBorderColor: [[UIColor blackColor] CGColor]];
		[self addSubview:topBackground];
        
        [topDivider1 release];
      
		userField = [[UITextField alloc] initWithFrame:CGRectMake(20,61, 280, 22)];
		userField.font = FILTERFONT(15);
        userField.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];

		userField.delegate = self;
		userField.placeholder = @"Username";
		userField.autocorrectionType = UITextAutocorrectionTypeNo;
		userField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[self addSubview:userField];
		
		
		passField = [[UITextField alloc] initWithFrame:CGRectMake(20, 104, 280, 22)];
		passField.font = FILTERFONT(15);
        passField.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
		passField.delegate = self;
		passField.placeholder = @"Password";
		passField.autocorrectionType = UITextAutocorrectionTypeNo;
		passField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		passField.secureTextEntry = YES;
		[self addSubview:passField];
		
		[userField becomeFirstResponder];
        
		
		forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
		forgotButton.frame = CGRectMake(86, 150, 148, 31);
		[forgotButton setBackgroundImage:[UIImage imageNamed:@"featured_screen_button.png"] forState:UIControlStateNormal];
		forgotButton.titleLabel.font = FILTERFONT(13);
		[forgotButton setTitle:@"Forgot Password" forState:UIControlStateNormal];
		forgotButton.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.29];
		forgotButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
		[forgotButton addTarget:self action:@selector(forgotPasswordTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:forgotButton];
        
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void) forgotPasswordTapped:(id)button {
    
	[self.stackController pushFilterViewWithDictionary:[NSDictionary dictionaryWithObject:@"forgotPasswordView" forKey:@"viewToPush"]];
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Login"];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
	
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] setRightButtonWithType:kToolbarButtonTypeLogin];

    [[FilterToolbar sharedInstance] showPlayerButton:NO];
	
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	
	if(textField == userField) {
		[textField resignFirstResponder];
		[passField becomeFirstResponder];
	} else if (textField == passField) {
		
		if([userField.text length] > 0) {
			
			if([passField.text length] > 0) {
				//TODO: login and store credentials
				// NSLog(@"login");
				[textField resignFirstResponder];
				[self sendLoginRequest];
				return NO;
			}
			
		}
		[textField resignFirstResponder];
		[userField becomeFirstResponder];
		
	}
	
	
	
	
	
	return NO;
}


-(void)sendLoginRequest {
	
	//TODO: call login on the API
    // Instead just let them through so we can test while we dont have API spec
	
	NSString *user = userField.text;
	NSString *pass = passField.text;
	
	
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:user,@"username",pass,@"password",nil];
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:dict andType:kFilterAPITypeLogin andCallback:self];
}


#pragma -
#pragma FilterAPIOperation methods

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	//Success! 
	
	[[NSUserDefaults standardUserDefaults] setObject:userField.text forKey:USERNAME_KEY];
	NSError *err = nil;
	[SFHFKeychainUtils storeUsername:userField.text andPassword:passField.text forServiceName:KEYCHAIN_SERVICENAME updateExisting:YES error:&err];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.stackController authorizationDone];
    
    [self removeFromSuperview];
	//TODO: dismiss this view
	
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
