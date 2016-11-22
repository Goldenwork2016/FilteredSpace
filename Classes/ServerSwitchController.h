//
//  ServerSwitchController.h
//  TheFilter
//
//  Created by Patrick Hernandez on 4/5/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	kDevServer,
	kAlphaServer,
	kStagingServer,
		
} FilterServerType;

@interface ServerSwitchController : UIViewController <UITextFieldDelegate>{
    
    UITextField *serverField;
    UITextView *consoleView;
    
    UIButton *devButton;
    UIButton *alphaButton;
    UIButton *stagingButton;
}

+ (ServerSwitchController*) sharedInstance;

@end
