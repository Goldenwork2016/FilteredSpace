//
//  FilterPlayerSlideshowTableContainer.m
//  TheFilter
//
//  Created by Ben Hine on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterPlayerSlideshowTableContainer.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"
#import "FilterGlobalImageDownloader.h"

@implementation FilterPlayerSlideshowTableContainer

@synthesize tableView = tableView_;
@synthesize repeatButton;
@synthesize imageViewer = imageViewer_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		imageViewer_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height)];
		imageViewer_.image = [UIImage imageNamed:@"xlrg_no_image.png"];//testing code
		[imageViewer_ setContentMode:UIViewContentModeScaleAspectFit];
		imageViewer_.layer.zPosition = -100;
		imageViewer_.backgroundColor = [UIColor clearColor];
		//imageViewer_.layer.transform = CATransform3DMakeRotation(-3.141, 0, 1, 0);
		//[self addSubview:imageViewer_];
		
		contentView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height)];
		
		// Secondary toolbar
		UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		[toolbar setBackgroundColor:[UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0]];
		
		UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 39, 320, 1)];
		[bottomBar setBackgroundColor:[UIColor blackColor]];
		
		[toolbar addSubview:bottomBar];
		
		clearButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[clearButton setFrame:CGRectMake(-81, 5, 80, 31)];
		[clearButton setImage:[UIImage imageNamed:@"clear_queue_button.png"] forState:UIControlStateNormal];
		
		//[toolbar addSubview:clearButton];
		
		editButton = [UIButton buttonWithType:UIButtonTypeCustom];
		editButton.frame = CGRectMake(267, 5, 43, 31);
		[editButton setBackgroundImage:[UIImage imageNamed:@"edit_done_m_button.png"] forState:UIControlStateNormal];
		[editButton setTitle:@"Edit" forState:UIControlStateNormal];
		editButton.titleLabel.font = FILTERFONT(12);
		editButton.titleLabel.shadowColor = [UIColor blackColor];
		editButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        editButton.titleLabel.frame = CGRectMake(100, 10, 43, 31);
		[editButton addTarget:self action:@selector(editPushed:) forControlEvents:UIControlEventTouchUpInside];
		[toolbar addSubview:editButton];
		
		
		repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
		repeatButton.frame = CGRectMake(10, 10, 25, 21);
		[repeatButton setBackgroundImage:[UIImage imageNamed:@"off_repeat_icon.png"] forState:UIControlStateNormal];
		[repeatButton setBackgroundImage:[UIImage imageNamed:@"on_repeat_icon.png"] forState:UIControlStateSelected];
		[repeatButton addTarget:self action:@selector(repeatSelected:) forControlEvents:UIControlEventTouchUpInside];
		[toolbar addSubview:repeatButton];
		
		
		[contentView_ addSubview:toolbar];
		
		tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, frame.size.height-40)];
		
		UIView *backgroundView_ = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		backgroundView_.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		
		tableView_.backgroundView = backgroundView_;
		tableView_.separatorColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
		[contentView_ addSubview:tableView_];
		
		[self addSubview:contentView_];
    }
    return self;
}



-(void)performFlipTransition {
	
	if(contentView_.superview) {
		[UIView transitionFromView:contentView_ toView:imageViewer_ duration:0.7 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
	} else {
		[UIView transitionFromView:imageViewer_ toView:contentView_ duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
	}
	
}


-(void)editPushed:(id)sender {
	[self setEditing:!tableView_.editing];
	
}

- (void)setEditing:(BOOL)editing {
    [tableView_ setEditing:editing animated:YES];
	
	if(!tableView_.editing) {
		[editButton setTitle:@"Edit" forState:UIControlStateNormal];
		[tableView_ selectRowAtIndexPath:selectedIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
		
		
		[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			
			clearButton.frame = CGRectMake(-81, 5, 80, 31);
			
		}
						 completion:^(BOOL finished) {
							 
							 [clearButton removeFromSuperview];
							 [tableView_ reloadData]; // this is a haxx to get the play carat back after the selection animation is done
							 
						 }];
		
		
	} else {
		[editButton setTitle:@"Done" forState:UIControlStateNormal];
		selectedIndex = [[tableView_ indexPathForSelectedRow] retain];
		
		[clearButton addTarget:tableView_.dataSource action:@selector(clearPushed:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:clearButton];
		[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
			clearButton.frame = CGRectMake(10, 5, 80, 31);
			
		}
						 completion:^(BOOL finished) {
							 
                             
						 }];
		
	}
}

-(void)setHeaderEnabled:(BOOL)enable {
	
	repeatButton.enabled = enable;
	clearButton.enabled = enable;
	editButton.enabled = enable;
		
}

-(void)repeatSelected:(id)sender {
	repeatButton.selected = !repeatButton.selected;
}

-(void)imageFinished:(id)sender {
	imageViewer_.image = [(NSNotification*)sender image];
}

- (void)dealloc {
    [super dealloc];
}


@end
