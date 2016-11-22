//
//  FilterBandVideoTableCell.m
//  TheFilter
//
//  Created by John Thomas on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterBandVideoTableCell.h"
#import "FilterGlobalImageDownloader.h"
#import "Common.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0]
#define MEDIUM_TEXT_COLOR [UIColor colorWithRed:0.65 green:0.66 blue:0.66 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1.0]

@implementation FilterBandVideoTableCell

@synthesize durationLabel = durationLabel_;
@synthesize nameLabel = nameLabel_;
@synthesize videoImage = videoImage_;
@synthesize webView = webView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.

 		self.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];

		// the need for the chevron will be introduced in a later version
//		chevronView_ = [[UIImageView alloc] initWithFrame:CGRectMake(300, 27, 9, 14)];
//		chevronView_.image = [UIImage imageNamed:@"chevron.png"];
//		[self.contentView addSubview:chevronView_];
		
		nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 280, 15)];
		nameLabel_.font = FILTERFONT(13);
		nameLabel_.textColor = LIGHT_TEXT_COLOR;
		nameLabel_.adjustsFontSizeToFitWidth = YES;
		nameLabel_.minimumFontSize = 10;
		nameLabel_.textAlignment = UITextAlignmentLeft;
		nameLabel_.backgroundColor = [UIColor clearColor];
        //nameLabel_.text = @"test";
		[self.contentView addSubview:nameLabel_];
		
		durationLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(75, 25, 280, 12)];
		durationLabel_.font = FILTERFONT(10);
		durationLabel_.textColor = DARK_TEXT_COLOR;
		durationLabel_.adjustsFontSizeToFitWidth = YES;
		durationLabel_.minimumFontSize = 10;
		durationLabel_.textAlignment = UITextAlignmentLeft;
		durationLabel_.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:durationLabel_];
		
		//videoImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(70, 43, 60, 60)];
        videoImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
		videoImage_.image = [UIImage imageNamed:@"sm_no_image.png"];
		[self.contentView addSubview:videoImage_];
        
        //NSString *urlString = @"http://www.youtube.com/watch?v=1ytCEuuW2_A";
        
        //webView_ = [[FilterYoutubeView alloc] initWithStringAsURL:urlString frame:CGRectMake(0, 0, 60, 60)];
        //[self addSubview:webView_];
        
//        test = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
//
//        // HTML to embed YouTube video
//        NSString *youTubeVideoHTML = @"<html><head>\
//        <body style=\"margin:0\">\
//        <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
//        width=\"%0.0f\" height=\"%0.0f\"></embed>\
//        </body></html>";
//        
//        // Populate HTML with the URL and requested frame size
//        NSString *html = [NSString stringWithFormat:youTubeVideoHTML, urlString, 60, 60];
//        
//        // Load the html into the webview
//        [test loadHTMLString:html baseURL:nil];
//        [self.contentView addSubview:test];

	}
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    [webView_ touchesBegan:touches withEvent:event];
//    [super touchesBegan:touches withEvent:event];
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    [webView_ touchesEnded:touches withEvent:event];
//    [super touchesEnded:touches withEvent:event];
//}
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    return view;
//}
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    BOOL TEST = [super pointInside:point withEvent:event]; 
//    return TEST;
//}

-(void)posterImageDownloaded:(id)sender {
	videoImage_.image = [(NSNotification*)sender image];
}
     
// TODO: adjust primary, secondary, and image frames based on the amount of content in each

@end
