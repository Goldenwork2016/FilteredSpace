    //
//  MainViewController.m
//  TheFilter
//
//  Created by Ben Hine on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "TheFilterMultimediaManager.h"
#import "StreamingAudioDriver.h"
#import "FilterTabBarView.h"
#import "FilterPlayerController.h"
#import "FilterToolbar.h"
#import "FilterStackController.h"
#import "FilterToolbarButton.h"
#import "FilterView.h"
#import "FilterCache.h"
#import "Common.h"


#import "FilterSignInView.h"
#import "FilterLoginView.h"
#import "FilterShowsAllShowsView.h"
//Testing code - remove later
#import "ServerSwitchController.h"

@implementation MainViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
  //  NSLog(@"Mainview init: ");
    if (self) {
		stacksArray = [[NSMutableArray alloc] init];

        FilterStackController *stackOne = [[FilterStackController alloc] initWithType:NewsStackController delegate:self];
		
		FilterStackController *stackTwo = [[FilterStackController alloc] initWithType:ShowsStackController delegate:self];
		
		FilterStackController *stackThree = [[FilterStackController alloc] initWithType:FeaturedStackController delegate:self];
		
		FilterStackController *stackFour = [[FilterStackController alloc] initWithType:ProfileStackController delegate:self];
		
		FilterStackController *stackFive = [[FilterStackController alloc] initWithType:ExtrasStackController delegate:self];
		
		[stacksArray addObject:stackOne];
		[stacksArray addObject:stackTwo];
		[stacksArray addObject:stackThree];
		[stacksArray addObject:stackFour];
		[stacksArray addObject:stackFive];
        
        currentFilterTab = 2;
        
        if (![[FilterCache sharedInstance] myAccountDataExists]) {
            [self showAccountSignIn];
        }
        else {
            [tabBar_ setSelectedTabWithIndex:currentFilterTab];
        }
        
        [stackOne release];
        [stackTwo release];
        [stackThree release];
        [stackFour release];
        [stackFive release];
       // NSLog(@"Mainview init: just built stacks");
    }
    
    return self;
}

- (void)loadView {
    
    int sheight = [ [ UIScreen mainScreen ] bounds ].size.height;
    int swidth = [ [ UIScreen mainScreen ] bounds ].size.width;
    NSLog(@"w = %d h = %d", swidth, sheight);
    
    //self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
     self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, swidth, sheight - 20)];
    
    backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    backgroundImage.frame = CGRectMake(0, -20, 320, 480);
    //backgroundImage.frame = CGRectMake(0, -20, 320, 520);
    [self.view addSubview:backgroundImage];
    
    tabBar_ = [[FilterTabBarView alloc] initWithFrame:CGRectMake(0, 382, 320, 78)];
    //tabBar_ = [[FilterTabBarView alloc] initWithFrame:CGRectMake(0, 440, 320, 78)];
    tabBar_.delegate = self;
    [self.view addSubview:tabBar_];
    
    toolbar_ = [FilterToolbar sharedInstance];
    toolbar_.delegate = self;
    [self.view addSubview:toolbar_];
    [self.view bringSubviewToFront:toolbar_];
       
    //JDH
    NSLog(@"mainview size: w %f, h %f", self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view sendSubviewToBack:backgroundImage];
  //  NSLog(@"Mainview : loadView");
    
}


-(void)viewDidLoad {
    [tabBar_ setSelectedTabWithIndex:currentFilterTab];

}


- (void) showAccountSignIn {
    accountStack = [[FilterStackController alloc] initWithType:AccountStackController delegate:self];
    
    [self.view addSubview:accountStack.currentView];
    
    //Hack Alert - this is kind of nasty and i don't like it
    [stacksArray addObject:accountStack];
    currentFilterTab = 5;
    
    [[FilterAPIOperationQueue sharedInstance] removeAllOperations];    
}

- (void) createAndShowFeatured {
    currentFilterTab = 2;
    
    [tabBar_ setSelectedTabWithIndex:2];
}

- (void) showFeatured {
    
    [self filterTabBarSelectedWithIndex:currentFilterTab];
    
    [tabBar_ setSelectedTabWithIndex:2];
    
    currentFilterTab = 2;
}

-(void)animateAwayFromPlayer {
	
	FilterPlayerController *player = [FilterPlayerController sharedInstance];
	
	FilterView *currentView = (FilterView*)[[stacksArray objectAtIndex:currentFilterTab] currentView];
	[currentView configureToolbar];
    
	[self popFromView:player toView:currentView animated:YES];
}

#pragma mark -
#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark TabBarDelegate

-(void)filterTabBarSelectedWithIndex:(NSInteger)idx {
	
  // NSLog(@"Mainview : filterTabBarSelectedWithIndex");
	// remove current tab view
	[[[stacksArray objectAtIndex:currentFilterTab] currentView] removeFromSuperview];
	
	currentFilterTab = idx;
	FilterView *filterView = (FilterView*)[[stacksArray objectAtIndex:currentFilterTab] currentView];
	[filterView configureToolbar];
	
	//TODO: we need to think about this more
	[filterView refreshData];
	////////////////////////////////////////
	//NSLog(@"MainView just refreshed data.");
	if(!tabBar_.superview) {
		//NSLog(@"TABBAR: %@", [tabBar_ description]);
		tabBar_.frame = CGRectMake(0, tabBar_.frame.origin.y, tabBar_.frame.size.width, tabBar_.frame.size.height);
		[self.view addSubview:tabBar_];
	}
    
    [self.view addSubview:filterView];
	
    if(filterView.showsTabBar) {
        [self.view bringSubviewToFront:tabBar_];
    }
    else {
        tabBar_.frame = CGRectMake(-tabBar_.frame.size.width, tabBar_.frame.origin.y, tabBar_.frame.size.width, tabBar_.frame.size.height);
    }
   // NSLog(@"MainView about to bringSubviewToFront:toolbar_");
    [self.view bringSubviewToFront:toolbar_];
}
	
-(void)filterTabBarSelectedTabTappedWithIndex:(NSInteger)idx {
	
	
}

#pragma mark -
#pragma mark ToolbarDelegate

-(void)FilterToolbarDelegatePlayerButtonPressed {
	
	FilterPlayerController *player = [FilterPlayerController sharedInstance];
	player.stackController = [stacksArray objectAtIndex:currentFilterTab]; //HACK ALERT - the only time we use the stack controller is as a passthrough to display the ratings action sheet
	player.frame = CGRectMake(320, 20, 320, 460);
	[player setEditing:NO];
	FilterView *currentView = [[stacksArray objectAtIndex:currentFilterTab] currentView];
	
    [self pushNewView:player fromOldView:currentView];
    
}


-(void)FilterToolbarDelegateLeftButtonPressedWithButton:(id)button {
	
	FilterToolbarButton *aButton = (FilterToolbarButton*)button;
	
   // NSLog(@"MainView FilterToolbarDelegateLeftButtonPressedwithButton: %d", aButton.toolbarButtonType); 
	switch (aButton.toolbarButtonType) {
		case kToolbarButtonTypeBackButton:
			if ([[FilterPlayerController sharedInstance] frame].origin.x < 320) { // ULTRA HACK
				[self animateAwayFromPlayer];
			}
			else {
				[[stacksArray objectAtIndex:currentFilterTab] popNavigationStack];
			}
			break;
						
		case kToolbarButtonTypeCancel:
			[[stacksArray objectAtIndex:currentFilterTab] popNavigationStack];
			break;
						
		default:
			break;
	}
	
	
}

-(void)FilterToolbarDelegateRightButtonPressedWithButton:(id)button {
	
	
	FilterToolbarButton *aButton = (FilterToolbarButton*)button;
    //NSLog(@"MainView FilterToolbarDelegateRightButtonPressedwithButton: %d", aButton.toolbarButtonType); 	
	switch (aButton.toolbarButtonType) {
		case kToolbarButtonTypePlaylistList:
			[[FilterPlayerController sharedInstance] performFlipTransition];
			
			break;
		case kToolbarButtonTypeDone:
				
				[[[stacksArray objectAtIndex:currentFilterTab] currentView] donePushed:button];
			
			break;
			
		case kToolbarButtonTypeCreateAccount:
			[(FilterCreateAccountView*)[accountStack currentView] sendCreateRequest];
			break;
		case kToolbarButtonTypeLogin:
			[(FilterLoginView*)[accountStack currentView] sendLoginRequest];
			
			
		default:
			break;
	}
	
}

#pragma mark -
#pragma mark FilterUpcomingShowsToolbarDelegate

-(void)ForwardUpcomingShowsButtonPressedWithButton:(id)button {
	
	FilterToolbarButton *aButton = (FilterToolbarButton*)button;
	
	switch (aButton.toolbarButtonType) {

		case kToolbarButtonTypeUpcomingShowsPosterButton: {

//            FilterStackController *stackController = [stacksArray objectAtIndex:ShowsStackController];
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"showAllShows",@"viewToPush",nil];
//            [stackController replaceFilterViewWithDictionary:dict];
            
			FilterStackController *stackController = [stacksArray objectAtIndex:ShowsStackController];
			[stackController popNavigationStack];
		}
		break;
		
		case kToolbarButtonTypeUpcomingShowsLeftSegmentButton:
			break;
		
		case kToolbarButtonTypeUpcomingShowsRightSegmentButton:
			break;

		case kToolbarButtonTypeUpcomingShowsAllShowsButton: {
			
			FilterStackController *stackController = [stacksArray objectAtIndex:ShowsStackController];
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"showAllShows",@"viewToPush",nil];
			
			[stackController pushFilterViewWithDictionary:dict];
		}
		break;
			
		default:
			break;
	}
}

#pragma mark -
#pragma mark FilterSearchShowsToolbarDelegate

-(void)ForwardSearchShowsButtonPressedWithButton:(id)button {
	
	FilterToolbarButton *aButton = (FilterToolbarButton*)button;
	
	switch (aButton.toolbarButtonType) {
		case kToolbarButtonTypeSearchShowsFilterButton:
			[[stacksArray objectAtIndex:currentFilterTab] filterUpcomingShows];
			break;			
        case kToolbarButtonTypeUpcomingShowsMapButton: {
			
            FilterShowsAllShowsView* allShows = (FilterShowsAllShowsView*)[[stacksArray objectAtIndex:currentFilterTab] currentView];
            [allShows mapButtonTapped:button];
		}
            break;
		default:
			break;
	}
}

-(void)ForwardShowsSearchReturn:(NSString *)searchString {
    [[[stacksArray objectAtIndex:currentFilterTab] currentView] searchReturned:searchString];
}
#pragma mark -
#pragma mark FilterStackControllerDelegate methods

-(void)popFromView:(FilterView*)currentView toView:(FilterView*)prevView animated:(BOOL)animated {
	
    //JDH
//	NSLog(@"MainView popFromview"); 
 //   NSLog(@"prev frame height= %f", prevView.frame.size.height);
	prevView.frame = CGRectMake(-320, prevView.frame.origin.y, prevView.frame.size.width, prevView.frame.size.height);
 //   NSLog(@"MainView frame.size.height: %f",self.view.frame.size.height );
 //   NSLog(@"MainView origin: x%f  y%f",self.view.frame.origin.x, self.view.frame.origin.y  );
 //   NSLog(@"MainView.tag %d", self.view.tag);
    if( self.view.frame.origin.y == 0){
     [self.view setFrame:CGRectMake(0, 20, 320, 480)];
    }
    
	[self.view addSubview:prevView];
    
	[self.view bringSubviewToFront:tabBar_];
	[self.view bringSubviewToFront:toolbar_];
	
	[UIView transitionWithView:self.view 
                      duration:animated ? 0.3 : 0.0 
                       options:currentView.popTransitionStyle 
                    animations:^{
                        
                        prevView.frame = CGRectMake(0, prevView.frame.origin.y, prevView.frame.size.width, prevView.frame.size.height);
                        currentView.frame = CGRectMake(320, currentView.frame.origin.y, currentView.frame.size.width, currentView.frame.size.height);
                        // Fix for now. For all that is holy please dont leave this like this. 
                        if (prevView.showsTabBar && currentFilterTab != 5) {
                            [self.view addSubview:tabBar_];
                            tabBar_.frame = CGRectMake(0, tabBar_.frame.origin.y, tabBar_.frame.size.width, tabBar_.frame.size.height);
                        }
                    }
					completion:^(BOOL finished) {
						
						[currentView removeFromSuperview];
						
						
					}];
	
    [prevView refreshData];
	[prevView configureToolbar];
}

-(void)pushNewView:(FilterView*)newView fromOldView:(FilterView*)oldView {
	
	[newView configureToolbar];
	//NSLog(@"MainView pushNewView");
 	newView.frame = CGRectMake(320, newView.frame.origin.y, newView.frame.size.width, newView.frame.size.height);
    
	[self.view addSubview:newView];
	//[self.view bringSubviewToFront:tabBar_];
	//[self.view bringSubviewToFront:toolbar_];
    
    if (newView.showsTabBar && tabBar_.frame.origin.x < 0)
    {
        [self.view addSubview:tabBar_];
    }
	
	[UIView transitionWithView:self.view duration:0.3 
					   options:newView.pushTransitionStyle 
					animations:^{ 
                        oldView.frame = CGRectMake(-320, oldView.frame.origin.y, 320, oldView.frame.size.height); 
                        newView.frame = CGRectMake(0, newView.frame.origin.y, newView.frame.size.width, newView.frame.size.height);
                        if(!(newView.showsTabBar)) {
                            tabBar_.frame = CGRectMake(-320, tabBar_.frame.origin.y, tabBar_.frame.size.width, tabBar_.frame.size.height);
                        }
                    } 
					completion:^(BOOL finished) {
						[oldView removeFromSuperview];
                        if(!(newView.showsTabBar)) {
                            [tabBar_ removeFromSuperview];
                        }
						
						
					}];
	[self.view bringSubviewToFront:toolbar_];
	
}

//-(void)showRockSuckActionSheetForView:(FilterView*)viewObj {
//	
//	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Rate"
//															  delegate:viewObj 
//													 cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil 
//													 otherButtonTitles:@"Rocks",@"Sucks", nil] autorelease];
//	
//	[actionSheet showInView:self.view];
//	
//	
//}


-(void)accountStackDone {
    
//    for(UIView *view in accountStack) {
//        [view removeFromSuperview];
//    }
//    
    [stacksArray removeObject:accountStack];
    
	[self createAndShowFeatured];
}




#pragma mark -
#pragma mark FilterCreateAccountViewDelegate methods

-(void)accountCreatedWithObject:(id)data {
	
	[[FilterCache sharedInstance] storeMyAccount:data];
	[tabBar_ setSelectedTabWithIndex:2];
	
	
	[self dismissModalViewControllerAnimated:YES];
}

-(void)presentImagePicker:(UIImagePickerController*)picker {
	[self presentModalViewController:picker animated:YES];
}

#pragma mark -
#pragma mark DEBUG

-(void)serverButtonPushed:(id)sender {
   // NSLog(@"Switch Server");

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[ServerSwitchController sharedInstance]];
    
    [self presentModalViewController:navController animated:YES];
}


@end
