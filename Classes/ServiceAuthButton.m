//
//  ServiceAuthButton.m
//  TheFilter
//
//  Created by John Thomas on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServiceAuthButton.h"
#import "Common.h"

@implementation ServiceAuthButton

@synthesize serviceId = serviceId_;
@synthesize authMode = authMode_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

		self.titleLabel.font = FILTERFONT(17);
		[self setBackgroundImage:[UIImage imageNamed:@"under_meter_button.png"] forState:UIControlStateNormal];
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setAuthMode:(ServiceAuthenticationMode)auth {
	authMode_ = auth;
	
	switch (authMode_) {
		case ServiceAuthorize:
			[self setTitle:@"Login" forState:UIControlStateNormal];
			break;
		
		case ServiceDeauthorize:
			[self setTitle:@"Logout" forState:UIControlStateNormal];
			break;

		default:
			break;
	}
}

@end
