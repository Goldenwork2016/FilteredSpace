//
//  FilterToolbar.m
//  TheFilter
//
//  Created by Ben Hine on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterToolbar.h"
#import "FilterPlayerButton.h"
#import "FilterToolbarButton.h"
#import "FilterSegmentedSecondaryToolbar.h"
#import "Common.h"

#define FILTERTOOLBARFRAME CGRectMake(0, 0, 320, 59)
#define FILTERTOOLBARFRAMEWITHSUBTOOLBAR CGRectMake(0, 0, 320, 118)

#define TOOLBARSOLOLABELFRAME CGRectMake(65, 5, 190, 30)

#define TOOLBARPRIMARYLABELFRAME CGRectMake(65, 0, 190, 25)
#define TOOLBARSECONDARYLABELFRAME CGRectMake(65, 20, 190, 25)

#define PLAYERBUTTONFRAME CGRectMake(280, 8, 30, 31)
#define RIGHTBUTTONFRAME CGRectMake(281, 7, 30, 31)
#define RIGHTBUTTONFRAMELRG CGRectMake(258, 7, 52, 31)
#define LEFTBUTTONFRAME CGRectMake(10, 7, 52, 31)

@implementation FilterToolbar

static FilterToolbar *singleton = nil;


@synthesize primaryLabel = primaryLabel_;
@synthesize secondaryLabel = secondaryLabel_;
@synthesize delegate = delegate_;
@synthesize playerButton;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		
		
		backgroundView = [[UIImageView alloc] initWithFrame:FILTERTOOLBARFRAME];
		backgroundView.image = [UIImage imageNamed:@"main_navigation.png"];
		[self addSubview:backgroundView];
		[self sendSubviewToBack:backgroundView];
		
		
		logoText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fs_logo.png"]];
		logoText.frame = CGRectMake(self.center.x - logoText.image.size.width / 2, 7, logoText.image.size.width, logoText.image.size.height);
		[self addSubview:logoText];
		
		self.backgroundColor = [UIColor clearColor];
		
		primaryLabel_ = [[UILabel alloc] initWithFrame:TOOLBARSOLOLABELFRAME];
		primaryLabel_.backgroundColor = [UIColor clearColor];
		//primaryLabel_.textColor = [UIColor whiteColor];
		primaryLabel_.textAlignment = UITextAlignmentCenter;
		CGFloat primSize = 18;
		primaryLabel_.font = FILTERFONT(primSize);
		primaryLabel_.shadowOffset = CGSizeMake(0, -1);
		primaryLabel_.textColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1];
		primaryLabel_.shadowColor = [UIColor blackColor];
		
		secondaryLabel_ = [[UILabel alloc] initWithFrame:TOOLBARSECONDARYLABELFRAME];
		secondaryLabel_.backgroundColor = [UIColor clearColor];
		//secondaryLabel_.textColor = [UIColor whiteColor];
		secondaryLabel_.textAlignment = UITextAlignmentCenter;
		CGFloat secondSize = 13;
		secondaryLabel_.font = FILTERFONT(secondSize);
		secondaryLabel_.shadowOffset = CGSizeMake(0, -1);
		secondaryLabel_.textColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1];
		secondaryLabel_.shadowColor = [UIColor blackColor];
		
		//TODO: configure these buttons and such
		
		playerButton = [[FilterPlayerButton alloc] initWithFrame:PLAYERBUTTONFRAME];
		[playerButton addTarget:self action:@selector(playerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		
		rightButton_ = [[FilterToolbarButton buttonWithType:UIButtonTypeCustom] retain];
		rightButton_.frame = RIGHTBUTTONFRAME;
		[rightButton_ addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		leftButton_ = [[FilterToolbarButton buttonWithType:UIButtonTypeCustom] retain];
		leftButton_.frame = LEFTBUTTONFRAME;
		[leftButton_ addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		
		// setup secondary toolbars
		currentSecondaryToolbarType = kSecondaryToolbar_None;
		
		searchShowsToolbar = [[FilterSearchShowsToolbar alloc] initWithFrame:CGRectMake(0, 44, 320, 59)];
		searchShowsToolbar.delegate = self;
		
		upcomingShowsToolbar = [[FilterUpcomingShowsToolbar alloc] initWithFrame:CGRectMake(0, 44, 320, 59)];
		upcomingShowsToolbar.delegate = self;
		
		segmentSecondaryToolbar = [[FilterSegmentedSecondaryToolbar alloc] initWithFrame:CGRectMake(0, 44, 320, 59)];
		
		/////////////////////////
		// Debugging code to allow us to switch servers on demand
		//
		/////////////////////////
        NSString *serverplist = [[NSBundle mainBundle] pathForResource:@"FilterAPIServers" ofType:@"plist"];
        
        if([[[NSDictionary dictionaryWithContentsOfFile:serverplist] objectForKey:@"serverSwitcherOn"] boolValue]) {
            serverSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
            serverSwitchButton.frame = logoText.frame;
            [serverSwitchButton addTarget:self action:@selector(serverButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:serverSwitchButton];
		}
    }
	
    return self;
}

/////////////////////////
// Debugging code to allow us to switch servers on demand
//
/////////////////////////


-(void)serverButtonPushed:(id)sender {
    [delegate_ serverButtonPushed:sender];	
}

+(id)sharedInstance {
	
	@synchronized(self) {
		if(singleton == nil) {
			
			singleton = [[FilterToolbar alloc] initWithFrame:FILTERTOOLBARFRAMEWITHSUBTOOLBAR];
			
		}
		return singleton;
	}
	
	
}


- (UIView *)hitTest:(CGPoint)point 
		  withEvent:(UIEvent *)event
{
	UIView *hitView = [super hitTest:point withEvent:event];
	if( self == hitView ) {
		return nil;
	} else {
		
		
		return hitView;
	}
}


-(void)showPlayerButton:(BOOL)hideShow {
	
	if(!playerButton.superview && hideShow) {
		[self addSubview:playerButton];
		if(rightButton_.superview) {
			[rightButton_ removeFromSuperview];
		}
	} else if (!hideShow) {
		[playerButton removeFromSuperview];
	}
	
}


-(void)setRightButtonWithType:(ToolbarButtonType)type {
	
	// clearing button text just to be safe
	[rightButton_ setTitle:@"" forState:UIControlStateNormal];
	
	switch (type) {
		case kToolbarButtonTypePlaylistList:
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"list_button.png"] forState:UIControlStateNormal];
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"pressed_down_list_button.png"] forState:UIControlStateHighlighted];
			rightButton_.frame = RIGHTBUTTONFRAME;
			rightButton_.toolbarButtonType = type;
			
			[self addSubview:rightButton_];
			break;
		case kToolbarButtonTypeCreateAccount:
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"cancel_edit_button.png"] forState:UIControlStateNormal];
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"pressed_down_cancel_edit_button.png"] forState:UIControlStateHighlighted];
			rightButton_.frame = RIGHTBUTTONFRAMELRG;
			rightButton_.titleLabel.font = FILTERFONT(12);
			[rightButton_ setTitle:@"Create" forState:UIControlStateNormal];
			[rightButton_ setTitleColor:[UIColor colorWithRed:97 green:.96 blue:.96 alpha:1.0] forState:UIControlStateNormal];
			
			rightButton_.toolbarButtonType = type;
			[self addSubview:rightButton_];
			break;
			
		case kToolbarButtonTypeDone:
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"cancel_edit_button.png"] forState:UIControlStateNormal];
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"pressed_down_cancel_edit_button.png"] forState:UIControlStateHighlighted];
			rightButton_.frame = RIGHTBUTTONFRAMELRG;
			rightButton_.titleLabel.font = FILTERFONT(12);
			[rightButton_ setTitle:@"Done" forState:UIControlStateNormal];
			[rightButton_ setTitleColor:[UIColor colorWithRed:97 green:.96 blue:.96 alpha:1.0] forState:UIControlStateNormal];
			
			rightButton_.toolbarButtonType = type;
			[self addSubview:rightButton_];
			break;
		case kToolbarButtonTypeLogin:
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"cancel_edit_button.png"] forState:UIControlStateNormal];
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"pressed_down_cancel_edit_button.png"] forState:UIControlStateHighlighted];
			rightButton_.frame = RIGHTBUTTONFRAMELRG;
			rightButton_.titleLabel.font = FILTERFONT(12);
			[rightButton_ setTitle:@"Login" forState:UIControlStateNormal];
			[rightButton_ setTitleColor:[UIColor colorWithRed:97 green:.96 blue:.96 alpha:1.0] forState:UIControlStateNormal];
			
			rightButton_.toolbarButtonType = type;
			[self addSubview:rightButton_];
			break;
		
		case kToolbarButtonTypeNext:
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"next_button.png"] forState:UIControlStateNormal];
			[rightButton_ setBackgroundImage:[UIImage imageNamed:@"pressed_down_next_button.png"] forState:UIControlStateHighlighted];
			rightButton_.frame = RIGHTBUTTONFRAMELRG;
			
			rightButton_.toolbarButtonType = type;
			[self addSubview:rightButton_];
			break;
			
		default:
			
			[rightButton_ removeFromSuperview];
			
			break;
	}
	
	
}


-(void)setLeftButtonWithType:(ToolbarButtonType)type {
	
	// clearing button text just to be safe
	[leftButton_ setTitle:@"" forState:UIControlStateNormal];
	
	switch (type) {
		case kToolbarButtonTypeBackButton:
			[leftButton_ setBackgroundImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
			[leftButton_ setBackgroundImage:[UIImage imageNamed:@"pressed_down_back_button.png"] forState:UIControlStateHighlighted];
			leftButton_.toolbarButtonType = type;
			[self addSubview:leftButton_];
			break;
			
		case kToolbarButtonTypeCancel:
			[leftButton_ setBackgroundImage:[UIImage imageNamed:@"cancel_edit_button.png"] forState:UIControlStateNormal];
			[leftButton_ setBackgroundImage:[UIImage imageNamed:@"pressed_down_cancel_edit_button.png"] forState:UIControlStateHighlighted];
			leftButton_.titleLabel.font = FILTERFONT(12);
			[leftButton_ setTitle:@"Cancel" forState:UIControlStateNormal];
			[leftButton_ setTitleColor:[UIColor colorWithRed:97 green:.96 blue:.96 alpha:1.0] forState:UIControlStateNormal];
			
			leftButton_.toolbarButtonType = type;
			[self addSubview:leftButton_];
			break;
			
		default:
			
			[leftButton_ removeFromSuperview];
			
			break;
	}	
}

- (void) showSecondaryToolbar:(SecondaryToolbarType)toolbarType {

	if (currentSecondaryToolbarType == toolbarType)
		return;
	
	// remove previous toolbar
	[secondaryToolbar_ removeFromSuperview];
	
	switch (toolbarType) {
		case kSecondaryToolbar_SearchShows:
			secondaryToolbar_ = (UIView*)searchShowsToolbar;
			currentSecondaryToolbarType = toolbarType;
			break;
			
		case kSecondaryToolbar_UpcomingShows:
			secondaryToolbar_ = (UIView*)upcomingShowsToolbar;
			currentSecondaryToolbarType = toolbarType;
			break;
			
		case kSecondaryToolbar_NewsFeed:
			secondaryToolbar_ = (UIView*)segmentSecondaryToolbar;
			currentSecondaryToolbarType = toolbarType;
			break;
		default:
			secondaryToolbar_ = nil;
			currentSecondaryToolbarType = kSecondaryToolbar_None;
			break;
	}
	
	[self addSubview:secondaryToolbar_];
}

- (void) showSecondaryToolbar:(SecondaryToolbarType)toolbarType withLabel:(NSString *)string {
    if (toolbarType == kSecondaryToolbar_UpcomingShows) {
        [[upcomingShowsToolbar primaryLabel] setText:string];
    }
    
    [self showSecondaryToolbar:toolbarType];
}

-(void) showUpcomingShowsMapButton:(BOOL)showMapButton {
	if (showMapButton == YES)
		[upcomingShowsToolbar setMapButton];
	else 
		[upcomingShowsToolbar setShowListButton];
}

-(void)playerButtonPressed:(id)sender {
	
	[delegate_ FilterToolbarDelegatePlayerButtonPressed];
	
}

-(void)rightButtonPressed:(id)sender {
	
	[delegate_ FilterToolbarDelegateRightButtonPressedWithButton:sender];
	
}


-(void)leftButtonPressed:(id)sender {
	[delegate_ FilterToolbarDelegateLeftButtonPressedWithButton:sender];
	
}

-(void)showPrimaryLabel:(NSString*)string {
	
	[logoText removeFromSuperview];
	primaryLabel_.text = string;
	
	if(secondaryLabel_.superview == nil) {
		primaryLabel_.frame = TOOLBARSOLOLABELFRAME;
		primaryLabel_.textColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1];
		primaryLabel_.font = FILTERFONT(18);
	}
	
	
	if(primaryLabel_.superview == nil) {
		[self addSubview:primaryLabel_];
	}
	
}

-(void)showSecondaryLabel:(NSString*)string {
	[logoText removeFromSuperview];
	
	secondaryLabel_.text = string;
	
	if(string) {
		primaryLabel_.frame = TOOLBARPRIMARYLABELFRAME;
		primaryLabel_.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
		primaryLabel_.font = FILTERFONT(13);
	} else {
		primaryLabel_.frame = TOOLBARSOLOLABELFRAME;
		primaryLabel_.textColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1];
		primaryLabel_.font = FILTERFONT(18);
	}
		
	if(secondaryLabel_.superview == nil) {
		[self addSubview:secondaryLabel_];
	}
}

-(void)showLogo {
	
	if(logoText.superview == nil) {
		[self addSubview:logoText];
	}
	[primaryLabel_ removeFromSuperview];
	[secondaryLabel_ removeFromSuperview];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark FilterSecondaryToolbar delegate methods

- (void)FilterUpcomingShowsButtonPressedWithButton:(id)sender {
	[self.delegate ForwardUpcomingShowsButtonPressedWithButton:sender];
}

- (void)FilterSearchShowsButtonPressedWithButton:(id)sender {
	[self.delegate ForwardSearchShowsButtonPressedWithButton:sender];
}

- (void)FilterSearchShowsReturned:(NSString*)searchString {
    [self.delegate ForwardShowsSearchReturn:searchString];
}

@end
