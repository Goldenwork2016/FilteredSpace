//
//  ExtrasGridItem.h
//  TheFilter
//
//  Created by Ben Hine on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	kGridItemTypeBandDirectory,
	kGridItemTypeVenueDirectory,
	kGridItemTypeGenreDirectory,
	kGridItemTypeLikedSongs,
	kGridItemTypeAddFriends,
	kGridItemTypeSettings,
	kGridItemTypeNotifications,
	
	
} GridItemType;


@interface ExtrasGridItem : UIButton {

	GridItemType itemType_;
	
}

@property (nonatomic, assign) GridItemType itemType;

@end
