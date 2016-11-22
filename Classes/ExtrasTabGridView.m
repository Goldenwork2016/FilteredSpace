//
//  ExtrasTabGridView.m
//  TheFilter
//
//  Created by Ben Hine on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExtrasTabGridView.h"
#import "ExtrasGridItem.h"
#import "Common.h"
#import "FilterToolbar.h"
#import "NotificationsView.h"

@implementation ExtrasTabGridView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		gridItems_ = [[NSMutableArray alloc] init];
		
		ExtrasGridItem *bandsItem = [[ExtrasGridItem alloc] init];
		[bandsItem setBackgroundImage:[UIImage imageNamed:@"band_icon.png"] forState:UIControlStateNormal];
		[bandsItem setBackgroundImage:[UIImage imageNamed:@"pressed_down_band_icon.png"] forState:UIControlStateHighlighted];
		bandsItem.itemType = kGridItemTypeBandDirectory;
		[self addGridItem:bandsItem];
		
		ExtrasGridItem *venueItem = [[ExtrasGridItem alloc] init];
		[venueItem setBackgroundImage:[UIImage imageNamed:@"venues_icon.png"] forState:UIControlStateNormal];
		[venueItem setBackgroundImage:[UIImage imageNamed:@"pressed_down_venues_icon.png"] forState:UIControlStateHighlighted];
		venueItem.itemType = kGridItemTypeVenueDirectory;
		[self addGridItem:venueItem];
		
		ExtrasGridItem *genresItem = [[ExtrasGridItem alloc] init];
		[genresItem setBackgroundImage:[UIImage imageNamed:@"genres_icon.png"] forState:UIControlStateNormal];
		[genresItem setBackgroundImage:[UIImage imageNamed:@"pressed_down_genres_icon.png"] forState:UIControlStateHighlighted];
		genresItem.itemType = kGridItemTypeGenreDirectory;
		[self addGridItem:genresItem];
		
//		ExtrasGridItem *likedSongs = [[ExtrasGridItem alloc] init];
//		[likedSongs setBackgroundImage:[UIImage imageNamed:@"liked_songs_icon.png"] forState:UIControlStateNormal];
//		[likedSongs setBackgroundImage:[UIImage imageNamed:@"pressed_down_liked_songs_icon.png"] forState:UIControlStateHighlighted];
//		likedSongs.itemType = kGridItemTypeLikedSongs;
//		[self addGridItem:likedSongs];		
		
		ExtrasGridItem *settings = [[ExtrasGridItem alloc] init];
		[settings setBackgroundImage:[UIImage imageNamed:@"settings_icon.png"] forState:UIControlStateNormal];
		[settings setBackgroundImage:[UIImage imageNamed:@"pressed_down_settings_icon.png"] forState:UIControlStateHighlighted];
		settings.itemType = kGridItemTypeSettings;
		[self addGridItem:settings withFrame:CGRectMake(123, 125, 74, 74)];
		
		
    }
    return self;
}

-(void)configureToolbar {
	[[FilterToolbar sharedInstance] showPlayerButton:YES];
	[[FilterToolbar sharedInstance] setLeftButtonWithType:kToolbarButtonTypeNone];
	
	[[FilterToolbar sharedInstance] showSecondaryToolbar:kSecondaryToolbar_None];
	
	[[FilterToolbar sharedInstance] showLogo];
	
}


-(void)addGridItem:(ExtrasGridItem *)item {
	
	NSInteger index = [gridItems_ count];
	
	CGRect frame = CGRectMake(18 + (105 * (index % 3)), 20 + (105 * (index / 3)), 74, 74);
	[self addGridItem:item withFrame:frame];
}

-(void)addGridItem:(ExtrasGridItem *)item withFrame:(CGRect) frame {
	item.frame = frame;
	[item addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:item];
	[gridItems_ addObject:item];
}

-(void)itemSelected:(id)sender {
	
	ExtrasGridItem *item = (ExtrasGridItem*)sender;
	
	//TODO: make this call the stack controller and load the view.
	switch (item.itemType) {
		case kGridItemTypeBandDirectory: {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"bandDirectory",@"viewToPush",nil];
			[self.stackController pushFilterViewWithDictionary:dict];
			break;
        }
		case kGridItemTypeVenueDirectory: {
			
			NSDictionary *viewData = [NSDictionary dictionaryWithObject:[NSString stringWithString:@"venueDirectory"] forKey:@"viewToPush"]; 
			[self.stackController pushFilterViewWithDictionary:viewData];
			break;
		}
		case kGridItemTypeSettings:
		{
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"settingsView",@"viewToPush",nil];
			[self.stackController pushFilterViewWithDictionary:dict];
			
			break;
		}
		case kGridItemTypeLikedSongs:
		{	
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"likedSongsView",@"viewToPush",nil];
			[self.stackController pushFilterViewWithDictionary:dict];
			
			break;
		}
		case kGridItemTypeGenreDirectory:
		{	
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"genresDirectory",@"viewToPush",nil];
			[self.stackController pushFilterViewWithDictionary:dict];
			
			break;
		}

		default:
			break;
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
