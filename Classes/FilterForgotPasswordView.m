//
//  FilterForgotPasswordView.m
//  TheFilter
//
//  Created by John Thomas on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterForgotPasswordView.h"
#import "FilterToolbar.h"
#import "FilterAPIOperationQueue.h"

@implementation FilterForgotPasswordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 415)];
        [self addSubview:webView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Forgot Password"];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
	
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[[FilterToolbar sharedInstance] setRightButtonWithType:kToolbarButtonTypeNone];
    
	
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	if (newSuperview != nil) {
		
        NSMutableString *urlAddress = [NSMutableString stringWithFormat:@"%@/accounts/password/reset/" , [[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL]];
        if([[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY]) {
            [urlAddress appendFormat:@"?email=%@", [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY]];
        }
        
        NSURL *url = [NSURL URLWithString:urlAddress];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        [webView loadRequest:requestObj];    
	} 
}

@end
