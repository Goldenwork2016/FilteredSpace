//
//  FilterYoutubeView.m
//  TheFilter
//
//  Created by Patrick Hernandez on 5/12/11.
//  Copyright 2011 Mutual Mobile, LLC. All rights reserved.
//

#import "FilterYoutubeView.h"


@implementation FilterYoutubeView

#pragma mark -
#pragma mark Initialization

- (id)initWithStringAsURL:(NSString *)urlString frame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
       
        /*    Old pre-iOS 6 way of embedding video
        // Create webview with requested frame size
        //self = [[UIWebView alloc] initWithFrame:frame];
        
        // HTML to embed YouTube video
        NSString *youTubeVideoHTML = @"<html><head>\
        <body style=\"margin:0\">\
        <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
        width=\"%0.0f\" height=\"%0.0f\"></embed>\
        </body></html>";
        
        // Populate HTML with the URL and requested frame size
        NSString *html = [NSString stringWithFormat:youTubeVideoHTML, urlString, frame.size.width, frame.size.height];
        
        // Load the html into the webview
        [self loadHTMLString:html baseURL:nil];
        */
        
        //New way - using iFrame  - JDH Sept,2013
        self.backgroundColor = [UIColor blackColor];
         
        NSString *youTubeVideoHTML  = @"\
        <html><head>\
        <style type=\"text/css\">\
        body {  background-color: transparent;\
        color: white; \
        }\
        </style>\
        </head><body style=\"margin:0\">\
        <iframe class=\"youtube-player\" width=\"%0.0f\" height=\"%0.0f\" src=\"http://www.youtube.com/embed/%@?autoplay=1\" frameborder=\"0\" allowfullscreen=\"true\"></iframe>\
        </body></html>";
        NSString *html = [NSString stringWithFormat:youTubeVideoHTML, frame.size.width, frame.size.height, urlString];
        
        // Load the html into the webview
        [self loadHTMLString:html baseURL:nil];
        
        /*
        //Another try...
        
        NSString *yout = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", urlString];
        NSURL *url = [NSURL URLWithString: yout];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self loadRequest:request];
        */
        
    }
    
    return self;  
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc 
{
    [super dealloc];
}

@end
