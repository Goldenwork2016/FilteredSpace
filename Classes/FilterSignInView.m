//
//  FilterSignInView.m
//  TheFilter
//
//  Created by John Thomas on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterSignInView.h"
#import "Common.h"
#import "FilterToolbar.h"

@implementation FilterSignInView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_background.png"]];
		backgroundImage.frame = CGRectMake(0, -20, 320, 480);
		[self addSubview:backgroundImage];
		
		welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 257, 233, 20)];
		welcomeLabel.font = FILTERFONT(18);
		welcomeLabel.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
		welcomeLabel.backgroundColor = [UIColor clearColor];
		welcomeLabel.shadowColor = [UIColor blackColor];
		welcomeLabel.shadowOffset = CGSizeMake(0, 1);
		welcomeLabel.text = @"Welcome to FilteredSpace!";
		[self addSubview:welcomeLabel];
        
		joinButton = [[UIButton alloc] initWithFrame:CGRectMake(44, 284, 233, 45)];
		[joinButton setBackgroundImage:[UIImage imageNamed:@"intro_button.png"] forState:UIControlStateNormal];
		joinButton.titleLabel.font = FILTERFONT(17);
		[joinButton setTitle:@"Join Now" forState:UIControlStateNormal];
		joinButton.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.29];
		joinButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
		[joinButton addTarget:self action:@selector(createAccount:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:joinButton];

		loginButton = [[UIButton alloc] initWithFrame:CGRectMake(44, 345, 233, 45)];
		[loginButton setBackgroundImage:[UIImage imageNamed:@"intro_button.png"] forState:UIControlStateNormal];
		loginButton.titleLabel.font = FILTERFONT(17);
		[loginButton setTitle:@"Login" forState:UIControlStateNormal];
		loginButton.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.29];
		loginButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
		[loginButton addTarget:self action:@selector(loginPushed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:loginButton];
        
        serverButton = [[UIControl alloc] initWithFrame:CGRectMake(10, 60, 300, 100)];
        [serverButton addTarget:self.stackController.delegate action:@selector(serverButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
        
        // [self addSubview:serverButton];
    }
    return self;
}


-(void)configureToolbar {
	[[[FilterToolbar sharedInstance] superview] sendSubviewToBack:[FilterToolbar sharedInstance]];
}

-(void)loginPushed:(id)sender {
	
	
	[self.stackController pushFilterViewWithDictionary:[NSDictionary dictionaryWithObject:@"loginView" forKey:@"viewToPush"]];
	
}

-(void)createAccount:(id)sender {
	[self.stackController pushFilterViewWithDictionary:[NSDictionary dictionaryWithObject:@"createAccountView" forKey:@"viewToPush"]];
}

- (void)dealloc {
    [super dealloc];
}


@end
