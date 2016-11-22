//
//  FilterAllShowsTableCell.m
//  TheFilter
//
//  Created by John Thomas on 2/21/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "FilterAllShowsTableCell.h"
#import "FilterAPIOperationQueue.h"
#import "FilterGlobalImageDownloader.h"
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation FilterAllShowsTableCell

@synthesize show = show_;
//@synthesize dayOfWeekLabel = dayOfWeekLabel_;
//@synthesize dayOfMonthLabel = dayOfMonthLabel_;
@synthesize showLabel = showLabel_;
@synthesize venueLabel = venueLabel_;
@synthesize bandsLabel = bandsLabel_;
@synthesize posterView = posterView_;
//@synthesize attendingLabel = attendingLabel_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		self.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
        
//		dateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 69)];
//		dateView.image = [UIImage imageNamed:@"date_box.png"];
//		[self.contentView addSubview:dateView];

//		addBookmarkButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 9, 25, 52)];
//		[addBookmarkButton setBackgroundImage:[UIImage imageNamed:@"add_bookmark_icon.png"] forState:UIControlStateNormal];
//		[addBookmarkButton addTarget:self action:@selector(addBookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//		
//		bookmarkButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 9, 29, 55)];
//		[bookmarkButton setBackgroundImage:[UIImage imageNamed:@"bookmark.png"] forState:UIControlStateNormal];
//		[bookmarkButton addTarget:self action:@selector(bookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
//		chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(302, 27, 9, 14)];
//		chevronView.image = [UIImage imageNamed:@"chevron.png"];
//		[self.contentView addSubview:chevronView];

//		dayOfWeekLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 15)];
//		dayOfWeekLabel_.font = FILTERFONT(10);
//		dayOfWeekLabel_.textColor = MEDIUM_TEXT_COLOR;
//		dayOfWeekLabel_.adjustsFontSizeToFitWidth = YES;
//		dayOfWeekLabel_.minimumFontSize = 10;
//		dayOfWeekLabel_.textAlignment = UITextAlignmentCenter;
//		dayOfWeekLabel_.backgroundColor = [UIColor clearColor];
//		[self.contentView addSubview:dayOfWeekLabel_];

//		dayOfMonthLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 70, 54)];
//		dayOfMonthLabel_.font = FILTERFONT(32);
//		dayOfMonthLabel_.textColor = LIGHT_TEXT_COLOR;
//		dayOfMonthLabel_.adjustsFontSizeToFitWidth = YES;
//		dayOfMonthLabel_.minimumFontSize = 10;
//		dayOfMonthLabel_.textAlignment = UITextAlignmentCenter;
//		dayOfMonthLabel_.backgroundColor = [UIColor clearColor];
//		dayOfMonthLabel_.shadowColor = [UIColor blackColor];
//		dayOfMonthLabel_.shadowOffset = CGSizeMake(0, 2);
//		[self.contentView addSubview:dayOfMonthLabel_];
		
		showLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(68, 10, 185, 16)];
		showLabel_.font = FILTERFONT(14);
		showLabel_.textColor = LIGHT_TEXT_COLOR;
		//showLabel_.adjustsFontSizeToFitWidth = YES;
		//showLabel_.minimumFontSize = 10;
		showLabel_.textAlignment = UITextAlignmentLeft;
		showLabel_.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:showLabel_];

		venueLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(68, 27, 185, 14)];
		venueLabel_.font = FILTERFONT(12);
		venueLabel_.textColor = DARK_TEXT_COLOR;
		//venueLabel_.adjustsFontSizeToFitWidth = YES;
		//venueLabel_.minimumFontSize = 10;
		venueLabel_.textAlignment = UITextAlignmentLeft;
		venueLabel_.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:venueLabel_];
        
 		bandsLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(68, 42, 222, 27)];
		bandsLabel_.font = FILTERFONT(10);
		bandsLabel_.textColor = DARK_TEXT_COLOR;
		bandsLabel_.adjustsFontSizeToFitWidth = YES;
		bandsLabel_.minimumFontSize = 10;
		bandsLabel_.textAlignment = UITextAlignmentLeft;
		bandsLabel_.backgroundColor = [UIColor clearColor];
        bandsLabel_.lineBreakMode = UILineBreakModeWordWrap;
        bandsLabel_.numberOfLines = 2;
		[self.contentView addSubview:bandsLabel_];
        
//        CGSize maximumSize = CGSizeMake(300, 9999);
//        NSString *dateString = @"The date today is January 1st, 1999";
//        CGSize dateStringSize = [dateString sizeWithFont:FILTERFONT(14) 
//                                       constrainedToSize:maximumSize 
//                                           lineBreakMode:bandsLabel_.lineBreakMode];
//        
//        CGRect frame = CGRectMake(10, 10, 300, dateStringSize.height);
//        
//        bandsLabel_.frame = frame;
        
// 		attendingLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(80, 50, 185, 12)];
//		attendingLabel_.font = FILTERFONT(10);
//		attendingLabel_.textColor = DARK_TEXT_COLOR;
//		attendingLabel_.adjustsFontSizeToFitWidth = YES;
//		attendingLabel_.minimumFontSize = 10;
//		attendingLabel_.textAlignment = UITextAlignmentLeft;
//		attendingLabel_.backgroundColor = [UIColor clearColor];
//		[self.contentView addSubview:attendingLabel_];
	}
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [bandsLabel_ release];
    [venueLabel_ release];
    [showLabel_ release];
    [posterView_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark instance methods

- (void)setBookmark {
    
    if (bookmark != nil) {
        [self addSubview:bookmark];
    }
    else {
        bookmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_bookmark.png"]];
        bookmark.frame = CGRectMake(281, 0, 34, 40);
        
        [self addSubview:bookmark];
    }
}
- (void)removeBookmark {
    
    if (bookmark != nil) {
        [bookmark removeFromSuperview];
        [bookmark release];
        bookmark = nil;
    }
}
//- (void)setAddBookmarkButton {
//	if(!addBookmarkButton.superview) {
//		[self.contentView addSubview:addBookmarkButton];
//		
//		[bookmarkButton removeFromSuperview];
//	}	
//}
//
//- (void)setBookmarkButton {
//	if(!bookmarkButton.superview) {
//		[self.contentView addSubview:bookmarkButton];
//		
//		[addBookmarkButton removeFromSuperview];
//	}		
//}

-(void)posterImageDownloaded:(id)sender {
    UIImageView *posterImage;
    
    posterImage = [[UIImageView alloc] initWithImage:[(NSNotification*)sender image]];
    
    [posterView_ setPosterImage:posterImage];
    
    [posterImage release];
}

#pragma mark -
#pragma mark private methods

- (void)addBookmarkButtonPressed:(id)sender {
    //NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:show_.showID] forKey:@"showID"];
    //[[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeShowBookmark andCallback:self];
}

- (void)bookmarkButtonPressed:(id)sender {
	
}

#pragma mark -
#pragma mark APIOperations Delegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {

	switch (filterop.type) {
			
		case kFilterAPITypeShowBookmark:
		{
			
			NSLog(@"FOLLOWSHOW");
			//[self setBookmarkButton];
			break;
		}
			
		default:
			break;
	}
}

-(void)filterAPIOperation:(FilterAPIOperation*)filterop didFailWithError:(NSError*)err {
	
    NSString *title;
    NSString *message;
    
    if ([[err domain] isEqualToString:@"USR"]) {
        title   = [[err userInfo] objectForKey:@"name"];
        message = [[err userInfo] objectForKey:@"description"];
    }
    else {
        title   = @"Sorry";
        message = @"The Server could not be reached";
    }
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle: title
                                                         message: message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}

@end
