//
//  SocialServicesView.m
//  TheFilter
//
//  Created by John Thomas on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SocialServicesView.h"
#import "FilterToolbar.h"
#import "ServiceAuthButton.h"

#import "SHK.h" 
#import "SHKTumblr.h"
#import "TheFilterAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
//#import "SHKTwitter.h"
//#import "SHKFacebook.h"

#define kFacebookSection	0
#define kTwitterSection		1
#define kTumblrSection		2

@implementation SocialServicesView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		serviceIdentifiers_ = [[NSArray alloc] initWithObjects:@"Facebook", @"SHKTwitter", @"SHKTumblr", nil];

		UIView *buttonBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
		buttonBackground.backgroundColor = [UIColor clearColor];
		
		logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 300, 45)];
		[logoutButton setBackgroundImage:[UIImage imageNamed:@"new_wide_button.png"] forState:UIControlStateNormal];
		logoutButton.titleLabel.font = FILTERFONT(17);
		[logoutButton setTitle:@"Log out of all services" forState:UIControlStateNormal];
		[logoutButton addTarget:self action:@selector(logoutServices:) forControlEvents:UIControlEventTouchUpInside];
		[buttonBackground addSubview:logoutButton];

		servicesTable_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
		servicesTable_.delegate = self;
		servicesTable_.dataSource = self;
		servicesTable_.backgroundColor = [UIColor clearColor];
		servicesTable_.separatorColor = [UIColor blackColor];	
		servicesTable_.tableFooterView = buttonBackground;
		[self addSubview:servicesTable_];
	}
	
    return self;
}

- (void)dealloc {
    [super dealloc];

	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:@"sharerAuthorized" 
												  object:nil];
}

-(void)configureToolbar {
	
	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Services"];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeBackButton];
	
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	if (newSuperview != nil) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(sharerAuthorized:)
													 name:@"sharerAuthorized"
												   object:nil];
	} else {
		
		[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	}
	
}

- (void)serviceAuthTapped:(id)sender {
	
	ServiceAuthButton *button = sender;
    NSString *serviceName = (NSString *)button.serviceId;
    
    if([serviceName isEqualToString: @"Facebook" ]  ){
        //Facebook
        if (button.authMode == ServiceAuthorize) {
            
            TheFilterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            if (FBSession.activeSession.isOpen) {
                FBRequest *me = [FBRequest requestForMe];
                [me startWithCompletionHandler: ^(FBRequestConnection *connection, 
                                                  NSDictionary<FBGraphUser> *my,
                                                  NSError *error) {
                
                }];
            } else {
                // The user has initiated a login, so call the openSession method
                // and show the login UX if necessary.
                [appDelegate openSessionWithAllowLoginUI:YES];
            }   
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook"]];
            button.authMode = ServiceDeauthorize;
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook"]];
            button.authMode = ServiceAuthorize;
        }
        
        
    }
    else
        
        if([serviceName isEqualToString: @"SHKTwitter" ] ){
            
         if (button.authMode == ServiceAuthorize) {
            
            if (NSClassFromString(@"TWTweetComposeViewController")) {
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"SHKTwitter"]];
                button.authMode = ServiceDeauthorize;
            } else {
                
                objAlertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your device cannot login to Twitter. Check the internet connection or make sure your device has at least one twitter account setup." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [objAlertView show];
                [objAlertView release];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"SHKTwitter"]];
                button.authMode = ServiceAuthorize;
            }
         }
         else {
             [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"SHKTwitter"]];
             button.authMode = ServiceAuthorize;
         }
    }
	else{
        SHKSharer *service = [[[NSClassFromString(button.serviceId) alloc] init] autorelease];
        if ([service isAuthorized]) {		
            [[service class] logout];
        } else {
            [service promptAuthorization];
            [service setShouldAutoShare:YES];
        }
    }

	[servicesTable_ reloadData];
}

- (void)serviceSwitchTapped:(id)sender {

	UISwitch *button = sender;
	
	BOOL enabled = [button isOn];
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:[NSString stringWithFormat:@"%@_isEnabled", [serviceIdentifiers_ objectAtIndex:button.tag]]];
}

- (void)logoutServices:(id)sender {
	
	[[[[UIAlertView alloc] initWithTitle:@"Logout"
								 message:@"Are you sure you want to logout of all share services?"
								delegate:self
					   cancelButtonTitle:@"Cancel"
					   otherButtonTitles:@"Logout",nil] autorelease] show];
}

#pragma mark -
#pragma mark Notifcation Handlers

- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook"]];
        FBRequest *me = [FBRequest requestForMe];
        [me startWithCompletionHandler: ^(FBRequestConnection *connection, 
                                          NSDictionary<FBGraphUser> *my,
                                          NSError *error) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook"]];
            
        }];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook"]];
    }
    
}

- (void)sharerAuthorized:(NSNotification *)note {
	
	[servicesTable_ reloadData];
}

#pragma mark -
#pragma mark UITableView Delegate/Datasource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;
    BOOL cellIsFacebook = NO, cellIsTwitter = NO;
	SHKSharer *service = [[[NSClassFromString([serviceIdentifiers_ objectAtIndex:indexPath.section]) alloc] init] autorelease];
    
    if ([serviceIdentifiers_ objectAtIndex:indexPath.section] == @"Facebook"){
        cellIsFacebook = YES;
    }
    if ([serviceIdentifiers_ objectAtIndex:indexPath.section] == @"SHKTwitter"){
        cellIsTwitter = YES;
    }
    
	//SHKTwitter *service = [[SHKTwitter alloc] init];
    
	switch (indexPath.row) {
		case 0:{
			
			cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"socialAuthCell"];	
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"socialAuthCell"] autorelease];
				cell.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
				
				cell.textLabel.font = FILTERFONT(16);
				cell.textLabel.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}	

			cell.textLabel.text = @"Authorization";
			
			ServiceAuthButton *auth = [[ServiceAuthButton alloc] initWithFrame:CGRectMake(210, 6, 90, 31)];
			auth.serviceId = [service sharerId];
            if(cellIsFacebook) {
                auth.serviceId = @"Facebook";

                if([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_isLoggedIn", auth.serviceId]] == YES){
                    auth.authMode = ServiceDeauthorize; 
                }
                else{
                   auth.authMode = ServiceAuthorize;     
                }
                // 
                
            }
            else
              if(cellIsTwitter) {
                auth.serviceId = @"SHKTwitter";
                
                if([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_isLoggedIn", auth.serviceId]] == YES){
                    auth.authMode = ServiceDeauthorize;
                }
                else{
                    auth.authMode = ServiceAuthorize;
                }
                //
                
            }
            else {
                auth.authMode = [service isAuthorized] ? ServiceDeauthorize : ServiceAuthorize;
            }
            
			[auth addTarget:self action:@selector(serviceAuthTapped:) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:auth];
		}
		break;
			
		case 1: {
			
			cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"socialEnableCell"];	
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"socialEnableCell"] autorelease];
				cell.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
				
				cell.textLabel.font = FILTERFONT(16);
				cell.textLabel.textColor = [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}	

			cell.textLabel.text = @"Enable Service";
			
			BOOL enabled = TRUE;
			NSString *key = [serviceIdentifiers_ objectAtIndex:indexPath.section];
			if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_isEnabled", key]] != nil)
				enabled = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_isEnabled", key]];
			
			UISwitch *enableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(206, 6, 94, 31)];
			[enableSwitch setOn:enabled];
			enableSwitch.tag = indexPath.section;
			[enableSwitch addTarget:self action:@selector(serviceSwitchTapped:) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:enableSwitch];
		}
		break;
			
		default:
			break;
	}
		
	return cell;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSString *serveID;
    serveID  = [serviceIdentifiers_ objectAtIndex:section];
    
    if ([serviceIdentifiers_ objectAtIndex:section] == @"Facebook"){
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook"]] == YES){
            return 2;        }
    }
	if ([NSClassFromString([serviceIdentifiers_ objectAtIndex:section]) isServiceAuthorized]) {
		return 2;
	}	

	return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
	
	UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 180, 25)] autorelease];
	headerLabel.font = FILTERFONT(18);
	headerLabel.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
	headerLabel.textAlignment = UITextAlignmentLeft;
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.shadowColor = [UIColor blackColor];
	headerLabel.shadowOffset = CGSizeMake(0, 1);
	[backgroundView addSubview:headerLabel];
	
	switch (section) {
		case kFacebookSection:
			headerLabel.text = @"Facebook";
			break;
			
		case kTwitterSection:
			headerLabel.text = @"Twitter";
			break;

		case kTumblrSection:
			headerLabel.text = @"Tumblr";
			break;

		default:
			break;
	}
	
	return backgroundView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 35;
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		
		[SHK logoutOfAll];
        //JDH Facebook logout
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook"]];
        
		[servicesTable_ reloadData];
	}
}

@end
