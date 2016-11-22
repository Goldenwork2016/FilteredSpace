//
//  FilterPosterView.m
//  TheFilter
//
//  Created by John Thomas on 2/18/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "FilterPosterView.h"
#import "FilterGlobalImageDownloader.h"

@implementation FilterPosterView

@synthesize filterShowID = filterShowID_; 
@synthesize posterImage = posterImage_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		
		// TODO: fill out this poster data with actual data
		self.backgroundColor = [UIColor clearColor];
		
        posterImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];

        NSString *imageName = nil;
        if (frame.size.width < 100) {
            imageName = @"no_poster_avatar.png";
        } else {
            imageName = @"lrg_no_poster_avatar.png";
        }
        
        posterImage_.image = [UIImage imageNamed:imageName];
      //  NSLog(@"FilterPosterView Initwithframe poster image: %@", posterImage_.image);
        [self addSubview:posterImage_];
				
    }
    return self;
}

// this call has become a wrapper to keep from breaking old calls
- (id)initWithFrame:(CGRect)frame withShow:(FilterShow*)showObj withBookmark:(BOOL)useBookmark {

    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:[NSNumber numberWithInt:showObj.showID] forKey:@"showID"];
    [params setObject:[NSNumber numberWithBool:useBookmark] forKey:@"useBookmark"];
    if (frame.size.width == 41 && showObj.posterURL != nil) {
        [params setObject:showObj.posterURL forKey:@"posterURL"];
    }
    if (frame.size.width == 310 && showObj.posterLargeURL != nil) {
        [params setObject:showObj.posterLargeURL forKey:@"posterURL"];
    }

    return [self initWithFrame:frame withDictionary:params];
}

- (id)initWithFrame:(CGRect)frame withDictionary:(NSDictionary *)dict {

	self = [self initWithFrame:frame];
	if (self) {
        
        filterShowID_ = [[dict objectForKey:@"showID"] intValue];
				
        NSString *posterURL = [dict objectForKey:@"posterURL"];
        
        // JDH FIX 7/25/12 length check
        if (posterURL != nil && (id)posterURL != [NSNull null] 
             && [posterURL length] > 0 ){            
            posterImage_.image = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:posterURL object:self selector:@selector(posterImageDownloaded:)];
       // NSLog(@"FilterPosterView InitwithframeDict poster URL: %@ image= %@", posterURL, posterImage_.image);
        }
        // JDH FIX 7/25/12
        else {
            NSString *imageName = nil;
            if (frame.size.width < 100) {
                imageName = @"no_poster_avatar.png";
            } else {
                imageName = @"lrg_no_poster_avatar.png";
            }
            posterImage_.image = [UIImage imageNamed:imageName];
      //  NSLog(@"FilterPosterView InitwithframeDict poster image: %@", posterImage_.image);
        }
		if ([[dict objectForKey:@"useBookmark"] boolValue] == YES) {
			
			// detemine whether to use the small or large bookmark based on the poster size
			if (frame.size.width > 100) {
				bookmarkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lrg_bookmark_icon"]];
				bookmarkImage.frame = CGRectMake(frame.size.width-49, 0, 49, 48);			
			}
			else if (frame.size.width > 50) {
				bookmarkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sm_bookmark_icon"]];
				bookmarkImage.frame = CGRectMake(frame.size.width-22, 0, 22, 22);
			}
			
			[self addSubview:bookmarkImage];
        }
	}
	
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)setImageCornerRadius:(NSInteger)radius {
	self.layer.cornerRadius = radius;
}

-(void)posterImageDownloaded:(id)sender {
  //  NSLog(@"posterImageDownloaded beforeimage %@", posterImage_.image);  
	posterImage_.image = [(NSNotification*)sender image];
 //   NSLog(@"posterImageDownloaded afterimage %@", posterImage_.image);
}

@end
