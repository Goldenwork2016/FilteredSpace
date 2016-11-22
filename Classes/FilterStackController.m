//
//  FilterStackController.m
//  TheFilter
//
//  Created by Ben Hine on 2/11/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "FilterStackController.h"
#import "FilterMainScrollView.h"
#import "FilterMainFeaturedView.h"
#import "FilterShowsMapView.h"
#import "FilterShowsPosterView.h"
#import	"FilterShowsAllShowsView.h"
#import "FilterShowsExpandedPosterView.h"
#import "FilterShowsCheckIn.h"
#import "FilterShowsDetailsView.h"
#import "FilterNewsView.h"
#import "ProfileTabView.h"
#import "ExtrasTabGridView.h"
#import "MoreFeaturedView.h"
#import "FeaturedSongView.h"
#import "NotificationsView.h"
#import "FilterBandProfileView.h"
#import "FilterVideoPlayView.h"
#import "ReviewView.h"
#import "BandsDirectoryView.h"
#import "VenueDirectoryView.h"
#import "SettingsView.h"
#import "GenresView.h"
#import "AddFriendsView.h"
#import "SocialServicesView.h"
#import "FilterSignInView.h"
#import "FilterLoginView.h"
#import "FilterCreateAccountView.h"
#import "FilterForgotPasswordView.h"
#import "PasswordChangeView.h"
#import "VenueProfileView.h"
#import "VenueMapView.h"
#import "FilterCache.h"
#import "FilterToolbar.h"
#import "MainViewController.h"
#import "VenueShowsView.h"

@implementation FilterStackController

@synthesize navStack        = navStack_;
@synthesize delegate        = delegate_;
@synthesize currentView     = currentView_;
@synthesize controllerType  = controllerType_;

-(id)initWithType:(FilterStackControllerType)type delegate:(id)delegate {
	
	self = [super init];
	if (self) {

		delegate_ = delegate;
		controllerType_ = type;
		navStack_ = [[NSMutableArray alloc] init];
		
		if (type == ShowsStackController) {
			//FilterShowsPosterView *showsPosters = [[FilterShowsPosterView alloc] initWithFrame:CGRectMake(0, 90, 320, 365)];
			//showsPosters.stackController = self;
			//[navStack_ addObject:showsPosters];
            FilterShowsAllShowsView *allShows = [[FilterShowsAllShowsView alloc] initWithFrame:CGRectMake(0, 90, 320, 319)];
            allShows.stackController = self;
            allShows.showsTabBar = YES;
            [navStack_ addObject:allShows];
            // JDH
          //  NSLog(@"FilterStackController: just added allShows");
		}
		else if(type == FeaturedStackController) {
            FilterMainScrollView *featured = [[FilterMainScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, 365)];
			//FilterMainFeaturedView *featured = [[FilterMainFeaturedView alloc] initWithFrame:CGRectMake(0, 45, 320, 365)];
			featured.stackController = self;
            featured.showsTabBar = YES;
			[navStack_ addObject:featured];
            // JDH
          //  NSLog(@"FilterStackController: just added featured");
		} else if (type == NewsStackController) {
			FilterNewsView *newsView = [[FilterNewsView alloc] initWithFrame:CGRectMake(0, 45, 320, 365)];
			newsView.stackController = self;
            newsView.showsTabBar = YES;
			[navStack_ addObject:newsView];
		} else if (type == ProfileStackController) {
			ProfileTabView *profileView = [[ProfileTabView alloc] initWithFrame:CGRectMake(0, 45, 320, 365)];
			profileView.stackController = self;
            profileView.showsTabBar = YES;
			[navStack_ addObject:profileView];
            // JDH
          //  NSLog(@"FilterStackController: just added profileView");
		} else if (type == ExtrasStackController) {
			ExtrasTabGridView *extrasView = [[ExtrasTabGridView alloc] initWithFrame:CGRectMake(0, 45, 320, 365)];
			
            extrasView.showsTabBar = YES;
			extrasView.stackController = self;
			[navStack_ addObject:extrasView];
            // JDH
            // NSLog(@"FilterStackController: just added extrasView");
		} else if (type == AccountStackController) {
			
			FilterSignInView *signIn = [[FilterSignInView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
			signIn.stackController = self;
            signIn.showsTabBar = NO;
			[navStack_ addObject:signIn];
            // JDH
          //  NSLog(@"FilterStackController: just added signIn");
			
		}
		
		
	}
	return self;
	
}

-(FilterView*)currentView {
	return [navStack_ lastObject];
}

-(void)popNavigationStack {
    [self popNavigationStackWithAnimation:YES];

}

-(void)popNavigationStackWithAnimation:(BOOL)animated {
    if ([navStack_ count] > 1) {
        
        FilterView *viewToRemove;
        FilterView *viewToPresent;
        
        viewToRemove    = [self currentView];
        
        [[FilterAPIOperationQueue sharedInstance] removeOperationsForCallback:viewToRemove];
        [navStack_ removeLastObject];
        
        viewToPresent   = [navStack_ lastObject];
        
        //Fix frame after sharekit
       // NSLog (@"View to remove %@", viewToRemove);
         
        [delegate_ popFromView:viewToRemove toView:viewToPresent animated:animated];
	}
}

-(void)pushFilterViewWithDictionary:(NSDictionary*)viewDict {
	
	NSString* viewToPush = [viewDict objectForKey:@"viewToPush"];
    
    FilterView *view;
    
#warning remove before production
    if (viewToPush == nil) {
        NSAssert(NO, @"There was no \"viewToPush\" key");
    }
    
	if ([viewToPush isEqualToString:@"showExpandedPosters"]) {
		
		FilterShowsExpandedPosterView *showsExpandedPosterView = [[FilterShowsExpandedPosterView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)]; //side note with tab bar hieght is 365
		showsExpandedPosterView.stackController = self;
		
		NSInteger idx = [[viewDict objectForKey:@"selectedIndex"] intValue];
		NSArray *posters = [viewDict objectForKey:@"data"];
		[showsExpandedPosterView setPosterDataArray:posters startingAtIndex:idx];
		
		
		[delegate_ pushNewView:(FilterView*)showsExpandedPosterView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:showsExpandedPosterView];
		[showsExpandedPosterView release];

    } else if ([viewToPush isEqualToString:@"playBandVideo"]) {
		
		FilterVideoPlayView *videoPlayView = [[FilterVideoPlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)]; //side note with tab bar height is 365
		videoPlayView.stackController = self;
		
        FilterVideo *video = [viewDict objectForKey:@"video"] ;
        [videoPlayView setVideoData: video];
		
		[delegate_ pushNewView:(FilterView*)videoPlayView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:videoPlayView];
		
		[videoPlayView release];
        
	} else if ([viewToPush isEqualToString:@"showCheckIn"]) {
		
		FilterDataObject *checkInObj = [viewDict objectForKey:@"data"];
		FilterShowsCheckIn *showsCheckInView = [[FilterShowsCheckIn alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		showsCheckInView.stackController = self;
		showsCheckInView.checkInObj = checkInObj;
		
		[delegate_ pushNewView:(FilterView*)showsCheckInView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:showsCheckInView];
		
		[showsCheckInView release];		
		
	} else if ([viewToPush isEqualToString:@"showDetails"]) {
		
		FilterShowsDetailsView *showsDetailsView = [[FilterShowsDetailsView alloc] initWithFrame:CGRectMake(0, 45, 320, 415)];
		//showsDetailsView.show = [viewDict objectForKey:@"data"];
        showsDetailsView.showID = [viewDict objectForKey:@"showID"];
		showsDetailsView.stackController = self;
		[delegate_ pushNewView:(FilterView*)showsDetailsView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:showsDetailsView];
		
		[showsDetailsView release];
		
	} else if ([viewToPush isEqualToString:@"venueDirectory"]) {
		
		VenueDirectoryView *venueView = [[VenueDirectoryView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		venueView.stackController = self;
		[delegate_ pushNewView:(FilterView*)venueView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:venueView];
				
		[venueView release];
		
	} else if ([viewToPush isEqualToString:@"genresDirectory"]) {
		
		GenresView *genreView = [[GenresView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		genreView.stackController = self;
		[delegate_ pushNewView:(FilterView*)genreView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:genreView];
		
		[genreView release];
				
								 
	} else if ([viewToPush isEqualToString:@"addFriendsView"]) {
		
		AddFriendsView *friendsView = [[AddFriendsView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		friendsView.stackController = self;
		[delegate_ pushNewView:(FilterView*)friendsView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:friendsView];
		
		[friendsView release];
		
	} else if ([viewToPush isEqualToString:@"settingsView"]) {
		
		SettingsView *settings = [[SettingsView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		settings.stackController = self;
		[delegate_ pushNewView:(FilterView*)settings fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:settings];
		
		[settings release];
		
		
	} else if ([viewToPush isEqualToString:@"bandProfile"]) {
		
		FilterBandProfileView *bandProfileView = [[FilterBandProfileView alloc] initWithFrame:CGRectMake(0, 45, 320, 414) andID:[viewDict objectForKey:@"ID"]];
		//bandProfileView.bandProfile = [viewDict objectForKey:@"data"];
		bandProfileView.stackController = self;
		[delegate_ pushNewView:(FilterView*)bandProfileView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:bandProfileView];
		
		
		[bandProfileView release];
		
	} else if([viewToPush isEqualToString:@"songDetails"]) {
		
		FeaturedSongView *songDetails = [[FeaturedSongView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		songDetails.track = [viewDict objectForKey:@"data"];
		songDetails.stackController = self;
		[delegate_ pushNewView:(FilterView*)songDetails fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:songDetails];
		
		//[delegate_ pushNewView:(FilterView*)songDetails fromOldView:[navStack_ lastObject]];
		
		[songDetails release];
		
	} else if ([viewToPush isEqualToString:@"fanProfile"]) {
		
		ProfileTabView *profileView = [[ProfileTabView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		profileView.fanAccount = [viewDict objectForKey:@"data"];
		[delegate_ pushNewView:(FilterView*)profileView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:profileView];
		
		
		[profileView release];
		
	} else if ([viewToPush isEqualToString:@"socialServices"]) {
		
		SocialServicesView *services = [[SocialServicesView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		services.stackController = self;
		[delegate_ pushNewView:(FilterView*)services fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:services];
		
		[services release];
		
		
	} else if ([viewToPush isEqualToString:@"showAllShows"]) {
		
		FilterShowsAllShowsView *showsAllShowsView = [[FilterShowsAllShowsView alloc] initWithFrame:CGRectMake(0, 90, 320, 371)];
		showsAllShowsView.stackController = self;
        //showsAllShowsView.showsTabBar = YES;
        [delegate_ pushNewView:(FilterView*)showsAllShowsView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:showsAllShowsView];
		
		[showsAllShowsView release];		
		
	}
    else if([viewToPush isEqualToString:@"moreFeatured"]) {
		
		MoreFeaturedView *moreFeatured = [[MoreFeaturedView alloc] initWithFrame:CGRectMake(0, 45, 320,414)];
		moreFeatured.stackController = self;
		[delegate_ pushNewView:(FilterView*)moreFeatured fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:moreFeatured];
		
		[moreFeatured release];
        
	} else if ([viewToPush isEqualToString:@"showMapView"]) {
		
		FilterShowsMapView *showsMapView = [[FilterShowsMapView alloc] initWithFrame:CGRectMake(0, 90, 320, 371)];	
		showsMapView.stackController = self;
        showsMapView.pushTransitionStyle = UIViewAnimationTransitionFlipFromLeft;
        //showsMapView.showsTabBar = YES;

        NSArray *posters = [viewDict objectForKey:@"data"];
		showsMapView.mapPosterShows = posters;
        
        [delegate_ pushNewView:(FilterView*)showsMapView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:showsMapView];
		
		[showsMapView release];
		
	} else if ([viewToPush isEqualToString:@"notifications"]) {
		NotificationsView *notificationsView = [[NotificationsView alloc] initWithFrame:CGRectMake(0, 22, 320, 414)];
		notificationsView.stackController = self;
		[delegate_ pushNewView:(FilterView*)notificationsView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:notificationsView];
		
		[notificationsView release];
		
	} else if ([viewToPush isEqualToString:@"reviewView"]) {
		
		ReviewView *reviewView = [[ReviewView alloc] initWithFrame:CGRectMake(0, 22, 320, 414)];
		reviewView.stackController = self;
		[delegate_ pushNewView:(FilterView*)reviewView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:reviewView];
		
		[reviewView release];
		
	} else if ([viewToPush isEqualToString:@"bandDirectory"]) {
		BandsDirectoryView *bandsDirectoryView = [[BandsDirectoryView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		bandsDirectoryView.stackController = self;
		[delegate_ pushNewView:(FilterView*)bandsDirectoryView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:bandsDirectoryView];
		
		
		[bandsDirectoryView release];
	} else if ([viewToPush isEqualToString:@"loginView"]) {
		
		FilterLoginView *loginView = [[FilterLoginView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		loginView.stackController = self;
		[delegate_ pushNewView:(FilterView*)loginView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:loginView];
		
	} else if ([viewToPush isEqualToString:@"createAccountView"]) {
		FilterCreateAccountView *createAccont = [[FilterCreateAccountView alloc] initWithFrame:CGRectMake(0, 45, 320, 414) asModify:!(self.controllerType == AccountStackController)];
		createAccont.stackController = self;
		createAccont.delegate = (id)delegate_;
		[delegate_ pushNewView:(FilterView*)createAccont fromOldView:(FilterView *)[navStack_ lastObject]];
		[navStack_ addObject:createAccont];
	}  else if ([viewToPush isEqualToString:@"forgotPasswordView"]) {
		FilterForgotPasswordView *forgotPass = [[FilterForgotPasswordView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		forgotPass.stackController = self;
		[delegate_ pushNewView:(FilterView*)forgotPass fromOldView:(FilterView *)[navStack_ lastObject]];
		[navStack_ addObject:forgotPass];
	} else if ([viewToPush isEqualToString:@"changePassword"]) {
		PasswordChangeView *changePW = [[PasswordChangeView alloc] initWithFrame:CGRectMake(0, 45, 320, 414)];
		changePW.stackController = self;
		[delegate_ pushNewView:(FilterView*)changePW fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:changePW];
		[changePW release];
	} else if ([viewToPush isEqualToString:@"venueProfile"]) {
        VenueProfileView *profile = [[VenueProfileView alloc] initWithFrame:CGRectMake(0, 45, 320, 414) andID:[viewDict objectForKey:@"ID"]];
		profile.stackController = self;
		[delegate_ pushNewView:(FilterView*)profile fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:profile];
		[profile release];
    } else if ([viewToPush isEqualToString:@"venueMap"]) {
        VenueMapView *mapView = [[VenueMapView alloc] initWithFrame:CGRectMake(0, 45, 320, 414) andDictionary:viewDict];
		mapView.stackController = self;
		[delegate_ pushNewView:(FilterView*)mapView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:mapView];
		[mapView release];
    } else if ([viewToPush isEqualToString:@"venueShowsView"]) {
        VenueShowsView *showsView = [[VenueShowsView alloc] initWithFrame:CGRectMake(0, 45, 320, 414) andDictionary:viewDict];
		showsView.stackController = self;
		[delegate_ pushNewView:(FilterView*)showsView fromOldView:(FilterView*)[navStack_ lastObject]];
		[navStack_ addObject:showsView];
		[showsView release];
    }
    else {
#warning remove before production
        NSAssert(NO, @"There was no view found with that name");
    }
    
    
}

-(void)authorizationDone {
	[delegate_ accountStackDone];
}

- (void)filterUpcomingShows {
	if (controllerType_ != ShowsStackController)
		return;
	
	UIActionSheet *filterOptions = [[[UIActionSheet alloc] initWithTitle:@"Filter By" 
															   delegate:[navStack_ lastObject] 
													  cancelButtonTitle:@"Cancel" 
												 destructiveButtonTitle:nil 
													  otherButtonTitles:@"My Bands", @"My Genres", @"All Shows",nil] autorelease];

	[filterOptions showInView:[navStack_ lastObject]];
}

- (void)logout {
    [self popNavigationStackWithAnimation:NO];
    [((id)delegate_) showFeatured];
    [[FilterToolbar sharedInstance] showPlayerButton:NO];
    [[FilterCache sharedInstance] removeMyAccount];
    [((id)delegate_) showAccountSignIn];
}
@end
