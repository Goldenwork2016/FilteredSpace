//
//  ServerSwitchController.m
//  TheFilter
//
//  Created by Patrick Hernandez on 4/5/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import "ServerSwitchController.h"
#import <QuartzCore/QuartzCore.h>
#import "FilterAPIOperationQueue.h"

@implementation ServerSwitchController

static ServerSwitchController *singleton = nil;

- (id)init {
    self = [super init];
    if (self) {
       // serverField = [[UITextField alloc] initWithFrame:CGRectMake(65, 10, 235, 24)];
        serverField = [[UITextField alloc] initWithFrame:CGRectMake(50, 72, 245, 24)];
        serverField.placeholder = @"http://prefix.server.com";
        serverField.font = [UIFont systemFontOfSize:15.0];
        serverField.autocorrectionType = UITextAutocorrectionTypeNo;
        serverField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        serverField.backgroundColor = [UIColor lightGrayColor];
        serverField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"mediaurl"];
        serverField.clearButtonMode = UITextFieldViewModeWhileEditing;
        serverField.delegate = self;
        
        [serverField.layer setCornerRadius:2];
        [self.view addSubview:serverField];
        
        consoleView = [[UITextView alloc] initWithFrame:CGRectMake(10, 170, 300, 300)];
        consoleView.font = [UIFont systemFontOfSize:15.0];
        consoleView.backgroundColor = [UIColor grayColor];
        consoleView.layer.cornerRadius = 2;
        
        UILabel *serverLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 55, 20)];
        serverLabel.text = @"Server: ";
        serverLabel.font = [UIFont systemFontOfSize:15.0];
        [self.view addSubview:serverLabel];
        
        [serverLabel release];
        
        //Try putting nav before definition of server buttons...
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        UIBarButtonItem *done   = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        
        [self.navigationItem setLeftBarButtonItem:cancel];
        [self.navigationItem setRightBarButtonItem:done];
        
        [cancel release];
        [done release];
        
        
        
        devButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        // devButton.frame = CGRectMake(10, 50, 300, 30);
        devButton.frame = CGRectMake(10, 110, 300, 30);
        [devButton setTitle:@"Dev" forState:UIControlStateNormal];
        [devButton addTarget:self action:@selector(setTextViewText:) forControlEvents:UIControlEventTouchUpInside];
        devButton.tag = kDevServer;
        [self.view addSubview:devButton];

        alphaButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //alphaButton.frame = CGRectMake(10, 90, 300, 30);
        alphaButton.frame = CGRectMake(10, 150, 300, 30);
        [alphaButton setTitle:@"Alpha" forState:UIControlStateNormal];
        [alphaButton addTarget:self action:@selector(setTextViewText:) forControlEvents:UIControlEventTouchUpInside];
        alphaButton.tag = kAlphaServer;
        [self.view addSubview:alphaButton];
        
        stagingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //stagingButton.frame = CGRectMake(10, 130, 300, 30);
        stagingButton.frame = CGRectMake(10, 190, 300, 30);
        [stagingButton setTitle:@"Staging" forState:UIControlStateNormal];
        [stagingButton addTarget:self action:@selector(setTextViewText:) forControlEvents:UIControlEventTouchUpInside];
        stagingButton.tag = kStagingServer;
        [self.view addSubview:stagingButton];
       
        /*
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        UIBarButtonItem *done   = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        
        [self.navigationItem setLeftBarButtonItem:cancel];
        [self.navigationItem setRightBarButtonItem:done];
        
        [cancel release];
        [done release];
         */
        
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        [self setTitle:@"Set server"];

    }
    return self;
}

- (void) setTextViewText:(id)sender {
    switch ([sender tag]) {
        case kDevServer:
            serverField.text = @"http://dev.filteredspace.com";
            break;
        case kAlphaServer:
            serverField.text = @"http://www.filteredspace.com";
            break;
        case kStagingServer:
            serverField.text = @"http://staging.filteredspace.com";
            break;
        default:
            break;
    }
}

#pragma mark - 
#pragma mark Navigation Button Press
- (void) cancel:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

- (void) done:(id)sender {
    
    if (serverField.text == nil || [serverField.text length] == 0) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Empty Field"
                                   message: @"Server name cannot be empty"
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert release];
        
        return;
    }
    
    NSString *serverString = serverField.text;
    
    if ([serverString characterAtIndex:[serverString length] - 1] == '/') {
        serverString = [serverString substringToIndex:[serverString length] - 1];
    }
    
    // NSLog(@"new server: %@", serverString);
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@/api/v2/", serverString] forKey:@"apiurl"];
    [[NSUserDefaults standardUserDefaults] setObject:serverString forKey:@"mediaurl"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //TODO: figure out a better more isolated way
    [[FilterAPIOperationQueue sharedInstance] setAPI_URL:[NSString stringWithFormat:@"%@/api/v2/", serverString]];
    [[FilterAPIOperationQueue sharedInstance] setAPI_MEDIA_URL:serverString];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma -
#pragma Singleton Methods
+(id)sharedInstance {
	
	@synchronized(self) {
		
		if(singleton == nil) {
			singleton = [[ServerSwitchController alloc] init];
		}
		return singleton;
	}
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

#pragma mark - 
#pragma mark UITextFieldDelegate conformance
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - 
#pragma mark - View lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
@end
