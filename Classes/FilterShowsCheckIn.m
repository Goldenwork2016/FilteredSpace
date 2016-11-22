//
//  FilterShowsCheckIn.m
//  TheFilter
//
//  Created by John Thomas on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterShowsCheckIn.h"
#import "FilterToolbar.h"
#import "FilterLocationManager.h"
#import "FilterDataObjects.h"
#import "FilterGlobalImageDownloader.h"
#import "TheFilterAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

//#import "SHKTwitter.h"
// #import "SHKFacebook.h"
#import "SHKTumblr.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation FilterShowsCheckIn

@synthesize checkInObj = checkInObj_;
@synthesize postParams;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
				
		filterObjImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 48, 48)];
		filterObjImage.layer.cornerRadius = 5;
		filterObjImage.clipsToBounds = YES;
		[self addSubview:filterObjImage];

		venueLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 6, 165, 14)];
		venueLabel.font = FILTERFONT(13);
		venueLabel.textColor = DARK_TEXT_COLOR;
		venueLabel.adjustsFontSizeToFitWidth = YES;
		venueLabel.minimumFontSize = 10;
		venueLabel.textAlignment = UITextAlignmentLeft;
		venueLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:venueLabel];

		bandLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 22, 165, 18)];
		bandLabel.font = FILTERFONT(16);
		bandLabel.textColor = LIGHT_TEXT_COLOR;
		bandLabel.adjustsFontSizeToFitWidth = YES;
		bandLabel.minimumFontSize = 10;
		bandLabel.textAlignment = UITextAlignmentLeft;
		bandLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:bandLabel];
				
 		attendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 6, 70, 12)];
		attendingLabel.font = FILTERFONT(10);
		attendingLabel.textColor = DARK_TEXT_COLOR;
		attendingLabel.adjustsFontSizeToFitWidth = YES;
		attendingLabel.minimumFontSize = 10;
		attendingLabel.textAlignment = UITextAlignmentRight;
		attendingLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:attendingLabel];
		
		checkInComments = [[FilterCheckInCommentView alloc] initWithFrame:CGRectMake(10, 59, 300, 94)];
		[self addSubview:checkInComments];
		
		
		// TODO: decide whether to make this a secondary toolbar or keep this inline
		shareBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 145, 320, 53)];
		shareBackground.image = [UIImage imageNamed:@"share_background_bar.png"];
		
 		shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 169, 42, 15)];
		shareLabel.font = FILTERFONT(13);
		shareLabel.textColor = LIGHT_TEXT_COLOR;
		shareLabel.adjustsFontSizeToFitWidth = YES;
		shareLabel.minimumFontSize = 10;
		shareLabel.textAlignment = UITextAlignmentLeft;
		shareLabel.text = @"Share:";
		shareLabel.backgroundColor = [UIColor clearColor];
		
		twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(56, 162, 51, 31)];
		[twitterButton setBackgroundImage:[UIImage imageNamed:@"unselected_twitter.png"] forState:UIControlStateNormal]; // unselected and unhighlighted
		[twitterButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_twitter.png"] forState:UIControlStateHighlighted]; // unselected and highlighted
		[twitterButton setBackgroundImage:[UIImage imageNamed:@"selected_twitter.png"] forState:(UIControlStateSelected | UIControlStateNormal)]; // selected and unhighlighted
		[twitterButton addTarget:self action:@selector(twitterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(111, 162, 51, 31)];
		[facebookButton setBackgroundImage:[UIImage imageNamed:@"unselected_facebook.png"] forState:UIControlStateNormal]; // unselected and unhighlighted
		[facebookButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_facebook.png"] forState:UIControlStateHighlighted]; // unselected and highlighted
		[facebookButton setBackgroundImage:[UIImage imageNamed:@"selected_facebook.png"] forState:(UIControlStateSelected | UIControlStateNormal)]; // selected and unhighlighted
		[facebookButton addTarget:self action:@selector(facebookButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		tumblrButton = [[UIButton alloc] initWithFrame:CGRectMake(166, 162, 51, 31)];
		[tumblrButton setBackgroundImage:[UIImage imageNamed:@"unselected_tumblr.png"] forState:UIControlStateNormal]; // unselected and unhighlighted
		[tumblrButton setBackgroundImage:[UIImage imageNamed:@"pressed_down_tumblr.png"] forState:UIControlStateHighlighted]; // unselected and highlighted
		[tumblrButton setBackgroundImage:[UIImage imageNamed:@"selected_tumblr.png"] forState:(UIControlStateSelected | UIControlStateNormal)]; // selected and unhighlighted
		[tumblrButton addTarget:self action:@selector(tumblrButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:shareBackground];
		[self addSubview:shareLabel];
		[self addSubview:twitterButton];
		[self addSubview:facebookButton];
		[self addSubview:tumblrButton];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//	[[NSNotificationCenter defaultCenter] removeObserver:self 
//													name:@"sharerAuthorized" 
//												  object:nil];
    [super dealloc];
}

- (void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:NO];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeCancel];
	[[FilterToolbar sharedInstance] setRightButtonWithType:kToolbarButtonTypeDone];
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];	

	[[FilterToolbar sharedInstance] showPrimaryLabel:@"Check In"];
	[[FilterToolbar sharedInstance] showSecondaryLabel:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
	if (newSuperview != nil) {
		[checkInComments.commentView becomeFirstResponder];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(sharerAuthorized:)
													 name:@"sharerAuthorized"
												   object:nil];
  
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(sessionStateChanged:)
         name:FBSessionStateChangedNotification
         object:nil];
        
        // Check the session for a cached token to show the proper authenticated
        // UI. However, since this is not user intitiated, do not show the login UX.
        TheFilterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:NO];
        
/*		
		SHKFacebook *facebook = [[[SHKFacebook alloc] init] autorelease];
		if ([facebook isAuthorized]) {
 */
        //  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook"]];
        
			if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook" ]]!= nil) {
				facebookButton.selected = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"Facebook"]];
			} else {
				facebookButton.selected = YES;		// default is YES if the entry isnt there
			}

//		}
		
			if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"SHKTwitter"]]!= nil) {
				twitterButton.selected = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_isLoggedIn", @"SHKTwitter"]];
			} else {
				twitterButton.selected = YES;		// default is YES if the entry isnt there
			}
			
		//}
		
		SHKTumblr *tumblr = [[[SHKTumblr alloc] init] autorelease];
		if ([tumblr isAuthorized]) {
			if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_isLoggedIn", [tumblr sharerId]]] != nil) {
				tumblrButton.selected = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_isLoggedIn", [tumblr sharerId]]];
			} else {
				tumblrButton.selected = YES;		// default is YES if the entry isnt there
			}
			
		}
	}
}


- (void)setCheckInObj:(FilterDataObject *)obj {
	
	// checkins can happen for either shows or venues
	checkInObj_ = obj;
	
	if ([checkInObj_ isKindOfClass:[FilterShow class]]) {
		FilterShow *show = (FilterShow *)checkInObj_;

		filterObjImage.image = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:show.posterURL object:self selector:@selector(posterImageDownloaded:)];
		
		venueLabel.text = [NSString stringWithFormat:@"%@ Presents", show.showVenue.venueName];
		bandLabel.text = @"Band Name";
        // JDH FIX
        if (show.showBands != nil){
          bandLabel.text = [[show.showBands objectAtIndex:0] objectForKey:@"name"];
        }
        //NSLog(@" show.showBands = %@", show.showBands);
		//bandLabel.text = [show.showBands objectAtIndex:0].bandName;

        checkInComments.commentView.text = [NSString stringWithFormat:@"Checking out \'%@\' @%@ #filteredspace", show.name, show.showVenue.venueName];
        
        
	} else if ([checkInObj_ isKindOfClass:[FilterVenue class]]) {
		bandLabel.text = @"Found a band on FilteredSpace";
		checkInComments.commentView.text = @"Checking out a great show!";
	}
    
    self.postParams =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     @"https://filteredspace.com", @"link",
     @"http://afineweb.com/wp-content/uploads/icon@2x.png", @"picture",
     @"FilteredSpace", @"name",
     bandLabel.text, @"caption",
     checkInComments.commentView.text, @"description",
     nil];
}

-(void)posterImageDownloaded:(id)sender {
	filterObjImage.image = [(NSNotification*)sender image];
}

-(void)facebookButtonTapped:(id)sender {
    UIButton *button = sender;
    
    NSLog(@"### FB SDK VERSION : %@",
          [[FBRequestConnection class] performSelector:@selector(userAgent)]);
	
    if (!button.selected) {
    
        TheFilterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
        if (FBSession.activeSession.isOpen) {
            FBRequest *me = [FBRequest requestForMe];
            [me startWithCompletionHandler: ^(FBRequestConnection *connection, 
                                              NSDictionary<FBGraphUser> *my,
                                              NSError *error) {
            //self.helloLabel.text = my.first_name;
            }];
        } else {
        // The user has initiated a login, so call the openSession method
        // and show the login UX if necessary.
            [appDelegate openSessionWithAllowLoginUI:NO];
            //[appDelegate openSessionWithAllowLoginUI:YES];
        }   
        button.selected = YES;
    }
    else {
        button.selected = NO;
    }
    
    
/*	if (!button.selected) {
		SHKFacebook *facebook = [[[SHKFacebook alloc] init] autorelease];
		if ([facebook isAuthorized]) {
			
			[button setSelected:YES];
		} else {
			
			// for some reason the FB webview behaves differently than the others and we need to
			// clear out the keyboard ourselves
			[checkInComments.commentView resignFirstResponder];
			[facebook authorize];
            [facebook setShouldAutoShare:YES];
		}
	} else {
		button.selected = NO;
	}
 
 */
    
}

-(void)twitterButtonTapped:(id)sender {
	UIButton *button = sender;
	
	if (!button.selected) {
      if (NSClassFromString(@"TWTweetComposeViewController")) {
		
			[button setSelected:YES];
		} else {
			
            objAlertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your device cannot send the tweet now. Check the internet connection or make sure your device has at least one twitter account setup." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [objAlertView show];
            [objAlertView release];
            button.selected = NO;
		}
	} else {
		button.selected = NO;
	}
}

-(void)tumblrButtonTapped:(id)sender {
	UIButton *button = sender;
	
	if (!button.selected) {
		SHKTumblr *tumblr = [[[SHKTumblr alloc] init] autorelease];
		if ([tumblr isAuthorized]) {
			
			[button setSelected:YES];
		} else {
			
			[tumblr authorize];
            [tumblr setShouldAutoShare:YES];
		}
	} else {
		button.selected = NO;
	}
}

-(void)donePushed:(id)sender {
	//NSLog(@"submitCheckin");
    
    if ([checkInComments.commentView.text length] == 0) {
        
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"CheckIn Error"
                                   message: @"The comments field is required."
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert release];
        
        return;
    }
	
	NSString *latitude, *longitude, *objId, *checkInName;
	
	if ([checkInObj_ isKindOfClass:[FilterShow class]]) {
	
		FilterShow *show = (FilterShow *)checkInObj_;
		latitude = [NSString stringWithFormat:@"%.5f", show.showVenue.venueLocation.coordinate.latitude];
		longitude = [NSString stringWithFormat:@"%.5f", show.showVenue.venueLocation.coordinate.longitude];
		objId = [NSString stringWithFormat:@"%d", show.showID];
		checkInName = [NSString stringWithFormat:@"Show%d-Venue%d", show.showID, show.showVenue.venueID];
		

	} else if ([checkInObj_ isKindOfClass:[FilterVenue class]]) {
		
		
	}
	
	if (latitude != nil && longitude != nil) {
		
		NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
		//[dict setObject:checkInName forKey:@"name"];
		[dict setObject:checkInComments.commentView.text forKey:@"comment"];
		[dict setObject:latitude forKey:@"latitude"];
		[dict setObject:longitude forKey:@"longitude"];
		//[dict setObject:@"show" forKey:@"type"];
		[dict setObject:objId forKey:@"object_id"];
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:dict andType:kFilterAPITypeCreateCheckin andCallback:self];
	}
    
    if (facebookButton.selected == YES){
        
        TheFilterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        [postParams setObject:checkInComments.commentView.text forKey:@"description"];
        
        [FBRequestConnection
         startWithGraphPath:@"me/feed"
         parameters:self.postParams
         HTTPMethod:@"POST"
         completionHandler:^(FBRequestConnection *connection,
                             id result,
                             NSError *error) {
             NSString *alertText;
             if (error) {
                 alertText = [NSString stringWithFormat:
                              @"error: domain = %@, code = %d",
                              error.domain, error.code];
                 NSLog(@"FB error = %@",alertText);
                 if (!FBSession.activeSession.isOpen) {
                     // The user wants to post, but something is wrong,
                     // so call the openSession method,
                     // and show the login UX if necessary.
                     [appDelegate openSessionWithAllowLoginUI:YES];
                 }
                 
             } else {
             //alertText = [NSString stringWithFormat:
             //             @"Posted to Facebook"];
                 
              [[SHKActivityIndicator currentIndicator] displayCompleted:SHKLocalizedString(@"Posted to Facebook!")];
             }

         }];   
    
    }

    
    if (twitterButton.selected == YES){
        
        [postParams setObject:checkInComments.commentView.text forKey:@"description"];
        //first identify whether the device has twitter framework or not
        if (NSClassFromString(@"TWTweetComposeViewController")) {
            
            NSLog(@"Twitter framework is available on the device");
            //code goes here
            //first identify whether the device has twitter framework or not
            if (NSClassFromString(@"TWTweetComposeViewController")) {
                
                NSLog(@"Twitter framework is available on the device");
                //code goes here
                
                NSString *url = @"https://api.twitter.com/1.1/statuses/update.json";
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
                [params setObject:checkInComments.commentView.text  forKey:@"status"];
                
                ACAccountStore *accountStore = [[ACAccountStore alloc] init];
                ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                
                [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
                    if(granted)
                    {
                        NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                        if ([accountsArray count] > 0)
                        {
                            ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                            
                            SLRequest *postRequest = [SLRequest  requestForServiceType:SLServiceTypeTwitter requestMethod:TWRequestMethodPOST URL:[NSURL URLWithString:url] parameters:params ];
                            
                            [postRequest setAccount:twitterAccount];
                            
                            [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                             {
                                 NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                                  NSLog(@"Tweet output = %@",output);
                                 dispatch_async( dispatch_get_main_queue(), ^{
                                     if (error)
                                     {
                                          NSLog(@"tweet error  = %@",output);
                                     }
                                     else
                                     {
                                      [[SHKActivityIndicator currentIndicator] displayCompleted:SHKLocalizedString(@"Posted to Twitter!")];
                                     }
                                     
                                 });
                             }];
                        };
                    }
                }];  
            };
            
            
            
        }else{
            NSLog(@"Twitter framework is not available on the device");
            
            objAlertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your device cannot send the tweet now. Check the internet connection or make sure your device has at least one twitter account setup." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [objAlertView show];
            [objAlertView release];
            
        }
        
        
    }
}

#pragma mark -
#pragma mark Notifcation Handlers

- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        facebookButton.selected = YES;
        FBRequest *me = [FBRequest requestForMe];
        [me startWithCompletionHandler: ^(FBRequestConnection *connection, 
                                          NSDictionary<FBGraphUser> *my,
                                          NSError *error) {
            facebookButton.selected = YES;
            
        }];
    } else {
        facebookButton.selected = NO;
    }
    
}

- (void)sharerAuthorized:(NSNotification *)note {
	
	NSString *sharerId = [note object];
/*	if ([sharerId isEqualToString:@"SHKFacebook"]) {
		facebookButton.selected = YES;
		[checkInComments.commentView becomeFirstResponder];
	} else
 */       
    if ([sharerId isEqualToString:@"SHKTwitter"]) {
		twitterButton.selected = YES;
	} else if ([sharerId isEqualToString:@"SHKTumblr"]) {
		tumblrButton.selected = YES;
	}
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {

    NSString *someText = checkInComments.commentView.text;
    SHKItem *item = [SHKItem text:someText];
	
    // Share the item on Tumblr
	if ([tumblrButton isSelected]) {
		
		[SHKTumblr shareItem:item];
	}
	
/*	// Share the item with Twitter
 	if ([twitterButton isSelected]) {
 		[item setCustomValue:someText forKey:@"status"];
	 	[SHKTwitter shareItem:item];
 	}
	
	// Share the item with Facebook
	if ([facebookButton isSelected]) {
		
		[SHKFacebook shareItem:item];
	}
*/
    
	[self.stackController popNavigationStack];
}

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFailWithError:(NSError*)err {
	
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

@end
