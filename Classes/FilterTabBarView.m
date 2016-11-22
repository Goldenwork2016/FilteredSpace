//
//  FilterTabBarView.m
//  TheFilter
//
//  Created by Ben Hine on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterTabBarView.h"
#import "FilterTabButton.h"
#import "Common.h"

@implementation FilterTabBarView
@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		backgroundImage.image = [UIImage imageNamed:@"tab_bar.png"];
		backgroundImage.backgroundColor = [UIColor clearColor];
		[self addSubview:backgroundImage];
		
		tabButtons = [[NSMutableArray alloc] init];
		
		NSArray *imageFiles  = [NSArray arrayWithObjects:@"selected_news_tab_icon.png",
								@"selected_shows_tab_icon.png",
								@"selected_f_tab_icon.png",
								@"selected_profile_tab_icon.png",
								@"selected_extras_tab_icon.png",nil]; //this assumes the unselected filenames are the same except for adding "un" to the beginning
		
		
		for (int i = 0; i < 5; i++) {
			
			
			//TODO: the YES condition sizes are a bit janky, but I'll need new assets to fix it without antialiasing everything.
			CGRect tabFrame = (i == 2) ? CGRectMake(i* floor(frame.size.width/5) + 8, 14, 49, 49) : CGRectMake(i * frame.size.width / 5, 27, 62, 48);
			
			FilterTabButton *tabButton = [[FilterTabButton alloc] initWithFrame:tabFrame];
			
			tabButton.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:(CGFloat)i / 10 green:(CGFloat)i / 10 blue:(CGFloat)i / 10 alpha:1];
			
			tabButton.selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[imageFiles objectAtIndex:i]]];
			tabButton.unselectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"un%@",[imageFiles objectAtIndex:i]]]];
			[tabButton addTarget:self action:@selector(tabSelected:) forControlEvents:UIControlEventTouchDown];
			[tabButton addTarget:self action:@selector(tabTapped:) forControlEvents:UIControlEventTouchUpInside];
			
			tabButton.selected = NO;
			
			[tabButtons addObject:tabButton];
			[self addSubview:tabButton];
			
		}
		
    }
    return self;
}

-(void)tabSelected:(id)sender {
	
	// NSLog(@"TAB   SELECTED");
	for(FilterTabButton *aButton in tabButtons) {
		
		if(aButton == sender) {
			aButton.selected = YES;
			[delegate_ filterTabBarSelectedWithIndex:[tabButtons indexOfObject:aButton]];
		} else {
			aButton.selected = NO;
		}
		
		
	}
	
	
}


-(void)tabTapped:(id)sender {
	
	// NSLog(@"TABTAPPED");
	[delegate_ filterTabBarSelectedTabTappedWithIndex:[tabButtons indexOfObject:sender]];
	
}


-(void)setSelectedTabWithIndex:(NSInteger)idx {
    
    if (idx >= [tabButtons count]) {
        [delegate_ filterTabBarSelectedWithIndex:idx];
        return;
    }
    
	FilterTabButton *selectedButton = (FilterTabButton*)[tabButtons objectAtIndex:idx];
//	aButton.selected = YES;
//	[delegate_ filterTabBarSelectedWithIndex:idx];
	
    for(FilterTabButton *aButton in tabButtons) {
		
		if(aButton == selectedButton) {
			aButton.selected = YES;
			[delegate_ filterTabBarSelectedWithIndex:idx];
		} else {
			aButton.selected = NO;
		}
		
		
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
