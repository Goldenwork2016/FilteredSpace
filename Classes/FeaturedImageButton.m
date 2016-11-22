//
//  FeaturedImageButton.m
//  TheFilter
//
//  Created by Ben Hine on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeaturedImageButton.h"
#import "FilterGlobalImageDownloader.h"

@implementation FeaturedImageButton
@synthesize imageView = imageView_;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.layer.cornerRadius = 5;
		
		//Testing code
		self.backgroundColor = [UIColor clearColor];
		imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		imageView_.image = [UIImage imageNamed:@"med_no_image.png"];
		imageView_.layer.cornerRadius = 5;
		imageView_.clipsToBounds = YES;
		[self addSubview:imageView_];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [imageView_ release]; 
    [super dealloc];
}

- (void)setImageURL:(NSString*)url {
	
	if (url != nil) {
		
		UIImage *img = [[FilterGlobalImageDownloader globalImageDownloader] imageForURL:url object:self selector:@selector(posterImageDownloaded:)];
		
		if(img) {
		
			imageView_.image = img;
		}
	}
}

-(void)posterImageDownloaded:(id)sender {
	imageView_.image = [(NSNotification*)sender image];
}


@end
